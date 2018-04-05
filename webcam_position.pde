import websockets.*;
WebsocketServer ws;


import processing.video.*;
Capture cam1;
Capture cam2;
String info1 = "name=USB 相机,size=640x480,fps=30";
String info2 = "name=USB 相机 #2,size=640x480,fps=30";

color c1;
color c2;
int total1;
int count1;
int total2;
int count2;


//location of body projected onto the left edge of the sketch
int yPos;
//cartesian version opf yPos
int cyPos;

//location of body projected onto the top edge of the sketch
int xPos;

//vector info from "shadow" locations on left and top edges
float slopeX;
float slopeY;

//extrapolated coordinates of the user
int xBody;
int yBody;

//y intercepts of both component positioning vectors
float b1;
float b2;

int now;
int numX;
int numY;
int num;

void setup() {
  size(600, 600);
  //     ws://localhost:8025/john
  ws= new WebsocketServer(this, 8025, "/john");
  now=millis();
  //colorMode(HSB);
  String[] cameras = Capture.list();
  
  if (cameras.length == 0) {
    //println("There are no cameras available for capture.");
    exit();
  } else {
    //println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      //println(cameras[i]);
      if (cameras[i].equals(info1) == true){
        cam1 = new Capture(this, cameras[i]);
      }
      if (cameras[i].equals(info2) == true){
        cam2 = new Capture(this, cameras[i]);
      }    
    }
    cam1.start();
    cam2.start();
  }      
}

void draw() {
  total1 = 0;
  total2 = 0;
  count1 = 0;
  count2 = 0;
  if (cam1.available() == true) {
    cam1.read();
  }
  if (cam2.available() == true) {
    cam2.read();
  }
  //image(cam1, 0, 0, cam1.width, cam1.height);
  //image(cam2, width/2, 0, cam2.width, cam2.height);
  
  
  cam1.loadPixels();
  for (int i=0; i < cam1.width; i++){
    c1 = cam1.pixels[cam1.height/2 * cam1.width + i];
    //println("cam1:green(c1):"+green(c1));
    //println("cam1:red(c1):"+red(c1));
    if ( red(c1) < 100){
      //fill(255);      
      total1 += i;
      count1++;
    }
  }
  if (count1 > 0){
    xPos = total1/count1;
  }
  cam2.loadPixels();
  for (int i=0; i < cam2.width; i++){
    c2 = cam2.pixels[cam2.height/2 * cam2.width + i];
    //println("cam2:green(c1):"+green(c1));
    //println("cam2:red(c1):"+red(c1));
    if ( red(c2) < 100){
      //fill(255);
      total2 += i;
      count2++;
    }
  }
  if (count2 > 0){
    yPos = total2/count2;
  }
  
  //ellipse(xPos, height/2, 10,10);
  //ellipse(cam1.width + yPos, height/2, 10,10);
  if (xPos != 0){
  xPos = int(map(xPos, 0, cam1.width, 0, 600));
  }
  if (yPos != 0){
  yPos = int(map(yPos, 0, cam2.width, 600, 0));
  }
  //print(xPos);
  //print(", ");
  //println(yPos);
  calculate();
  visual();
  position();
}

void calculate(){
  //calculate cartesian version of yPos
  cyPos = height - yPos;
  //yPos is the same as the y intercept for the Y-axis camera's positioning vector
  b1 = cyPos;
  //calculate y intercept of X-axis camera positioning vector
  b2 = height - xPos * slopeX;
  
  //only calculate slope if not infinite
  if (mouseX != (width/2)){
   //slope is delta y divided by delta x
   slopeX = (0 - height) / (width/2 - float(xPos));
   slopeY = (height/2 - float(cyPos)) / (width - 0);
  }
  
  //result linear equation for point at which X and Y positioning vectors intersect
  //only calculate if within trackable area
  if (xPos > 0 && xPos < width && yPos > 0 && yPos < height){
  xBody = int((height * width - b1*width + 2 * b1 * xPos) / (slopeY * width - 2 * slopeY * xPos + 2 * slopeX * xPos - slopeX * width));
  yBody = height - int(xBody * slopeY + cyPos);
  }
}

void visual(){
  background(0);
  fill(255);
  noStroke();
  //vertices of trackable area are established by the intersections of the boundaries of the cameras' viewing angles
  beginShape();
  vertex(0, 0);
  vertex(4 * width / 5, 2 * height / 5);
  vertex(2 * width / 3, 2 * height / 3);
  vertex(2 * width / 5, 4 * height / 5); 
  endShape(CLOSE);
  
  //square
  fill(100);
  beginShape();
  vertex(width / 3, height / 3);
  vertex(width / 3, 2 * height / 3);
  vertex(2 * width / 3, 2 * height / 3);
  vertex(2 * width / 3, height / 3); 
  endShape(CLOSE);
  
  stroke(255,255,0);
  line(xPos, 0, width/2, height);
  stroke(255,0, 255);
  line(0,yPos, width, height/2);
  
  noStroke();
  fill(255,255,0);
  ellipse(xPos, 0, 10, 10);
  fill(255, 0, 255);
  ellipse(0, yPos, 10, 10);

  if (xPos > 0 && xPos < width && yPos > 0 && yPos < height){
    fill(0, 0, 255);
    noStroke();
    ellipse(xBody, yBody, 10, 10);
  }
}

void position() {

  if (xBody> 5*width/15 && xBody< 6*width/15) {
    numX = 0;
  } else if (xBody> 6*width/15 && xBody< 7*width/15) {
    numX = 1;
  } else if (xBody> 7*width/15 && xBody< 8*width/15) {
    numX = 2;
  } else if (xBody> 8*width/15 && xBody< 9*width/15) {
    numX = 3;
  } else if (xBody> 9*width/15 && xBody< 10*width/15) {
    numX = 4;
  }
  
  if (yBody> 5*height/15 && yBody< 6*height/15) {
    numY = 0;
  } else if (yBody> 6*height/15 && yBody< 7*height/15) {
    numY = 1;
  } else if (yBody> 7*height/15 && yBody< 8*height/15) {
    numY = 2;
  } else if (yBody> 8*height/15 && yBody< 9*height/15) {
    numY = 3;
  } else if (yBody> 9*height/15 && yBody< 10*height/15) {
    numY = 4;
  }
  
  num = numX + 5*numY;
  if (millis()>now+500) {
  ws.sendMessage(str(num));
  now = millis();
  }
}

void webSocketEvent(String msg){
 println(msg);
}
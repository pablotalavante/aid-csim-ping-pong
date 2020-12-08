import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import processing.serial.*;
import oscP5.*;
import netP5.*;

//HandPose values
OscP5 oscP5;
NetAddress myRemoteLocation;
float topx, topy, botx, boty;
float xhand, yhand;

//IMU values
Serial Uno;
String valFromUno;
int rotX, rotY, acceX, acceY; 

//Haptic code send to Arduino
String hapticStr;

PVector[] mouth = new PVector[24];

// A reference to our box2d world
Box2DProcessing box2d;

// Just a single box this time
Box box;
Box cpu;

// An ArrayList of particles that will fall on the surface
ArrayList<Particle> particles;

Particle ball;
// The Spring that will attach to the box from the mouse
Spring spring, springCPU;

Boundary wallL, wallR, wallTop, wallBottom;

// Paddle Rotation
float rotation = 0;

// Haptic
Haptic haptic;

// Perlin noise values
float xoff = 0;
float yoff = 1000;

void setup() {
  size(700,700);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);
  // Turn on collision listening!
  box2d.listenForCollisions();

  // Make the box
  box = new Box(width/2, height/2);
  cpu = new Box(width/2, 40);
  
  // Make the spring (it doesn't really get initialized until the mouse is clicked)
  spring = new Spring();
  spring.update(500, 2);
  spring.bind(width/2, height/2, box);
  
  springCPU = new Spring();
  springCPU.update(100, 0.8);
  springCPU.bind(width/2, 40, cpu);

  ball = new Particle(width/2, 100, 10);
  ball.body.applyForce(new Vec2(random(-500, 500), -7000), ball.body.getPosition());
  
  // create boundaries
  wallR = new Boundary(width, height/2, 10, height);
  wallL = new Boundary(0, height/2, 10, height);
  
  wallTop = new Boundary(width/2, 0, width, 10);
  wallBottom = new Boundary(width/2, height, width, 10);
  
  haptic = new Haptic();
  
  oscP5 = new OscP5(this, 8008);
  // myRemoteLocation = new NetAddress("127.0.0.1", 1234);
  xhand = width/2;
  yhand = height/2;
  
  Uno = new Serial(this, "/dev/cu.usbmodem14301", 115200); //my serial port & baud rate
}

void draw() {
  background(255);
  
  splitIMUData();
  
  if (random(1) < 0.2) {
    float sz = random(4,8);
    //particles.add(new Particle(width/2,-20,sz));
  }

  // We must always step through time!
  box2d.step();

  // Make an x,y coordinate out of perlin noise
  float x = width/2;
  float y = height/2;
  xoff += 0.00;
  yoff += 0.00;

  if (true) {
    //spring.update(mouseX,mouseY);
    spring.update(xhand, yhand);
    spring.display();
    
    springCPU.update(box2d.getBodyPixelCoord(ball.body).x, 40);
    springCPU.display();
  } else {
    spring.update(x,y);
  }
  
  box.body.setAngularVelocity(rotation-box.body.getAngle());

  ball.display();

  // Draw the box
  box.display();
  cpu.display();
  // Draw the spring
  spring.display();
  
  wallR.display();
  wallL.display();
  wallTop.display();
  wallBottom.display();
  
  haptic.updatePosition(box2d.getBodyPixelCoord(ball.body).x, box2d.getBodyPixelCoord(ball.body).y);
  haptic.display();
  
  //define haptic id (String) to send to Arduino
  //let's write a separated function later
  /* hapticStr = '1';
  Uno.write(hapticStr);
  Uno.clear();*/

  stroke(5);
  rectMode(CORNERS);
  //rect((1-topx)*width, (topy+0.5)*height, (1-botx)*width, (boty+0.5)*height);
  //println((1-topx)*width, topy*height, (1-botx)*width, boty*height);
  // rect(200, 200, 500, 500);
  stroke(1);
  
  //TODO: calibrate the range of movement
  xhand = ((1-topx)*width + (1-botx)*width)/2;
  yhand = (boty+0.5)*height;
}

void keyPressed() {
  if (key == 'a'){
    rotation = -0.8;
  } else if (key == 'd'){
    rotation = 0.8;
  } else {
    rotation = 0;
  }
}

void oscEvent(OscMessage msg) {
   println(msg);
   if(msg.checkAddrPattern("/boundingBox/topLeft")==true) {
        topx = msg.get(0).floatValue()/1280;
        topy = msg.get(1).floatValue()/1280;
        //println("xtop", topx);
        println("ytop", topy);
   }
   if(msg.checkAddrPattern("/boundingBox/bottomRight")==true) { 
        botx = msg.get(0).floatValue()/1280;
        boty = msg.get(1).floatValue()/1280;
        //println("xbot", botx);
        println("ybot", boty);
   }
}

void splitIMUData(){
  //receive IMU data
  if(Uno.available() > 0) 
  {  
    valFromUno = Uno.readStringUntil('\n');         
  } 
  try {
     String[] res = valFromUno.split(",");
     rotX = Integer.parseInt(res[0]);
     rotY = Integer.parseInt(res[1]);
     acceX = Integer.parseInt(res[2]);
     acceY = Integer.parseInt(res[3]);
  }
  catch (Exception e)
  {
     rotX = 0;
     rotY = 0;
     acceX = 0;
     acceY = 0;
  }
  println(rotX, rotY, acceX, acceY);
  //after this, do whatever you want with those IMU data
}

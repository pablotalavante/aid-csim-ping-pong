import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import oscP5.*;
import netP5.*;
import processing.serial.*;

/* HandPose OSC comm */
OscP5 myOSC;
// NetAddress myRemoteLocation;
static final int OSC_PORT = 8008;
float topX, topY, botX, botY;
float handX, handY;

/* IMU + vibromotor serial comm */
Serial mySerial;
String SERIAL_PORT = Serial.list()[0]; //"/dev/cu.usbmodem14301"; // check the correct port in Arduino
static final int BAUDRATE = 115200; // check the correct baud rate
String valFromSerial;
float rotX, rotY, acceX, acceY; 
String hapticStr;

/* Box2D */
Box2DProcessing box2d;
// ArrayList<Particle> particles; 

Particle ball;
Boundary wallL, wallR, wallT, wallB;
Box humanPlayer, cpuPlayer; // Players as rectangle paddles
Spring springHuman, springCPU; // Springs that will attach to the boxes

/* Perlin noise values */
// float xOff = 0;
// float yOff = 1000;

float rotation = 0; // Paddle rotation
// TODO: Paddle acceleration?

/* Haptic feedback */
Haptic haptic; // The matrix displaying haptic patterns

void setup() {
  
  size(700,700);
  smooth();
  
  initBox2d();
  initOSC();
  initSerial();

  // Initialize the players
  humanPlayer = new Box(width/2, height/2);
  cpuPlayer = new Box(width/2, 40);
  
  // Initialize the springs - they don't really get initialized until the mouse is clicked
  springHuman = new Spring();
  springHuman.update(500, 2);
  springHuman.bind(width/2, height/2, humanPlayer);
  
  springCPU = new Spring();
  springCPU.update(100, 0.8);
  springCPU.bind(width/2, 40, cpuPlayer);

  // Initialize the ball
  ball = new Particle(width/2, 100, 10);
  ball.body.applyForce(new Vec2(random(-500, 500), -7000), ball.body.getPosition());
  
  // Create boundaries
  wallR = new Boundary(width, height/2, 10, height);
  wallL = new Boundary(0, height/2, 10, height);
  wallT = new Boundary(width/2, 0, width, 10);
  wallB = new Boundary(width/2, height, width, 10);
  
  // Initialize the haptic matrix
  haptic = new Haptic();
}

void initBox2d() {
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);
  box2d.listenForCollisions();
}

void initOSC() {
  myOSC = new OscP5(this, OSC_PORT); 
  // myRemoteLocation = new NetAddress("127.0.0.1", 1234); 
  handX = width/2;
  handY = height/2;
}

void initSerial() {
  mySerial = new Serial(this, SERIAL_PORT, BAUDRATE); 
}

void draw() {
  
  background(255);
  checkIMUData();
  box2d.step();
  
  /* if (random(1) < 0.2) {
    float sz = random(4,8);
    particles.add(new Particle(width/2,-20,sz));
  } */

  /* Update global position based on OSC data */
  if (true) {
    // springHuman.update(mouseX, mouseY);
    springHuman.update(handX, handY);
    springHuman.display();
    springCPU.update(box2d.getBodyPixelCoord(ball.body).x, 40);
    springCPU.display();
  } 
  // else {
    // springHuman.update(width/2, height/2);
    // Make an x,y coordinate out of perlin noise
    // xOff += 0.00;
    // yOff += 0.00; 
  //} 
  
  /* Update local rotation based on serial data */
  humanPlayer.body.setAngularVelocity(rotation - humanPlayer.body.getAngle());
  // TODO: update acceleration
  // humanPlayer.body.setLinearVelocity();

  /* Display all graphic elements */
  wallR.display();
  wallL.display();
  wallT.display();
  wallB.display();
  humanPlayer.display();
  cpuPlayer.display();
  ball.display();
  
  /* Send haptic feedback to Arduino */
  haptic.updatePosition(box2d.getBodyPixelCoord(ball.body).x, box2d.getBodyPixelCoord(ball.body).y);
  haptic.display(); // display haptic patterns
  hapticStr = getHapticData(); // define haptic position = [direction, distance]
  mySerial.write(hapticStr); // send to Arduino
  mySerial.clear();
  
  stroke(5);
  rectMode(CORNERS);
  // rect((1 - topX) * width, (topY + 0.5) * height, (1 - botX) * width, (botY + 0.5) * height);
  
  stroke(1);
  // TODO: map the range of movement @HandPose app and @Processing app
  handX = ((1 - topX) * width + (1 - botX) * width)/2;
  handY = (botY + 0.5) * height;
}

// listen to HandPose
void oscEvent(OscMessage msg) {
   if(msg.checkAddrPattern("/boundingBox/topLeft") == true) {
      topX = msg.get(0).floatValue()/1280;
      topY = msg.get(1).floatValue()/1280;
      println(topX, topY);
   }
   if(msg.checkAddrPattern("/boundingBox/bottomRight") == true) { 
      botX = msg.get(0).floatValue()/1280;
      botY = msg.get(1).floatValue()/1280;
      println(botX, botY);
   }
   println("HandPose:");
   println(handX, handY);
}

// listen to Arduino
void checkIMUData(){
  if (mySerial != null) {
    while(mySerial.available() > 0) {  
      valFromSerial = mySerial.readStringUntil('\n');   
      try {
       String[] res = valFromSerial.split(",");
       rotX = Float.parseFloat(res[0]);
       rotY = Float.parseFloat(res[1]);
       acceX = Float.parseFloat(res[2]);
       acceY = Float.parseFloat(res[3]);
      }
      catch (Exception e)
      {
         rotX = 0;
         rotY = 0;
         acceX = 0;
         acceY = 0;
      }
      println("IMU:");
      println(rotX, rotY, acceX, acceY);
    }  
    rotation = rotY/100;
    // TODO: acceleration
  } 
}

String getHapticData() {
  String res = "";
  // TODO: define data based on [direction, distance]
  return res;
}

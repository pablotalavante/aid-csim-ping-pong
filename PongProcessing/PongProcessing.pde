import shiffman.box2d.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.joints.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.collision.shapes.Shape;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;
import processing.serial.*;

// A reference to our box2d world
Box2DProcessing box2d;

// Just a single box this time
Box box;

// An ArrayList of particles that will fall on the surface
ArrayList<Particle> particles;

Particle ball;
// The Spring that will attach to the box from the mouse
Spring spring;

Boundary wallL, wallR, wallTop, wallBottom;

// Paddle Rotation
float rotation = 0;

// Haptic
Haptic haptic;

// Perlin noise values
float xoff = 0;
float yoff = 1000;

//IMU values
Serial Uno;
String valFromUno;
int rotX; //rotation X-axis
int rotY; //rotation Y-axis
int acceX; //acceleration X-axis
int acceY; //acceleration Y-axis

//Haptic code send to Arduino
String hapticStr;

void setup() {
  size(400,700);
  smooth();

  // Initialize box2d physics and create the world
  box2d = new Box2DProcessing(this);
  box2d.createWorld();
  box2d.setGravity(0, 0);
  // Turn on collision listening!
  box2d.listenForCollisions();

  // Make the box
  box = new Box(width/2, height/2);

  // Make the spring (it doesn't really get initialized until the mouse is clicked)
  spring = new Spring();
  spring.bind(width/2, height/2, box);

  // Create the empty list
  particles = new ArrayList<Particle>();

  ball = new Particle(width/2, 0, 10);
  ball.body.applyForce(new Vec2(random(-10, 10), -2000), ball.body.getPosition());
  
  // create boundaries
  wallR = new Boundary(width, height/2, 10, height);
  wallL = new Boundary(0, height/2, 10, height);
  wallTop = new Boundary(width/2, 0, width, 10);
  wallBottom = new Boundary(width/2, height, width, 10);
  
  haptic = new Haptic();
  
  Uno = new Serial(this, "/dev/cu.usbmodem14301", 115200); //my serial port & baud rate
}

void draw() {
  background(255);
  
  //receive IMU data
  if(Uno.available() > 0) 
  {  
    valFromUno = Uno.readStringUntil('\n'); 
    if (valFromUno != null) {
      splitIMUData(valFromUno);
    }
  } 
  //after this, do whatever you want with those IMU data

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

  // This is tempting but will not work!
  // box.body.setXForm(box2d.screenToWorld(x,y),0);

  // Instead update the spring which pulls the mouse along
  if (true) {
    spring.update(mouseX,mouseY);
    spring.display();
  } else {
    spring.update(x,y);
  }
  
  println(box.body.getAngle());
  box.body.setAngularVelocity(rotation-box.body.getAngle());

  // Look at all particles
  for (int i = particles.size()-1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.display();
    // Particles that leave the screen, we delete them
    // (note they have to be deleted from both the box2d world and our list
    if (p.done()) {
      particles.remove(i);
    }
  }
  ball.display();

  // Draw the box
  box.display();

  // Draw the spring
  spring.display();
  
  wallR.display();
  wallL.display();
  wallTop.display();
  wallBottom.display();
  
  haptic.updatePosition(box2d.getBodyPixelCoord(ball.body).x,
                        box2d.getBodyPixelCoord(ball.body).y);
  haptic.display();
  
  //define haptic id (String) to send to Arduino
  //let's write a separated function later
  /* hapticStr = '1';
  Uno.write(hapticStr);
  Uno.clear();*/
}


// Collision event functions!
void beginContact(Contact cp) {
  // Get both fixtures
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  // Get both bodies
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  // Get our objects that reference these bodies
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();

  // If object 1 is a Box, then object 2 must be a particle
  // Note we are ignoring particle on particle collisions
  if (o1.getClass() == Box.class) {
    Particle p = (Particle) o2;
    p.change();
  } 
  // If object 2 is a Box, then object 1 must be a particle
  else if (o2.getClass() == Box.class) {
    Particle p = (Particle) o1;
    p.change();
  }
}


// Objects stop touching each other
void endContact(Contact cp) {
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

void splitIMUData(String str) {
  String[] res = str.split(",");
  try {
     rotX = Integer.parseInt(res[0]);
     rotY = Integer.parseInt(res[1]);
     acceX = Integer.parseInt(res[2]);
     acceY = Integer.parseInt(res[3]);
  }
  catch (NumberFormatException e)
  {
     rotX = 0;
     rotY = 0;
     acceX = 0;
     acceY = 0;
  }
  println(rotX);
  println(rotY);
  println(acceX);
  println(acceY);
}

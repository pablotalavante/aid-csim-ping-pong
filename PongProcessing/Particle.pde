class Particle {
  // a Body with a radius and a color
  Body body;
  float r;
  color col;

  // Constructor
  Particle(float x, float y, float r_) {
    r = r_;
    makeBody(x, y, r);
    body.setUserData(this);
    col = color(175);
  }

  // Remove the particle from the Box2d world
  void killBody() {
    box2d.destroyBody(body);
  }

  // Change color when the ball hit the paddles
  void change() {
    col = color(255, 0, 0);
  }

  // Check if the particle ready for removal
  boolean done() {
    // Check the screen position 
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Check if it's at the bottom of the screen
    if (pos.y > height+r*2) {
      killBody();
      return true;
    }
    return false;
  }

  void display() {
    
    // Get screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Get angle of rotation
    float a = body.getAngle();
    
    pushMatrix();
    translate(pos.x, pos.y);
    rotate(a);
    fill(col);
    stroke(0);
    strokeWeight(1);
    ellipse(0, 0, r*2, r*2);
    
    // Add a line to see the rotation
    line(0, 0, r, 0);
    popMatrix();
  }

  // Here's our function that adds the particle to the Box2D world
  void makeBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    // Set its position
    bd.position = box2d.coordPixelsToWorld(x, y);
    bd.type = BodyType.DYNAMIC;
    body = box2d.createBody(bd);

    // Make the body's shape a circle
    CircleShape cs = new CircleShape();
    cs.m_radius = box2d.scalarPixelsToWorld(r);

    FixtureDef fd = new FixtureDef();
    fd.shape = cs;
    
    // Parameters that affect physics
    fd.density = 1;
    fd.friction = 0.01;
    fd.restitution = 0.5;

    // Attach fixture to body
    body.createFixture(fd);

    body.setAngularVelocity(random(-10, 10));
  }
}

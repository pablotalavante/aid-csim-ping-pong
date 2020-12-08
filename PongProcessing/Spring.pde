// class to describe the spring displayed as a line
class Spring {
  MouseJoint mouseJoint;

  // Constructor
  Spring() {
    // At first it doesn't exist
    mouseJoint = null;
  }

  // Set target to the mouse location 
  void update(float x, float y) {
    if (mouseJoint != null) {
      // Convert to world coordinates
      Vec2 mouseWorld = box2d.coordPixelsToWorld(x,y);
      mouseJoint.setTarget(mouseWorld);
    }
  }

  void display() {
    if (mouseJoint != null) {
      
      // Get the two anchor points
      Vec2 v1 = new Vec2(0,0);
      mouseJoint.getAnchorA(v1);
      Vec2 v2 = new Vec2(0,0);
      mouseJoint.getAnchorB(v2);
      
      // Convert to screen coordinates
      v1 = box2d.coordWorldToPixels(v1);
      v2 = box2d.coordWorldToPixels(v2);
      
      // Draw the line
      stroke(0);
      strokeWeight(1);
      line(v1.x,v1.y,v2.x,v2.y);
    }
  }


  /* Attach the spring to an x,y location and the Box object's location */
  void bind(float x, float y, Box box) {
    
    // Define the joint
    MouseJointDef md = new MouseJointDef();
    
    // Body A is just a fake ground body for simplicity (there isn't anything at the mouse)
    md.bodyA = box2d.getGroundBody();
    
    // Body 2 is the box's boxy
    md.bodyB = box.body;
    
    // Get the mouse location in world coordinates
    Vec2 mp = box2d.coordPixelsToWorld(x,y);
    
    // Set the target
    md.target.set(mp);
    md.maxForce = 1000.0 * box.body.m_mass;
    md.frequencyHz = 2.0;
    md.dampingRatio = 0.9;

    //box.body.wakeUp();

    // Make the joint
    mouseJoint = (MouseJoint) box2d.world.createJoint(md);
  }

  void destroy() {
    // Get rid of the joint when the mouse is released
    if (mouseJoint != null) {
      box2d.world.destroyJoint(mouseJoint);
      mouseJoint = null;
    }
  }
}

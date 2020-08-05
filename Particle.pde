class Particle {

  // We need to keep track of a Body and a radius
  Body body;
  float r;
  float density = 5e6f;
  color col;
  
  boolean isRemoved = false;
  Particle(){}
  Particle(float x, float y, float r_) {
    r = r_;
    // This function puts the particle in the Box2d world
    makeBody(x, y, r);
    body.setUserData(this);
    col = color(127);
  }
  Particle(float x, float y){
    this(x,y,3);
  }
  
  void setOrbitVelocity(Planet pn){
    Vec2 dis = pn.worldPosition.sub(body.getPosition());
    float R = dis.length();
    float _t = G*pn.mass/R;
    float v = (float)Math.sqrt(_t);
    dis.normalize();
    dis = new Vec2(-dis.y, dis.x);
    dis.mulLocal(v);
    body.setLinearVelocity(dis);
  }
  // 
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    fill(col);
    noStroke();
    ellipse(pos.x, pos.y, r*2, r*2);
  }
  void displayAround(Vec2 center, float radians){
    fill(col);
    noStroke();
    pushMatrix();
      Vec2 displayedpos = box2d.getBodyPixelCoord(body).sub(center);
      rotate(radians);
      ellipse(displayedpos.x, displayedpos.y, r*2, r*2);
    popMatrix();
  }

  void makeBody(float x, float y, float r) {
    // Define a body
    BodyDef bd = new BodyDef();
    //bd.allowSleep = true;
    //bd.awake = true;
    bd.fixedRotation = true;
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
    fd.density = density;
    fd.friction = 0.01;
    fd.restitution = 0.3;

    // Attach fixture to body
    body.createFixture(fd);

  }
}

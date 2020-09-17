class Particle {

  // We need to keep track of a Body and a radius
  Body body;
  float r;
  float density;
  float m;
  float rockPercent;
  
  color col;
  
  boolean isRemoved = false;
  float pixeld;
  float pixelrockd;
  
  Particle(){}
  Particle(float x, float y, float m_, float rp) {
    m = m_;
    rockPercent = rp;
    setDensity(rockPercent, m);

    makeBody(x, y, r);
    body.setUserData(this);
    //col = color(255,255,255);
    //println(r);
    col = getColor(r);
    //println(body.getMass());
    //println(body.getMass()/r/r/PI);
    pixeld = box2d.scalarWorldToPixels(r)*2;
    pixelrockd = (float)Math.sqrt(rockPercent*box2d.scalarWorldToPixels(r)*2);
  }
  Particle(float x, float y){
    //this(x,y,0.62832f);
    this(x,y,defaultMass, random(1));
  }
  
  void setOrbitVelocity(Planet pn){
    Vec2 dis = pn.worldPosition.sub(body.getPosition());
    float R = dis.length();
    float _t = G*planetMass/R;
    float v = (float)Math.sqrt(_t);
    dis.normalize();
    dis = new Vec2(-dis.y, dis.x);
    dis.mulLocal(v);
    body.setLinearVelocity(dis);
  }
  
  void setDensity(float rock, float totalmass){
    density = rock*rockDensity+(1-rock)*iceDensity;
    r = (float)Math.sqrt(totalmass/density/PI);
  }
  // 
  
  void roche_update(){
    Vec2 pos = box2d.coordWorldToPixels(body.getPosition());
    
    float r = (float)Math.sqrt(this.m/density/PI);
    r = box2d.scalarWorldToPixels(r);
    float bstprob = sigmoid(r, burstSize, burstSizeRange);
    //println(r);
    if(!roche_check(pos)||random(1)<bstprob){
      new Burst(this);
    }
  }
  
  void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    fill(col);
    noStroke();
    ellipse(pos.x, pos.y, pixeld, pixeld);
    fill(rockColor);
    ellipse(pos.x, pos.y, pixelrockd, pixelrockd);
    //println(dia);
  }
  void displayAround(Vec2 center, float radians){
    fill(col);
    noStroke();
    pushMatrix();
      Vec2 displayedpos = box2d.getBodyPixelCoord(body).sub(center);
      rotate(radians);
      ellipse(displayedpos.x, displayedpos.y, pixeld, pixeld);
      fill(rockColor);
      ellipse(displayedpos.x, displayedpos.y, pixelrockd, pixelrockd);
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
    cs.m_radius = r;

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

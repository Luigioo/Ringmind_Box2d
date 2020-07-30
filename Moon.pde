class Moon {
  
  Body body;
  float r;

  float density = 5e6f;
  float forceRange = 200;
  
  Vec2 pixelPosition;
  
  Moon(){
    r=moon_min;
    float radians = rdbt(0,2*PI);
    float this_ringdius = (inner_ringdius+outter_ringdius)/2;
    float x = this_ringdius*(float)Math.cos(radians)+planet.pixelPosition.x;
    float y = this_ringdius*(float)Math.sin(radians)+planet.pixelPosition.y;
    
    pixelPosition = new Vec2(x,y);
    makeBody(x, y, r);
    body.setUserData(this);
  }
  
  Moon(float x, float y, float r_){
    r = r_;
    pixelPosition = new Vec2(x, y);
    makeBody(x,y,r);
    body.setUserData(this);
  }
  
  void display(){
    pixelPosition = box2d.coordWorldToPixels(body.getPosition());
    //println("mass"+body.getMass());
    noStroke();
    fill(255,0,0,127);
    ellipse(pixelPosition.x,pixelPosition.y, r*2, r*2);
    
    //
    noFill();
    stroke(0,255,0,127);
    ellipse(pixelPosition.x, pixelPosition.y, forceRange*2, forceRange*2);
  }
  void displayAround(Vec2 center, float radians){
      noStroke();
      fill(255,0,0,127);
    pushMatrix();
      pixelPosition = box2d.coordWorldToPixels(body.getPosition());
      Vec2 displayedpos = pixelPosition.sub(center);
      rotate(radians);
      ellipse(displayedpos.x, displayedpos.y, r*2, r*2);
      
      noFill();
      stroke(0,255,0,127);
      ellipse(displayedpos.x, displayedpos.y, forceRange*2, forceRange*2);
    
    popMatrix();
  }
    
  void applyG(Particle p){
      //Vec2 mypos = worldPosition;
      Vec2 ppos = p.body.getPosition();
      Vec2 f = body.getPosition().sub(ppos);
      float distance = f.length();
      if(distance > box2d.scalarPixelsToWorld(forceRange)){return;}
      float minDistance = box2d.scalarPixelsToWorld(r);
      distance = Math.max(minDistance, distance);
      f.normalize();
      f = f.mulLocal(G*((body.getMass()*p.body.getMass())/(distance*distance)));
      p.body.applyForce(f, p.body.getWorldCenter());
      f.mulLocal(-1);
      body.applyForce(f, body.getWorldCenter());
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
    fd.density = density;
    fd.friction = 0.01;
    fd.restitution = 0.3;

    // Attach fixture to body
    body.createFixture(fd);
        //print(body.getMass());
  }
  
  
}

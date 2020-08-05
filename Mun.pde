class Mun extends Particle{
  
  float forceRange = 200;
  
  public Mun(){
    r=moon_min;
    float radians = rdbt(0,2*PI);
    float this_ringdius = (inner_ringdius+outter_ringdius)/2;
    float x = this_ringdius*(float)Math.cos(radians)+planet.pixelPosition.x;
    float y = this_ringdius*(float)Math.sin(radians)+planet.pixelPosition.y;
    
    makeBody(x, y, r);
    body.setUserData(this);
    setOrbitVelocity(planet);
  }
  
  public Mun(float x, float y, float r_) {
    r = r_;
    // This function puts the particle in the Box2d world
    makeBody(x, y, r);
    body.setUserData(this);
    setOrbitVelocity(planet);
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
    if(p instanceof Mun){
    }else{
      body.applyForce(f, body.getWorldCenter());
    }
   
  }
  
  void display(){
    Vec2 pixelPosition = box2d.coordWorldToPixels(body.getPosition());
    //println("mass"+body.getMass());
    noStroke();
    fill(255,0,0,127);
    ellipse(pixelPosition.x,pixelPosition.y, r*2, r*2);

    noFill();
    stroke(0,255,0,127);
    ellipse(pixelPosition.x, pixelPosition.y, forceRange*2, forceRange*2);
  }
  void displayAround(Vec2 center, float radians){
      noStroke();
      fill(255,0,0,127);
    pushMatrix();
      Vec2 pixelPosition = box2d.coordWorldToPixels(body.getPosition());
      Vec2 displayedpos = pixelPosition.sub(center);
      rotate(radians);
      ellipse(displayedpos.x, displayedpos.y, r*2, r*2);
      
      noFill();
      stroke(0,255,0,127);
      ellipse(displayedpos.x, displayedpos.y, forceRange*2, forceRange*2);
    
    popMatrix();
  }
  
}

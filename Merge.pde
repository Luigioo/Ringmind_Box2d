class Merge{
  
  Vec2 pos;
  Vec2 vel;
  //float r;
  float m;
  boolean burst;
  float rockPercent;
  
  Body b1;
  Body b2;

  Merge(Contact cp){
    burst = false;
    Fixture f1 = cp.getFixtureA();
    Fixture f2 = cp.getFixtureB();
    Body b1 = f1.getBody();
    Body b2 = f2.getBody();
    Object o1 = b1.getUserData();
    Object o2 = b2.getUserData();
    Particle p1 = (Particle) o1;
    Particle p2 = (Particle) o2;
    if(p1.isRemoved || p2.isRemoved) {return;}
    
    this.m = b1.getMass()+b2.getMass();
    float prob = sigmoid(m, moon_min*0.6, 3.0f/moon_min);
    if(random(1)<prob){
      //println(prob);
    //if(true){
      if(p1 instanceof Mun){muns.remove(p1);}else{pars.remove(p1);}
      if(p2 instanceof Mun){muns.remove(p2);}else{pars.remove(p2);}
      p1.isRemoved = true;
      p2.isRemoved = true;
      
      //Vec2 newpos = box2d.coordWorldToPixels(b1.getPosition()).add(box2d.coordWorldToPixels((b2.getPosition())));
      //float newr = (float)Math.sqrt(p1.r*p1.r+p2.r*p2.r);
      //newpos.mulLocal(0.5f);
      ////println(newpos.x);
      ////println(newpos.y);
      ////println(newr);
      //Merge tp = new Merge(newpos, newr, b1, b2);
      
      calc_properties(p1,p2,b1,b2);
      float density = rockPercent*rockDensity+(1-rockPercent)*iceDensity;
      float r = (float)Math.sqrt(this.m/density/PI);
      r = box2d.scalarWorldToPixels(r);
      float bstprob = sigmoid(r, 30.0f, 3.0f/15.0f);
      println(r);
      if(random(1)<bstprob){
        burst = true;
        println(bstprob);
      }
      
      toaddnremove.add(this);
    }
  }
  //Merge(Particle p1, Particle p2, Body b1, Body b2){
  //  calc_properties(p1,p2,b1,b2);
  //}
  //Merge(Vec2 p, float r, Body b1, Body b2){
  //  pos = p;
  //  this.r = r;
  //  this.b1 = b1;
  //  this.b2 = b2;
  //}
  
  void calc_properties(Particle p1, Particle p2, Body b1, Body b2){
    this.b1 = b1;
    this.b2 = b2;
    float m1 = b1.getMass();
    float m2 = b2.getMass();
    //m1 *= m1;
    //m2 *= m2;
    float totalm = m1+m2;
    Vec2 displace = b2.getPosition().sub(b1.getPosition());
    float posx = displace.x / totalm * m2;
    float posy = displace.y / totalm * m2;
    posx += b1.getPosition().x;
    posy += b1.getPosition().y;
    this.pos = box2d.coordWorldToPixels(new Vec2(posx, posy));
    //this.r = (float)Math.sqrt(p1.r*p1.r+p2.r*p2.r);
    Vec2 v1 = b1.getLinearVelocity().clone();
    Vec2 v2 = b2.getLinearVelocity().clone();
    v1.mulLocal(m1);
    v2.mulLocal(m2);
    v1.addLocal(v2);
    v1.mulLocal(1/totalm);
    this.vel = v1;
    
    //rock percent
    m = totalm;
    rockPercent = (p1.rockPercent*m1+p2.rockPercent*m2)/totalm;
    
  }
  
  //
  void reborn(){
    if(this.burst){
      //float newr = this.r*this.r/burstNum;
      //newr = (float)Math.sqrt(newr);
      float newm = this.m/burstNum;
      
      for(int i=burstNum-1;i>=0;i--){
        float radians = 2*PI*i/burstNum;
        float radius = 20.0f;
        float x = radius*(float)Math.cos(radians)+this.pos.x;
        float y = radius*(float)Math.sin(radians)+this.pos.y;
        Particle newp = new Particle(x,y,newm, rockPercent);
        //newp.setOrbitVelocity(planet);
        Vec2 newvel = this.vel.clone();
        //newvel.subLocal(burstVel[i]);
        //newvel.addLocal(burstVel[i]);
        //newp.body.setLinearVelocity(newvel.add(burstVel[i]));
        newp.body.setLinearVelocity(newvel);
        pars.add(newp);
      }
    }
    else if(this.m>moon_min){
      Mun m = new Mun(this.pos.x, this.pos.y, this.m, rockPercent);
      muns.add(m);
      m.body.setLinearVelocity(this.vel);
      
    }else{
      Particle newParti = new Particle(this.pos.x, this.pos.y, m, rockPercent);
      pars.add(newParti);
      newParti.body.setLinearVelocity(this.vel);
    }
    box2d.destroyBody(this.b1);
    box2d.destroyBody(this.b2);
  }
  
}

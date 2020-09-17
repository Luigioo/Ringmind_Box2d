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
    
    float relSize = (b1.getMass()-b2.getMass())/this.m;
    relSize = Math.abs(relSize);
    float prob_relSize = sigmoid(relSize, relativeSize, relativeSizeRange);
    float prob_combined = sigmoid(m, combinedSize, combinedSizeRange);
    
    if(random(1)<prob_relSize ){//if merge
      //println("relsize pass");
      if(random(1)<prob_combined){
        //println("combined pass");
        if(p1 instanceof Mun){muns.remove(p1);}else{pars.remove(p1);}
        if(p2 instanceof Mun){muns.remove(p2);}else{pars.remove(p2);}
        p1.isRemoved = true;
        p2.isRemoved = true;
        
        calc_properties(p1,p2,b1,b2);
        float density = rockPercent*rockDensity+(1-rockPercent)*iceDensity;
        
        toaddnremove.add(this);
      }
    }
  }
  Merge(){};
  

  
  
  void calc_properties(Particle p1, Particle p2, Body b1, Body b2){
    this.b1 = b1;
    this.b2 = b2;
    float m1 = b1.getMass();
    float m2 = b2.getMass();
    //m1 *= m1;
    //m2 *= m2;
    float totalm = m1+m2;
    Vec2 displace = b2.getPosition().sub(b1.getPosition());
    //here calculates the new position for merged moon
    float posx = displace.x / totalm * m2;
    float posy = displace.y / totalm * m2;
    posx += b1.getPosition().x;
    posy += b1.getPosition().y;
    this.pos = box2d.coordWorldToPixels(new Vec2(posx, posy));

    Vec2 v1 = b1.getLinearVelocity().clone();
    Vec2 v2 = b2.getLinearVelocity().clone();
    v1.mulLocal(m1);
    v2.mulLocal(m2);
    v1.addLocal(v2);
    v1.mulLocal(1/totalm);
    this.vel = v1;

    m = totalm;
    rockPercent = (p1.rockPercent*m1+p2.rockPercent*m2)/totalm;
  }
  

  //
  void reborn(){
    if(this.burst){

      make_burst(this.pos, this.m, this.vel);
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
  void make_burst(Vec2 pos, float mass, Vec2 vel){
    float newm = mass/burstNum;
    float borrowedVel = 0f;
    for(int i=burstNum-1;i>=0;i--){
      float radians = 2*PI*i/burstNum;
      float radius = newm*20.0f;
      float x = radius*(float)Math.cos(radians)+pos.x;
      float y = radius*(float)Math.sin(radians)+pos.y;
      Particle newp = new Particle(x,y,newm, rockPercent);
      //newp.setOrbitVelocity(planet);
      Vec2 newvel = vel.clone();
      if(i!=0){
        float mag = newvel.length();
        float sign = random(2)-1;
        // println("sign: "+sign);
        float addedVel = burstAccel*sign;
        borrowedVel -= addedVel;
        mag += addedVel;
        newvel.normalize();
        newvel.mulLocal(mag);
      }else{
        float mag = newvel.length();
        mag += borrowedVel;
        newvel.normalize();
        newvel.mulLocal(mag);
      }
      //newvel.subLocal(burstVel[i]);
      //newvel.addLocal(burstVel[i]);
      //newp.body.setLinearVelocity(newvel.add(burstVel[i]));
      newp.body.setLinearVelocity(newvel);
      pars.add(newp);
    }
  }
}

class Burst extends Merge{
  
  Burst(Particle p){
    if(p.body.getMass()<=minimumMass){
      return;    
    }
    if(p instanceof Mun){
      muns.remove(p);
    }else{
      pars.remove(p);
    }
    Vec2 pos = box2d.coordWorldToPixels(p.body.getPosition());
    float mass = p.body.getMass();
    make_burst(pos, mass, p.body.getLinearVelocity());
    box2d.destroyBody(p.body);
  }
  
  
}

boolean roche_check(Vec2 position){
  float distance = planet.pixelPosition.sub(position).length();
  float prob = sigmoid(distance, rocheLimit, 100f/rocheLimit);
  return random(1)<prob;
}

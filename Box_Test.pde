// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;

// A list for all of our rectangles
ArrayList<Particle> pars;
ArrayList<Mun> muns = new ArrayList<Mun>();
ArrayList<TempParti> toaddnremove = new ArrayList<TempParti>();

Box2DProcessing box2d;
Planet planet;

Camera camera;

float G = 6.674e-11f;
int partis = 400;
float inner_ringdius = 300f;
float outter_ringdius = 430f;
float moon_min = 10.0f;

boolean previousM = false;
boolean currentM = false;

void setup() {
  size(1200, 1200);
  //frameRate(30);
  // Initialize and create the Box2D world
  box2d = new Box2DProcessing(this, 1e4f);  
  box2d.createWorld();
  box2d.setGravity(0,0);
  box2d.listenForCollisions();

  pars = new ArrayList<Particle>();
  planet = new Planet();
  
  for(int i=0;i<partis;i++){
    float radians = rdbt(0,2*PI);
    float this_ringdius = (rdbt(inner_ringdius, outter_ringdius));
    float x = this_ringdius*(float)Math.cos(radians)+planet.pixelPosition.x;
    float y = this_ringdius*(float)Math.sin(radians)+planet.pixelPosition.y;
    Particle p = new Particle(x, y);
    p.setOrbitVelocity(planet);
    pars.add(p);
  }
  Mun mu = new Mun();
  muns.add(mu);
  
  
  camera = new Camera();
  camera.setOrbitVelocity(planet);
  //Moon m2 = new Moon();
  //m2.setOrbitVelocity(planet);
  //moons.add(m2);
}

void draw() {

  background(255);
  //println(frameRate);
  box2d.step(1f/60f,10,8);
  //particles and bodies to be added and removed

  for(TempParti tp:toaddnremove){
    //print("addnremove");
    if(tp.r>moon_min){
      muns.add(new Mun(tp.pos.x, tp.pos.y, tp.r));
    }else{
      Particle newParti = new Particle(tp.pos.x, tp.pos.y, tp.r);
      pars.add(newParti);
      newParti.setOrbitVelocity(planet);
    }
    box2d.destroyBody(tp.b1);
    box2d.destroyBody(tp.b2);
  }
  toaddnremove.clear();
  
  // When the mouse is clicked, add a new particle
  if(!previousM && mousePressed){
    Particle p = new Particle(mouseX, mouseY);
    p.setOrbitVelocity(planet);
    pars.add(p);
  }
  //apply gravity
  for (int i = pars.size()-1; i >= 0; i--) {
    Particle p = pars.get(i);   
    planet.applyG(p);
    for(Mun mo:muns){
      mo.applyG(p);
    }
  }
  for(Mun mo:muns){
    for(Mun m2:muns){
      if(mo!=m2){mo.applyG(m2);}
    }
    planet.applyG(mo);
  }
  planet.applyG(camera);
  camera.update();
  //camera.display();

  //display
  if(keyPressed){
    displayAll();
  }else{
    displayNormal();
  }
  
  
  //handle inputs
  if(mousePressed){
    previousM = true;
  }else{
    previousM = false;
  }
}
class TempParti{
  Vec2 pos;
  float r;
  Body b1;
  Body b2;
  TempParti(Vec2 p, float r, Body b1, Body b2){
    pos = p;
    this.r = r;
    this.b1 = b1;
    this.b2 = b2;
  }
}
void beginContact(Contact cp){
  Fixture f1 = cp.getFixtureA();
  Fixture f2 = cp.getFixtureB();
  Body b1 = f1.getBody();
  Body b2 = f2.getBody();
  Object o1 = b1.getUserData();
  Object o2 = b2.getUserData();
  //if(o1 instanceof Particle){
  //  Particle p1 = (Particle) o1;
  //  if(o2 instanceof Particle){
  //    Particle p2 = (Particle) o2;
  //  }else{
  //    Moon m2 = (Moon) o2;
  //  }
  //}
  //if two particles collide
  if(!(o1 instanceof Mun) && !(o2 instanceof Mun)){
        Particle p1 = (Particle) o1;
        Particle p2 = (Particle) o2;
        
        if(p1.isRemoved || p2.isRemoved) {return;}
        pars.remove(p1);
        pars.remove(p2);
        p1.isRemoved = true;
        p2.isRemoved = true;
        
        Vec2 newpos = box2d.coordWorldToPixels(b1.getPosition()).add(box2d.coordWorldToPixels((b2.getPosition())));
        float newr = (float)Math.sqrt(p1.r*p1.r+p2.r*p2.r);
        newpos.mulLocal(0.5f);
        //println(newpos.x);
        //println(newpos.y);
        //println(newr);
        TempParti tp = new TempParti(newpos, newr, b1, b2);
        toaddnremove.add(tp);
  }else{
    //print("collide"); 
  }
}
void endContact(Contact cp) {
}

void displayNormal(){
   for(Particle p:pars){
      p.display();
    }
    planet.display();
  for(Mun mo:muns){
    mo.display();
  }
}
void displayAll(){
  
  pushMatrix();
    Vec2 moonpos = box2d.coordWorldToPixels(camera.worldpos);
    //Vec2 moonpos = moon.pixelPosition;
    translate(width/2,height/2);
    
    Vec2 disrotate = planet.pixelPosition.sub(moonpos);
    float disatan = disrotate.y/disrotate.x;
    //println("before"+disatan);
    
    disatan = (PI/2-atan(disatan));
    if(disrotate.x<0){
      disatan = disatan+PI;
    }
    //println("after"+disatan/PI*180);
    //println(disrotate.x+" "+disrotate.y);
    for(Particle p:pars){
      p.displayAround(moonpos, disatan);
    }
    planet.displayAround(moonpos, disatan);
    for(Mun mo:muns){
      mo.displayAround(moonpos, disatan);
    }
    //moon.displayAround(moonpos, disatan);
  popMatrix();

}
float rdbt(float min, float max){
  return (float)random(1)*(max-min)+min;
  
}

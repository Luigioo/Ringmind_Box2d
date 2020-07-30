import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import shiffman.box2d.*; 
import org.jbox2d.collision.shapes.*; 
import org.jbox2d.common.*; 
import org.jbox2d.dynamics.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Box_Test extends PApplet {

// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com






// A list for all of our rectangles
ArrayList<Particle> pars;
Box2DProcessing box2d;
Planet planet;
Moon moon;

int partis = 600;
float inner_ringdius = 400f;

float outter_ringdius = 450f;

boolean previousM = false;
boolean currentM = false;

public void setup() {
  
  //frameRate(30);
  
 
  // Initialize and create the Box2D world
  box2d = new Box2DProcessing(this, 1e4f);  
  box2d.createWorld();
  box2d.setGravity(0,0);

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
  moon = new Moon();
  moon.setOrbitVelocity(planet);
}

public void draw() {

  background(255);
  //println(frameRate);
  // We must always step through time!
  //box2d.step();
  box2d.step(1f/60f,10,8);

  // When the mouse is clicked, add a new Box object
  if(!previousM && mousePressed){
    Particle p = new Particle(mouseX, mouseY);
    p.setOrbitVelocity(planet);
    pars.add(p);
  }
  //println(previousM+" "+ mousePressed);


  for (int i = pars.size()-1; i >= 0; i--) {
    Particle p = pars.get(i);
    
    planet.applyG(p);
    moon.applyG(p);
    

    if (p.done()) {
      pars.remove(i);
    }
    //print(p.body.getMass());

  }
  

  
  planet.applyG(moon);
  
  if(keyPressed){
    displayAll();
  }else{
    displayNormal();
  }

  
  
  if(mousePressed){
    previousM = true;
  }else{
    previousM = false;
  }
}
public void displayNormal(){
   for(Particle p:pars){
      p.display();
    }
    planet.display();
    moon.display();
}
public void displayAll(){
  
  pushMatrix();
    Vec2 moonpos = moon.pixelPosition;
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
    moon.displayAround(moonpos, disatan);
  popMatrix();

}
public float rdbt(float min, float max){
  return (float)random(1)*(max-min)+min;
  
}
class Moon {
  
  
  Body body;
  float r;
  float G = 6.674e-11f;
  float density = 1e6f;
  
  Vec2 pixelPosition;
  //Vec2 worldPosition;
  
  Moon(){
    r=10;
    float radians = rdbt(0,2*PI);
    float this_ringdius = (inner_ringdius+outter_ringdius)/2;
    float x = this_ringdius*(float)Math.cos(radians)+planet.pixelPosition.x;
    float y = this_ringdius*(float)Math.sin(radians)+planet.pixelPosition.y;
    
    pixelPosition = new Vec2(x,y);
    makeBody(x, y, r);
  }
  
  public void display(){
    //println("mass"+body.getMass());
    noStroke();
    fill(255,0,0,127);
    pixelPosition = box2d.coordWorldToPixels(body.getPosition());
    ellipse(pixelPosition.x,pixelPosition.y, r*2, r*2);
  }
public void displayAround(Vec2 center, float radians){
    noStroke();
    fill(255,0,0,127);
  pushMatrix();
    pixelPosition = box2d.coordWorldToPixels(body.getPosition());
    Vec2 displayedpos = pixelPosition.sub(center);
    //rotate(radians);
    ellipse(displayedpos.x, displayedpos.y, r*2, r*2);
  
  popMatrix();
}
    
  public void applyG(Particle p){
      //Vec2 mypos = worldPosition;
      Vec2 ppos = p.body.getPosition();
      Vec2 f = body.getPosition().sub(ppos);
      float distance = f.length();
      float minDistance = box2d.scalarPixelsToWorld(r);
      distance = Math.max(minDistance, distance);
      f.normalize();
      f = f.mulLocal(G*((body.getMass()*p.body.getMass())/(distance*distance)));
      p.body.applyForce(f, p.body.getWorldCenter());
  }
  public void setOrbitVelocity(Planet pn){
    Vec2 dis = pn.worldPosition.sub(body.getPosition());
    float R = dis.length();
    float _t = G*pn.mass/R;
    float v = (float)Math.sqrt(_t);
    dis.normalize();
    dis = new Vec2(-dis.y, dis.x);
    dis.mulLocal(v);
    body.setLinearVelocity(dis);
  }
  
  public void makeBody(float x, float y, float r) {
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
    fd.friction = 0.01f;
    fd.restitution = 0.3f;

    // Attach fixture to body
    body.createFixture(fd);

  }
  
  
}
class Particle {

  // We need to keep track of a Body and a radius
  Body body;
  float r;
  int col;
  
  float G = 6.674e-11f;
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

  // This function removes the particle from the box2d world
  public void killBody() {
    box2d.destroyBody(body);
  }

  public void applyForce(PVector force){
    body.applyForce(new Vec2(force.x, force.y), body.getWorldCenter());
  }
  
  public void setOrbitVelocity(Planet pn){
    Vec2 dis = pn.worldPosition.sub(body.getPosition());
    float R = dis.length();
    float _t = G*pn.mass/R;
    float v = (float)Math.sqrt(_t);
    dis.normalize();
    dis = new Vec2(-dis.y, dis.x);
    dis.mulLocal(v);
    body.setLinearVelocity(dis);
  }


  // Is the particle ready for deletion?
  public boolean done() {
    // Let's find the screen position of the particle
    Vec2 pos = box2d.getBodyPixelCoord(body);
    // Is it off the bottom of the screen?
    if (pos.y > height+r*2 || pos.y<-r*2
        || pos.x>width+r*2 || pos.x<-r*2) {
      killBody();
      return true;
    }
    return false;
  }


  // 
  public void display() {
    // We look at each body and get its screen position
    Vec2 pos = box2d.getBodyPixelCoord(body);
    fill(col);
    noStroke();
    ellipse(pos.x, pos.y, r*2, r*2);
  }
public void displayAround(Vec2 center, float radians){
    fill(col);
    noStroke();
  pushMatrix();
    Vec2 displayedpos = box2d.getBodyPixelCoord(body).sub(center);
    rotate(radians);
    ellipse(displayedpos.x, displayedpos.y, r*2, r*2);
  
  popMatrix();
}

  // Here's our function that ////adds the particle to the Box2D world
  public void makeBody(float x, float y, float r) {
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
    fd.density = 1e-5f;
    fd.friction = 0.01f;
    fd.restitution = 0.3f;

    // Attach fixture to body
    body.createFixture(fd);

  }
}
class Planet{
  
    float G = 6.674e-11f;
    float mass = 1e5f;
    float minPixelsDistance = 70;
    Vec2 pixelPosition = new Vec2(width/2, height/2);
    Vec2 worldPosition = box2d.coordPixelsToWorld(pixelPosition);

    public void applyG(Particle p){
        //Vec2 mypos = worldPosition;
        Vec2 ppos = p.body.getPosition();
        Vec2 f = worldPosition.sub(ppos);
        float distance = f.length();
        float minDistance = box2d.scalarPixelsToWorld(minPixelsDistance);
        distance = Math.max(minDistance, distance);
        f.normalize();
        f = f.mulLocal(G*((mass*p.body.getMass())/(distance*distance)));
        p.body.applyForce(f, p.body.getWorldCenter());
    }
    
    public void applyG(Moon p){
        Vec2 ppos = p.body.getPosition();
        Vec2 f = worldPosition.sub(ppos);
        float distance = f.length();
        float minDistance = box2d.scalarPixelsToWorld(minPixelsDistance);
        distance = Math.max(minDistance, distance);
        f.normalize();
        f = f.mulLocal(G*((mass*p.body.getMass())/(distance*distance)));
        p.body.applyForce(f, p.body.getWorldCenter());
        //Vec2 vel = p.body.getLinearVelocity();
        //vel.addLocal(f);
        //p.body.setLinearVelocity(vel);
    }
    public void display(){
        noFill();
        stroke(255,0,0,127);
        ellipse(pixelPosition.x,pixelPosition.y, minPixelsDistance*2, minPixelsDistance*2);
    }
    
    public void displayAround(Vec2 center, float radians){
      noFill();
      stroke(255,0,0,127);
      pushMatrix();
        Vec2 displayedpos = pixelPosition.sub(center);
        rotate(radians);
        ellipse(displayedpos.x, displayedpos.y, minPixelsDistance*2, minPixelsDistance*2);
      
      popMatrix();
    }

}
  public void settings() {  size(1200, 1200); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Box_Test" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}

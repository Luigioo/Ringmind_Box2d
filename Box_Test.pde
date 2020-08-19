import controlP5.*;
import shiffman.box2d.*;
import org.jbox2d.collision.shapes.*;
import org.jbox2d.common.*;
import org.jbox2d.dynamics.*;
import org.jbox2d.dynamics.contacts.*;


ArrayList<Particle> pars;
ArrayList<Mun> muns = new ArrayList<Mun>();
ArrayList<Merge> toaddnremove = new ArrayList<Merge>();
ControlP5 cp5;
ArrayList<Putton> puttons = new ArrayList<Putton>();

Box2DProcessing box2d;
Planet planet;
Camera camera;

//adjustable parameters
float G = 6.674e-11f;//gravity constant
int partis = 600;//number of initial particals
float inner_ringdius = 300f;//inner radius of the ring
float outter_ringdius = 430f;//outter radius of the ring
float moon_min = 8.0f;//minimum mass if a moon
//float moon_max = 16.0f;
int burstNum = 8;//number of particles generated after a burst
float burstAccel = 0.01f;//change of speed for bursted particles(not implemented yet)
float rockDensity = 5.0f;//density of rock(black part)
float iceDensity = 1.0f;//density of ice(non-black part)
float defaultMass = 0.3f*PI;//initial mass of a particle
float planetForceRange = 500f;//planetary gravity's maximum range(the big circle)
float planetMass = 1e14f;
float planetMinPixelsDistance = 70f;//planetary gravity's minimum range(the small circle)
float moonForceRange = 200f;

//colors
color backColor = color(27, 38, 44);
color grav = color(0,183,194);
color planetColor = color(5, 219, 242);
color rockColor = color(0);
//others
boolean previousM = false;
boolean currentM = false;
Vec2[] burstVel;

void setup() {
  size(1600, 1200);
  //frameRate(30);

  init();
  initControls();
}
void init(){
  box2d = new Box2DProcessing(this);  
  box2d.createWorld();
  box2d.setGravity(0,0);
  box2d.listenForCollisions();

  pars = new ArrayList<Particle>();
  muns = new ArrayList<Mun>();
  toaddnremove = new ArrayList<Merge>();
  puttons = new ArrayList<Putton>();
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

  camera = new Camera();
  camera.setOrbitVelocity(planet);
  //Moon m2 = new Moon();
  //m2.setOrbitVelocity(planet);
  //moons.add(m2);
  Mun mu = new Mun(camera.pos.x, camera.pos.y);
  mu.setOrbitVelocity(planet);
  //print(mu.body.getMass());
  muns.add(mu);
  calc_burst();
  
  //println(box2d.scalarPixelsToWorld(1));
  
}
void draw() {

  background(backColor);
  //println(frameRate);
  box2d.step(1f/60f,10,8);
  
  //particles and bodies to be added and removed
  for(Merge tp:toaddnremove){
    tp.reborn();
  }
  toaddnremove.clear();
  

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
  // When the mouse is clicked, add a new particle
  //if(!previousM && mousePressed){
  //  Particle p = new Particle(mouseX, mouseY);
  //  p.setOrbitVelocity(planet);
  //  pars.add(p);
  //}
  if(mousePressed){
    previousM = true;
  }else{
    previousM = false;
  }
  
  updateControls();
}

void beginContact(Contact cp){
  new Merge(cp);
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
    translate(width/2,height/2-365);
    
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

void calc_burst(){
  burstVel = new Vec2[burstNum];
  for(int i=burstNum-1;i>=0;i--){
    float angle = (float)i / (float)burstNum*2.0f*PI;
    //println("angle"+angle);
    float x = burstAccel*cos(angle);
    float y = burstAccel*sin(angle);

    if(x<0.00001f&&x>-0.00001f){
      x = 0;
    }
    if(y<0.00001f&&y>-0.00001f){
      y = 0;
    }
    burstVel[i] = new Vec2(x,y);
    //println(burstVel[i].x+"   "+burstVel[i].y);
  }
}

float rdbt(float min, float max){
  return (float)random(1)*(max-min)+min;
}
float sigmoid(float x, float shift, float shrink){
  return 1.0f/(1.0f+exp((-x+shift)*shrink));
}
color getColor(float mass){
  float max = 2;
  if(mass<=0){
    return color(255,183, 255);
  }else if(mass>max){
    return color(0, 183, 255);
  }else{
    return color(255-mass/max*255, 183,255);
  }
    
}

class Planet{
  
    //float G = 6.674e-11f;
    //float planetMass = 1e14f;
    //float planetMinPixelsDistance = 70;
    //float planetForceRange = 500;
    Vec2 pixelPosition = new Vec2(width/2, height/2);
    Vec2 worldPosition = box2d.coordPixelsToWorld(pixelPosition);

    void applyG(Particle p){
        //Vec2 mypos = worldPosition;
        Vec2 ppos = p.body.getPosition();
        Vec2 f = worldPosition.sub(ppos);
        float distance = f.length();
        //if(distance > box2d.scalarPixelsToWorld(500)){return;}
        float minDistance = box2d.scalarPixelsToWorld(planetMinPixelsDistance);
        distance = Math.min(box2d.scalarPixelsToWorld(planetForceRange), distance);
        distance = Math.max(minDistance, distance);
        f.normalize();
        f = f.mulLocal(G*((planetMass*p.body.getMass())/(distance*distance)));
        p.body.applyForce(f, p.body.getWorldCenter());
    }
    
    void applyG(Camera c){
        Vec2 ppos = c.worldpos;
        Vec2 f = box2d.coordPixelsToWorld(pixelPosition).sub(ppos);
        float distance = f.length();
        float minDistance = box2d.scalarPixelsToWorld(planetMinPixelsDistance);
        distance = Math.max(minDistance, distance);
        f.normalize();
        f = f.mulLocal(G*((planetMass/(distance*distance))));
        c.addvel(f);
    }
    
    void display(){
        noFill();
        stroke(planetColor);
        //fill(planetColor);
        ellipse(pixelPosition.x,pixelPosition.y, planetMinPixelsDistance*2, planetMinPixelsDistance*2);
        
        noFill();
        stroke(grav);
        ellipse(pixelPosition.x,pixelPosition.y, planetForceRange*2, planetForceRange*2);
        //drawGradient(pixelPosition.x, pixelPosition.y, planetForceRange*2, grav);
    }
    
    void displayAround(Vec2 center, float radians){
      noFill();
      stroke(planetColor);
      //fill(planetColor);
      pushMatrix();
        Vec2 displayedpos = pixelPosition.sub(center);
        rotate(radians);
        ellipse(displayedpos.x, displayedpos.y, planetMinPixelsDistance*2, planetMinPixelsDistance*2);
      
        noFill();
        stroke(grav);
        ellipse(displayedpos.x,displayedpos.y, planetForceRange*2, planetForceRange*2);
      popMatrix();
    }
    
  void drawGradient(float x, float y, float range, color c) {
    float radius = range;
    fill(c);
    ellipse(x,y,radius, radius);
    float h = 255;
    for (float r = radius; r > 0; --r) {
      fill(backColor, h);
      ellipse(x, y, r, r);
      h = 255-r/radius*255;
    }
  }

}

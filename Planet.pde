class Planet{
  
    float G = 6.674e-11f;
    float mass = 1e5f;
    float minPixelsDistance = 70;
    float forceRange = 500;
    Vec2 pixelPosition = new Vec2(width/2, height/2);
    Vec2 worldPosition = box2d.coordPixelsToWorld(pixelPosition);

    void applyG(Particle p){
        //Vec2 mypos = worldPosition;
        Vec2 ppos = p.body.getPosition();
        Vec2 f = worldPosition.sub(ppos);
        float distance = f.length();
        //if(distance > box2d.scalarPixelsToWorld(500)){return;}
        float minDistance = box2d.scalarPixelsToWorld(minPixelsDistance);
        distance = Math.min(box2d.scalarPixelsToWorld(500), distance);
        distance = Math.max(minDistance, distance);
        f.normalize();
        f = f.mulLocal(G*((mass*p.body.getMass())/(distance*distance)));
        p.body.applyForce(f, p.body.getWorldCenter());
    }
    
    void applyG(Moon p){
        Vec2 ppos = p.body.getPosition();
        Vec2 f = worldPosition.sub(ppos);
        float distance = f.length();
        float minDistance = box2d.scalarPixelsToWorld(minPixelsDistance);
        distance = Math.max(minDistance, distance);
        f.normalize();
        f = f.mulLocal(G*((mass*p.body.getMass())/(distance*distance)));
        p.body.applyForce(f, p.body.getWorldCenter());

    }
    void applyG(Camera c){
        Vec2 ppos = c.worldpos;
        Vec2 f = box2d.coordPixelsToWorld(pixelPosition).sub(ppos);
        float distance = f.length();
        float minDistance = box2d.scalarPixelsToWorld(minPixelsDistance);
        distance = Math.max(minDistance, distance);
        f.normalize();
        f = f.mulLocal(G*((mass/(distance*distance))));
        c.addvel(f);
    }
    
    void display(){
        noFill();
        stroke(255,0,0,127);
        ellipse(pixelPosition.x,pixelPosition.y, minPixelsDistance*2, minPixelsDistance*2);
        noFill();
        stroke(0,255,0,127);
        ellipse(pixelPosition.x,pixelPosition.y, forceRange*2, forceRange*2);
    }
    
    void displayAround(Vec2 center, float radians){
      noFill();
      stroke(255,0,0,127);
      pushMatrix();
        Vec2 displayedpos = pixelPosition.sub(center);
        rotate(radians);
        ellipse(displayedpos.x, displayedpos.y, minPixelsDistance*2, minPixelsDistance*2);
      
        noFill();
        stroke(0,255,0,127);
        ellipse(displayedpos.x,displayedpos.y, forceRange*2, forceRange*2);
      popMatrix();
    }

}

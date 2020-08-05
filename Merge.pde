class Merge{
  Vec2 pos;
  float r;
  Body b1;
  Body b2;
  Vec2 vel;
  Merge(Particle p1, Particle p2, Body b1, Body b2){
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
    this.r = (float)Math.sqrt(p1.r*p1.r+p2.r*p2.r);
    Vec2 v1 = b1.getLinearVelocity().clone();
    Vec2 v2 = b2.getLinearVelocity().clone();
    v1.mulLocal(m1);
    v2.mulLocal(m2);
    v1.addLocal(v2);
    v1.mulLocal(1/totalm);
    this.vel = v1;
  }
  Merge(Vec2 p, float r, Body b1, Body b2){
    pos = p;
    this.r = r;
    this.b1 = b1;
    this.b2 = b2;
  }
}

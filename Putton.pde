class Putton{
  
  int posx, posy;
  int sizex=200,sizey=19;
  int padx=10,pady=7;
  color backcolor = color(229,243,255, 122);
  
  Putton(String varName, int x, int y, float mid, float range){
    this(varName, x, y, mid-range, mid+range, true);
  }
  
  Putton(String varName, int x, int y, float min, float max, boolean b){
    cp5.addSlider(varName)
      .setPosition(x,y)
      .setRange(min, max)
      .setSize(sizex,sizey)
      .setValue((min+max)/2.0f)
      .setFont(createFont("Arial",14))
      ;
    posx = x;
    posy = y;
    
  }
  
  void display(){
    noStroke();
    fill(backcolor);
    rect(posx-padx, posy-pady, sizex+padx*2, sizey+pady*2);
    
  }
  
}



public void initControls(){
  //println(PFont.list());
  cp5 = new ControlP5(this);
  
  //cp5.addTextlabel("label")
  //  .setText("SETUP")
  //  .setPosition(50,17)
  //  .setColorValue(0xffE5F3FF)
  //  .setFont(createFont("Arial",17))
  //  ;
    
  puttons.add(new Putton("G", 50,50, 3.674e-11f, 9.674e-11f, true));
  
  puttons.add(new Putton("partis", 50, 70, 600, 500));
  puttons.add(new Putton("inner_ringius", 50, 90, 300f, 200f));
  puttons.add(new Putton("outter_ringius", 50, 110, 430f, 200f));
  
  puttons.add(new Putton("moon_min", 50, 130, 8, 4));
  puttons.add(new Putton("burstNum", 50, 150, 8, 6));
  puttons.add(new Putton("rockDensity", 50, 170, 5, 4));
  puttons.add(new Putton("iceDensity", 50, 190, 1f, .6f));
  
  puttons.add(new Putton("defaultMass", 50, 210, 0.1f*PI, 1.0f*PI, true));
  
  puttons.add(new Putton("planetForceRange", 50, 230, 700, 200));
  puttons.add(new Putton("planetMass", 50, 250, 0.5e14f, 2.0e14f, true));
  puttons.add(new Putton("planetMinPixelsDistance", 50, 270, 70, 60));
  puttons.add(new Putton("moonForceRange", 50, 290, 200, 100));
  puttons.add(new Putton("relativeSize", 50, 310, 0.1f, 0.1f));
  puttons.add(new Putton("combinedSize", 50, 330, 8.0f, 7.0f));
  puttons.add(new Putton("rocheLimit", 50, 350, 350f, 300f));
  puttons.add(new Putton("roche_check_frequency", 50, 370, 5, 4));
  puttons.add(new Putton("burstAccel", 50, 390, 2f, 1.99f));
  
  cp5.addButton("resetCtrls")
   .setValue(0)
   .setPosition(50,450)
   .setSize(200,19)
   .setFont(createFont("Arial",14))
   ;
  
}

public void resetCtrls(){
  println("resetssss");
  init();
}

public void updateControls(){
  for(Putton p:puttons){
    //p.display();
  }
}

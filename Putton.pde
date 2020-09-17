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
  int off = 0;
  cp5.addTextlabel("setup")
    .setText("SETUP")
    .setPosition(50,17)
    .setColorValue(0xffE5F3FF)
    .setFont(createFont("Arial",17))
    ;
    
  puttons.add(new Putton("G", 50,50, 6.674e-11f, 3.674e-11f));
  puttons.add(new Putton("partis", 50, 70, 600, 500));
  puttons.add(new Putton("inner_ringdius", 50, 90, 300f, 200f));
  puttons.add(new Putton("outter_ringdius", 50, 110, 430f, 200f));
  
  off = 160;
  cp5.addTextlabel("play")
    .setText("PLAY")
    .setPosition(50,off-25)
    .setColorValue(0xffE5F3FF)
    .setFont(createFont("Arial",17))
  ;
  puttons.add(new Putton("moon_min", 50, 0+off, 8, 4));
  puttons.add(new Putton("burstNum", 50, 20+off, 8, 6));
  puttons.add(new Putton("rockDensity", 50, 40+off, 5, 4));
  puttons.add(new Putton("iceDensity", 50, 60+off, 1f, .6f));
  puttons.add(new Putton("defaultMass", 50, 80+off, 0.3f*PI, 0.3f*PI));
  puttons.add(new Putton("planetForceRange", 50, 100+off, 700, 200));
  puttons.add(new Putton("planetMass", 50, 120+off, 0.5e14f, 2.0e14f, true));
  puttons.add(new Putton("planetMinPixelsDistance", 50, 140+off, 70, 60));
  puttons.add(new Putton("moonForceRange", 50, 160+off, 200, 100));
  puttons.add(new Putton("burst_check_frequency", 50, 180+off, 5, 4));
  puttons.add(new Putton("burstAccel", 50, 200+off, 2, 1));
  puttons.add(new Putton("minimumMass", 50, 220+off, 0.1f*PI, 0.1f*PI));
  
  off = 435;
  cp5.addTextlabel("prob")
  .setText("PROBABAILITIES")
  .setPosition(50,off-25)
  .setColorValue(0xffE5F3FF)
  .setFont(createFont("Arial",17))
;
  puttons.add(new Putton("relativeSize", 50, 0+off, 0.1f, 0.1f));
  puttons.add(new Putton("relativeSizeRange", 50, 20+off, 0.5f, 0.5f));
  puttons.add(new Putton("combinedSize", 50, 40+off, 2.0f, 2.0f));
  puttons.add(new Putton("combinedSizeRange", 50, 60+off, 2f, 2f));
  puttons.add(new Putton("rocheLimit", 50, 80+off, 350f, 300f));
  puttons.add(new Putton("rocheLimitRange", 50, 100+off, 50, 50));
  puttons.add(new Putton("burtSize", 50, 120+off, 15, 15));
  puttons.add(new Putton("burstSizeRange", 50, 140+off, 5, 5));

  
  cp5.addButton("resetCtrls")
   .setValue(0)
   .setPosition(50,650)
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

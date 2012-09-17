/* Processing code for this example
 
 // Graphing sketch
 
 
 // This program takes ASCII-encoded strings
 // from the serial port at 9600 baud and graphs them. It expects values in the
 // range 0 to 1023, followed by a newline, or newline and carriage return
 
 // Created 20 Apr 2005
 // Updated 18 Jan 2008
 // by Tom Igoe
 // This example code is in the public domain.
*/
 
import processing.serial.*;
 
Serial myPort;        // The serial port
int xPos = 1;        // horizontal position of the graphs
float accelXValueLow = 100; // X-axis accelerometer data to map to graph height 0
float accelXValueHigh = 1000; // X-axis accelerometer data to map to the top of the graph
float accelYValueLow = 100; // Y-axis accelerometer data to map to graph height 0
float accelYValueHigh = 500; // Y-axis accelerometer data to map to the top of the graph
float accelZValueLow = 100; // Z-axis accelerometer data to map to graph height 0
float accelZValueHigh = 500; // Z-axis accelerometer data to map to the top of the graph
 
// Variables used when serial input isn't available
boolean TEST_MODE = true; // if true, random datapoints will be generated and passed in
float x;
float y;
float z;
int loopnum = 0;

DataPoint[] graphState; // the state of the graph
DataPoint latest = null; // the most recent datapoint
float xhighThresh = 80; // A threshold to trigger when the x-axis of the accelerometer goes high
float xlowThresh = 20;  // A threshold to trigger when the x-axis of the accelerometer goes low
float yhighThresh = 80; // A threshold to trigger when the y-axis of the accelerometer goes high
float ylowThresh = 20;  // A threshold to trigger when the y-axis of the accelerometer goes low
float zhighThresh = 80; // A threshold to trigger when the z-axis of the accelerometer goes high
float zlowThresh = 20;  // A threshold to trigger when the z-axis of the accelerometer goes low

// Scrollbars for user control
HScrollbar xhighScroll, xlowScroll;
HScrollbar yhighScroll, ylowScroll;
HScrollbar zhighScroll, zlowScroll;

void strokeRed() {
  stroke(255, 0, 0);
  fill(255, 0, 0);
}

void strokeGrey() {
  stroke(110, 110, 110);
  fill(110, 110, 110);
}

void drawThresholdLine(float ypos, boolean high) {
  if (high){
    strokeRed();
  }
  else {
    strokeGrey();
  }
  
  line(0, ypos, 2*width/3, ypos);
  rect(2*width/3-16, ypos-8, 16, 16);
}

void drawStaticBackground() {
  // set inital background:
  background(0);
  
  // draw a box
  stroke(255, 255, 255);
  fill(255, 255, 255);
  rect(2*width/3 + 5, 5, width/3 - 10, height - 10, 7);
  
  // and some header text
  textAlign(CENTER);
  fill(110,110,110);
  text("Accelerometer Data Graphing Utility", 2*width/3, 15, width/3, 50);
  
  // and some labels
  text("X-Axis Data", 2*width/3, height/6-60, width/3, 40);
  text("Y-Axis Data", 2*width/3, height/2-60, width/3, 40);
  text("Z-Axis Data", 2*width/3, 5*height/6-60, width/3, 40);

  text("High Threshold", 2*width/3 + 220, height/6-28, width/3 - 240, 16);   
  text("Low Threshold", 2*width/3 + 220, height/6+12, width/3 - 240, 16);  
  text("High Threshold", 2*width/3 + 220, height/2-28, width/3 - 240, 16);  
  text("Low Threshold", 2*width/3 + 220, height/2+12, width/3 - 240, 16);  
  text("High Threshold", 2*width/3 + 220, 5*height/6-28, width/3 - 240, 16);  
  text("Low Threshold", 2*width/3 + 220, 5*height/6+12, width/3 - 240, 16);  
}

void setup () {
  // set the window size:
  size(1000, 600);
  graphState = new DataPoint[2*width/3];
 
  // List all the available serial ports
  println(Serial.list());
 
  // I know that the first port in the serial list on my mac
  // is always my  Arduino, so I open Serial.list()[0].
  // Open whatever port is the one you're using.
  myPort = new Serial(this, Serial.list()[0], 9600);
 
  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');
 
  // draw the static background
  drawStaticBackground();
  
  // and initialize some scrollbars
  xhighScroll = new HScrollbar(2*width/3 + 15, height/6-20, 200, 16, 1);
  xhighScroll.newspos = xhighScroll.xpos + map(xhighThresh, 0, 100, 0, xhighScroll.swidth);
  xlowScroll = new HScrollbar(2*width/3 + 15, height/6+20, 200, 16, 1);
  xlowScroll.newspos = xlowScroll.xpos + map(xlowThresh, 0, 100, 0, xlowScroll.swidth);
  yhighScroll = new HScrollbar(2*width/3 + 15, height/2-20, 200, 16, 1);
  yhighScroll.newspos = yhighScroll.xpos + map(yhighThresh, 0, 100, 0, yhighScroll.swidth);
  ylowScroll = new HScrollbar(2*width/3 + 15, height/2+20, 200, 16, 1);
  ylowScroll.newspos = ylowScroll.xpos + map(ylowThresh, 0, 100, 0, ylowScroll.swidth);
  zhighScroll = new HScrollbar(2*width/3 + 15, 5*height/6-20, 200, 16, 1);
  zhighScroll.newspos = zhighScroll.xpos + map(zhighThresh, 0, 100, 0, zhighScroll.swidth);
  zlowScroll = new HScrollbar(2*width/3 + 15, 5*height/6+20, 200, 16, 1);
  zlowScroll.newspos = zlowScroll.xpos + map(zlowThresh, 0, 100, 0, zlowScroll.swidth);
}

void drawGraph() {
  for (int i = 0; i < graphState.length; i++) {
    DataPoint dp = graphState[i];
    if (dp == null) {
      break;
    }
    dp.draw(i);
  }
}

void draw () {
  // redraw the static background
  drawStaticBackground();
  
  // update the scrollbars
  xhighScroll.update();
  xlowScroll.update();
  yhighScroll.update();
  ylowScroll.update();
  zhighScroll.update();
  zlowScroll.update();
  
  // Set our threshold values based on scollbar position
  
  // these are scaled values from 0 to 100 for graph display
  xhighThresh = map(xhighScroll.getPos(), 0, 200, 0, 100);
  xlowThresh = map(xlowScroll.getPos(), 0, 200, 0, 100);
  yhighThresh = map(yhighScroll.getPos(), 0, 200,0, 100);
  ylowThresh = map(ylowScroll.getPos(), 0, 200, 0, 100);
  zhighThresh = map(zhighScroll.getPos(), 0, 200, 0, 100);
  zlowThresh = map(zlowScroll.getPos(), 0, 200, 0, 100);
  
  // these are actual values based on accelerometer input
  float xhighThreshRaw = map(xhighThresh, 0, 100, accelXValueLow, accelXValueHigh);
  float xlowThreshRaw = map(xlowThresh, 0, 100, accelXValueLow, accelXValueHigh);
  float yhighThreshRaw = map(yhighThresh, 0, 100, accelYValueLow, accelYValueHigh);
  float ylowThreshRaw = map(ylowThresh, 0, 100, accelYValueLow, accelYValueHigh);
  float zhighThreshRaw = map(zhighThresh, 0, 100, accelZValueLow, accelZValueHigh);
  float zlowThreshRaw = map(zlowThresh, 0, 100, accelZValueLow, accelZValueHigh);
  
  // write out the raw threshold values to the graph
  textAlign(CENTER);
  fill(110,110,110);
  text(xhighThreshRaw, 2*width/3 + 272, height/6);   
  text(xlowThreshRaw, 2*width/3 + 272, height/6+40);  
  text(yhighThreshRaw, 2*width/3 + 272, height/2);  
  text(ylowThreshRaw, 2*width/3 + 272, height/2+40);  
  text(zhighThreshRaw, 2*width/3 + 272, 5*height/6);  
  text(zlowThreshRaw, 2*width/3 + 272, 5*height/6+40); 
  
  xhighScroll.display();
  xlowScroll.display();
  yhighScroll.display();
  ylowScroll.display();
  zhighScroll.display();
  zlowScroll.display();
  
  // draw the graph
  drawGraph();
    
  // draw the threshold lines
  float xhigh_yPos = map(xhighThresh, 0, 100, height/3, 0);
  float xlow_yPos = map(xlowThresh, 0, 100, height/3, 0);
  float yhigh_yPos = map(yhighThresh, 0, 100, 2*height/3, height/3);
  float ylow_yPos = map(ylowThresh, 0, 100, 2*height/3, height/3);
  float zhigh_yPos = map(zhighThresh, 0, 100, height, 2*height/3);
  float zlow_yPos = map(zlowThresh, 0, 100, height, 2*height/3);
  if (latest != null) {
    drawThresholdLine(xhigh_yPos, latest.xHigh);
    drawThresholdLine(xlow_yPos, latest.xLow);
    drawThresholdLine(yhigh_yPos, latest.yHigh);
    drawThresholdLine(ylow_yPos, latest.yLow);
    drawThresholdLine(zhigh_yPos, latest.zHigh);
    drawThresholdLine(zlow_yPos, latest.zLow);
  }
  else {
    drawThresholdLine(xhigh_yPos, false);
    drawThresholdLine(xlow_yPos, false);
    drawThresholdLine(yhigh_yPos, false);
    drawThresholdLine(ylow_yPos, false);
    drawThresholdLine(zhigh_yPos, false);
    drawThresholdLine(zlow_yPos, false);
  }
  
  // TESTING ONLY: activate the serialEvent as if the accelerometer has sent new input.
  if (TEST_MODE) {
    serialEvent(myPort);
  }
}

void serialEvent (Serial myPort) {
  float rawX = 0, rawY = 0, rawZ = 0;
  boolean input_valid = false;
  
  // TESTING ONLY: generate random datapoints
  if (TEST_MODE) {
    if (loopnum % 10 == 0) { 
      x = random(accelXValueLow, accelXValueHigh);
      y = random(accelYValueLow, accelYValueHigh);
      z = random(accelZValueLow, accelZValueHigh);
    }
    loopnum++;
    rawX = x;
    rawY = y;
    rawZ = z;
    input_valid = true;
  }
  
  // Normal mode: read input from the accelerometer over the Serial connection
  else {
    // get the ASCII string: 
    String inString = myPort.readStringUntil('\n');
    if (inString != null) {
      inString = trim(inString);    // trim off any whitespace:
     
      // split into the three axes of accelerometer input
      String[] xyz = split(inString, ' ');
     
      // convert to floats
      rawX = float(xyz[0]); 
      rawY = float(xyz[1]);
      rawZ = float(xyz[2]);
      
      input_valid = true;
    }
  }

  if (input_valid) {
    // record the data in the global state
    DataPoint newdp = new DataPoint(rawX, rawY, rawZ);
    graphState[xPos-1] = newdp;
    latest = newdp;
     
    // at the edge of the screen, go back to the beginning:
    if (xPos >= 2*width/3-16) {
      xPos = 1;
      graphState = new DataPoint[2*width/3];
    } 
    else {
      // increment the horizontal position:
      xPos++;
    }
  }
}

class DataPoint {
  float xVal, yVal, zVal; // accelerometer values for the three axes
  boolean xHigh, yHigh, zHigh; // whether the value was above its high threshold when it was measured
  boolean xLow, yLow, zLow; // whether the value was below its low threshold when it was measured
  
  DataPoint(float _xVal, float _yVal, float _zVal) {
    xVal = _xVal;
    yVal = _yVal;
    zVal = _zVal;
    checkThresholds();
  }
  
  void checkThresholds() {
    // check thresholds against original values
    float scaledX = map(xVal, accelXValueLow, accelXValueHigh, 0, 100);
    xHigh = scaledX >= xhighThresh;
    xLow = scaledX <= xlowThresh;
    
    float scaledY = map(yVal, accelYValueLow, accelYValueHigh, 0, 100);
    yHigh = scaledY >= yhighThresh;
    yLow = scaledY <= ylowThresh;
     
    float scaledZ = map(zVal, accelZValueLow, accelZValueHigh, 0, 100);
    zHigh = scaledZ >= zhighThresh;
    zLow = scaledZ <= zlowThresh;
  }
  
  float normalizeForDisplay(float value, char axis) {
    float avLow = 100, avHigh = 500;
    switch(axis) {
      case 'x':
        avLow = accelXValueLow;
        avHigh = accelXValueHigh;
        break;
      case 'y':
        avLow = accelYValueLow;
        avHigh = accelYValueHigh;
        break;
      case 'z':
        avLow = accelZValueLow;
        avHigh = accelZValueHigh;
        break;
    }
    return map(value, avLow, avHigh, 0, height/3);
  }
  
  void draw(float xPos) {
    stroke(0,0,255);
    line(xPos, height/3, xPos, height/3 - normalizeForDisplay(xVal, 'x'));
    
    stroke(0,255,0);
    line(xPos, 2*height/3, xPos, 2*height/3 - normalizeForDisplay(yVal, 'y'));
          
    stroke(255,165,0);
    line(xPos, height, xPos, height - normalizeForDisplay(zVal, 'z'));
  }
}

class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }
  
  void update() {
    if(overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if(mousePressed && over) {
      locked = true;
    }
    if(!mousePressed) {
      locked = false;
    }
    if(locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if(abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
    }
  }
  
  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if(mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if(over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return (spos-xpos) * ratio;
  }
}
 

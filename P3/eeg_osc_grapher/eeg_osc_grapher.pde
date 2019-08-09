/*
*190809.mindGraph
*-----------------
* catches eeg-wave signals from thinkgearConnector
* channel per signal
* plots
* sendable osc 
* normalizable and scalable values 
*/

import neurosky.*;
import org.json.*;
import oscP5.*;
import netP5.*;
import controlP5.*;

OscP5 oscP5;
NetAddress theReceiver;
ThinkGearSocket neuroSocket;

int attention=0;
int meditation=0;
int de, th, al, ah, bl, bh, gl, gm;

int w, h, t;
PFont fontA;

Channel[] channels = new Channel[11];
int delta_level, theta_level, low_alpha_level, high_alpha_level, 
    low_beta_level, high_beta_level, low_gamma_level, mid_gamma_level;
int att_level, med_level, blink_level;

boolean newBlink, newMed, newAtt;

boolean[] isSending = new boolean[11];
boolean[] isNorm = new boolean[11];
int[] mult = new int[11];



void setup() {
  //-- other setups
  size(800, 600);
  w = width;
  h = height;
  frameRate(12);
  frame.setTitle("[interspecifics]: EEG Brain Grapher OSC");
  smooth();
  noFill();
  fontA = createFont("digit.ttf", 12);
  textFont(fontA);
  //-- osc
  oscP5 = new OscP5(this,12000);
  theReceiver = new NetAddress("192.168.1.160", 8000);
  //-- Creat the channel objects
  channels[0] = new Channel("Blink", color(0), "o-o", "/blink");
  channels[1] = new Channel("Attention", color(100), "Attention", "/attention");
  channels[2] = new Channel("Meditation", color(150), "Meditation", "/meditation");
  channels[3] = new Channel("Delta", color(219, 211, 42), "Dreamless Sleep", "/delta");
  channels[4] = new Channel("Theta", color(245, 80, 71), "Drowsy", "/theta");
  channels[5] = new Channel("Low Alpha", color(237, 0, 119), "Relaxed", "/lo_alpha");
  channels[6] = new Channel("High Alpha", color(212, 0, 149), "Relaxed", "/hi_alpha");
  channels[7] = new Channel("Low Beta", color(158, 18, 188), "Alert", "/lo_beta");
  channels[8] = new Channel("High Beta", color(116, 23, 190), "Alert", "/hi_beta");
  channels[9] = new Channel("Low Gamma", color(39, 25, 159), "---", "/lo_gamma");
  channels[10] = new Channel("High Gamma", color(23, 26, 153), "---", "/hi_gamma");
  delay(1000);
  // button states
  for (int k=0; k<11; k++){
    isSending[k] = false;
    isNorm[k] = false;
    mult[k] = 0;    
  }
  //-- tg stuff
  ThinkGearSocket neuroSocket = new ThinkGearSocket(this);
  try {
    neuroSocket.start();
  }catch (Exception e) {
    println("Is ThinkGear running??");
  }
}



void draw() {
  background(255);
  strokeWeight(2);
  /*plot*/
  for (int k=0; k<11; k++){
    int buffSize = channels[k].points.size()<100 ? channels[k].points.size() : 100;
    int channSize = channels[k].points.size();
    float px=0, py=0;
    stroke(channels[k].drawColor);
    beginShape();
    for (int i=0; i<buffSize-1; i++){
      Point thisPoint = channels[k].points.get(channSize-1-i);
      px = (w-175) - i * (w-175)/100;
      py = 20+(k+1)*(h/12) - map(thisPoint.value, channels[k].minValue, channels[k].maxValue, 0, (h-100)/12);
      if (i==1) {
        ellipse(px, py, 5, 5);
        strokeWeight(1);
        line (px+3, py, px+13, py);
        strokeWeight(2);
        fill(channels[k].drawColor);
        text(nf(thisPoint.value), px+15, py+2);
        noFill();
      }
      //if (k==0) vertex(px, py);
      curveVertex(px, py);
    }
    endShape();
    //-- lines
    strokeWeight(1);
    stroke(0, 127);
    line(25, 20 + (k+1)*(h/12), w - 125, 20 + (k+1)*(h/12));
    for (int j=0; j<20; j++){
      line(25+j*(w-175)/20, 20 + (k+1)*(h/12) + 2, 25+j*(w-175)/20, 20 + (k+1)*(h/12)-2);
    }
    //-- label
    fill(channels[k].drawColor);
    text(channels[k].name, 25, (k+1)*(h/12)-17);
    noFill();
    //-- buttons
    strokeWeight(1);
    if (isSending[k]) fill(channels[k].drawColor);
    else noFill();
    rect(w-121, (k+1)*(h/12)-25, 19, 39);
    if (isNorm[k]) fill(channels[k].drawColor, 64);
    else noFill();
    rect(w-100, (k+1)*(h/12)-25, 58, 19);
    if (mult[k]==1)fill(channels[k].drawColor, 92);
    else noFill();
    rect(w-100, (k+1)*(h/12)-4, 18, 18);
    if (mult[k]==2)fill(channels[k].drawColor, 156);
    else noFill();
    rect(w-80, (k+1)*(h/12)-4, 18, 18);
    if (mult[k]==3)fill(channels[k].drawColor, 220);
    else noFill();
    rect(w-60, (k+1)*(h/12)-4, 18, 18);
  }
}



void mousePressed(){
  if (mouseButton==LEFT){
    for(int k=0; k<11; k++){
      if ((mouseX > w-121) && (mouseX < w-102) && (mouseY > (k+1)*(h/12)-25) && (mouseY < (k+1)*(h/12)+14)){
        isSending[k] = !isSending[k];
      }
      if ((mouseX > w-100) && (mouseX < w-42) && (mouseY > (k+1)*(h/12)-25) && (mouseY < (k+1)*(h/12)-6)){
        isNorm[k] = !isNorm[k];
      }
      if ((mouseX > w-100) && (mouseX < w-82) && (mouseY > (k+1)*(h/12)-4) && (mouseY < (k+1)*(h/12)+14)){
        mult[k] = mult[k]==1 ? 0 : 1;
      }
      if ((mouseX > w-80) && (mouseX < w-62) && (mouseY > (k+1)*(h/12)-4) && (mouseY < (k+1)*(h/12)+14)){
        mult[k] = mult[k]==2 ? 0 : 2;
      }
      if ((mouseX > w-60) && (mouseX < w-42) && (mouseY > (k+1)*(h/12)-4) && (mouseY < (k+1)*(h/12)+14)){
        mult[k] = mult[k]==3 ? 0 : 3;
      }
    }
  }
}



void poorSignalEvent(int sig) {
  println("pSignalEvent "+sig);
}

/*void poorSignalEvent(int sig) {
  println("pSignalEvent "+sig);
  // simulate new values 
  med_level = int(100 * noise(1, frameCount*0.01));
  att_level = int(100 * noise(2, frameCount*0.033));
  blink_level = int(random(100));
  newMed = true;
  newAtt = true;
  newBlink = random(10)<=1 ? true : false;
  delta_level = int(10000 * noise(1, frameCount*0.001));
  theta_level = int(10000 * noise(2, frameCount*0.0033));
  low_alpha_level = int(10000 * noise(3, frameCount*0.0047));
  high_alpha_level = int(10000 * noise(4, frameCount*0.0037));
  low_beta_level = int(10000 * noise(5, frameCount*0.0027));
  high_beta_level = int(10000 * noise(6, frameCount*0.0017));
  low_gamma_level = int(10000 * noise(7, frameCount*0.007));
  mid_gamma_level = int(10000 * noise(8, frameCount*0.007));
  updateChannels();
  sendChannels();
}*/


void attentionEvent(int attentionLevel) {
  att_level = attentionLevel;
  newAtt = true;
}

void meditationEvent(int meditationLevel) {
  med_level = meditationLevel;
  newMed = true;
}

void blinkEvent(int blinkStrength) {
  blink_level = blinkStrength;
  newBlink = true;
}


/*public void eegEvent(int delta_level, int theta_level, 
                    int low_alpha_level, int high_alpha_level, 
                    int low_beta_level, int high_beta_level, 
                    int low_gamma_level, int mid_gamma_level) {
}*/

public void eegEvent(int delta_level, int theta_level, 
                    int low_alpha_level, int high_alpha_level, 
                    int low_beta_level, int high_beta_level, 
                    int low_gamma_level, int mid_gamma_level) {
  updateChannels();
  sendChannels();
}



void rawEvent(int[] raw) {
  //println("rawEvent Level: " + raw);
}  

void stop() {
  neuroSocket.stop();
  super.stop();
}



void updateChannels(){
  // append
  int bLev = newBlink ? blink_level : 0;
  channels[0].addDataPoint(bLev);
  newBlink = false;
  int aLev = newAtt ? att_level : 0;
  channels[1].addDataPoint(aLev);
  newAtt = false;
  int mLev = newMed ? med_level : 0;
  channels[2].addDataPoint(mLev);
  newMed = false;
  channels[3].addDataPoint(delta_level);
  channels[4].addDataPoint(theta_level);
  channels[5].addDataPoint(low_alpha_level);
  channels[6].addDataPoint(high_alpha_level);
  channels[7].addDataPoint(low_beta_level);
  channels[8].addDataPoint(high_beta_level);
  channels[9].addDataPoint(low_gamma_level);
  channels[10].addDataPoint(mid_gamma_level);
  // and print
  print("[de]:" + delta_level,"\t");
  print("[th]:" + theta_level,"\t");
  print("[al]:" + low_alpha_level,"\t");
  print("[ah]:" + high_alpha_level,"\t");
  print("[bl]:" + low_beta_level,"\t");
  print("[bh]:" + high_beta_level,"\t");
  print("[gl]:" + low_gamma_level,"\t");
  print("[gm]:" + mid_gamma_level,"\t\t");
  print("[A]:" + aLev,"\t");
  print("[M]:" + mLev,"\t");
  println("[B]:" + bLev,"\t");
}


void sendChannels(){
  for (int k=0; k<11; k++){
    if (isSending[k]){
      OscMessage oscmsg = new OscMessage(channels[k].path);
      if (!isNorm[k]) oscmsg.add(int(channels[k].getLatestPoint().value / pow(10, mult[k])));
      else oscmsg.add(map(channels[k].getLatestPoint().value,channels[k].minValue, channels[k].maxValue, 0, 1)*pow(10, mult[k]));
      oscP5.send(oscmsg, theReceiver); 
    }
  }
}

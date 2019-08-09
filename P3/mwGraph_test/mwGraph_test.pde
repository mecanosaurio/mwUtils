/*
*mindGraph
*------------------
*catches eeg-wave signals from thinkgearConnector
* channel per signal
* displays in plot
* sendable osc 
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
Channel[] channels = new Channel[11];
int delta_level, theta_level, low_alpha_level, high_alpha_level, 
    low_beta_level, high_beta_level, low_gamma_level, mid_gamma_level;

PFont fontA;

void setup() {
  //-- other setups
  size(800, 600);
  w = width;
  h = height;
  frameRate(12);
  smooth();
  noFill();
  fontA = createFont("digit.ttf", 12);
  textFont(fontA);
  
  //-- osc
  oscP5 = new OscP5(this,12000);
  theReceiver = new NetAddress("192.168.1.160",8000);
  //-- Creat the channel objects
  channels[0] = new Channel("Signal Quality", color(0), "-");
  channels[1] = new Channel("Attention", color(100), "Attention");
  channels[2] = new Channel("Meditation", color(50), "Meditation");
  channels[3] = new Channel("Delta", color(219, 211, 42), "Dreamless Sleep");
  channels[4] = new Channel("Theta", color(245, 80, 71), "Drowsy");
  channels[5] = new Channel("Low Alpha", color(237, 0, 119), "Relaxed");
  channels[6] = new Channel("High Alpha", color(212, 0, 149), "Relaxed");
  channels[7] = new Channel("Low Beta", color(158, 18, 188), "Alert");
  channels[8] = new Channel("High Beta", color(116, 23, 190), "Alert");
  channels[9] = new Channel("Low Gamma", color(39, 25, 159), "---");
  channels[10] = new Channel("High Gamma", color(23, 26, 153), "---");
  delay(1000);
  
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
  /*mask*/
  stroke(0, 127);
  strokeWeight(4);
  line(50, h/2 + 100, w-50, h/2 + 100);
  strokeWeight(2);
  /*plot*/
  for (int k=3; k<10; k++){
    int buffSize = channels[k].points.size()<100 ? channels[k].points.size() : 100;
    int channSize = channels[k].points.size();
    float px=0, py=0;
    stroke(channels[k].drawColor);
    beginShape();
    for (int i=0; i<buffSize-1; i++){
      Point thisPoint = channels[k].points.get(channSize-1-i);
      px = (w-125) - i * (w-200)/100;
      py = (h/2 + 100) - map(thisPoint.value, channels[k].minValue, channels[k].maxValue, 0, 350);
      if (i==0) {
        ellipse(px, py, 5, 5);
        strokeWeight(1);
        line (px+3, py, px+13, py);
        strokeWeight(2);
        fill(channels[k].drawColor);
        text(nf(thisPoint.value), px+15, py+2);
        noFill();
      }
      curveVertex(px, py);
    }
    endShape();
  }
}






void poorSignalEvent(int sig) {
  println("pSignalEvent "+sig);
}
/*
void poorSignalEvent(int sig) {
  println("pSignalEvent "+sig);
  // simulate new values 
  delta_level = int(10000 * noise(1, frameCount*0.001));
  theta_level = int(10000 * noise(2, frameCount*0.0033));
  low_alpha_level = int(10000 * noise(3, frameCount*0.0047));
  high_alpha_level = int(10000 * noise(4, frameCount*0.0037));
  low_beta_level = int(10000 * noise(5, frameCount*0.0027));
  high_beta_level = int(10000 * noise(6, frameCount*0.0017));
  low_gamma_level = int(10000 * noise(7, frameCount*0.007));
  mid_gamma_level = int(10000 * noise(8, frameCount*0.007));
  print("[de]: " + delta_level,"\t");
  print("[th]: " + theta_level,"\t");
  print("[al]: " + low_alpha_level,"\t");
  print("[ah]: " + high_alpha_level,"\t");
  print("[bl]: " + low_beta_level,"\t");
  print("[bh]: " + high_beta_level,"\t");
  print("[gl]: " + low_gamma_level,"\t");
  println("[gm]: " + mid_gamma_level);
  // append those values 
  channels[3].addDataPoint(delta_level);
  channels[4].addDataPoint(theta_level);
  channels[5].addDataPoint(low_alpha_level);
  channels[6].addDataPoint(high_alpha_level);
  channels[7].addDataPoint(low_beta_level);
  channels[8].addDataPoint(high_beta_level);
  channels[9].addDataPoint(low_gamma_level);
  channels[10].addDataPoint(mid_gamma_level);
}
*/


public void attentionEvent(int attentionLevel) {
  OscMessage oscmsg = new OscMessage("/att");
  println("Attention Level: " + attentionLevel);
  attention = attentionLevel;
  oscmsg.add(attention);
  oscP5.send(oscmsg, theReceiver); 
}


void meditationEvent(int meditationLevel) {
  OscMessage oscmsg = new OscMessage("/med");
  println("Meditation Level: " + meditationLevel);
  meditation = meditationLevel;
  oscmsg.add(meditation);
  oscP5.send(oscmsg, theReceiver); 
}

void blinkEvent(int blinkStrength) {
  OscMessage oscmsg = new OscMessage("/blink");
  println("blinkStrength: " + blinkStrength);
  oscmsg.add(blinkStrength);
  oscP5.send(oscmsg, theReceiver); 

}


/*public void eegEvent(int deltaData, int thetaData,  
                    int lowAlphaData, int highAlphaData, 
                    int lowBetaData, int highBetaData, 
                    int lowGammaData, int midGammaData) {
  // dont only print but append
}*/
public void eegEvent(int delta_level, int theta_level, 
                    int low_alpha_level, int high_alpha_level, 
                    int low_beta_level, int high_beta_level, 
                    int low_gamma_level, int mid_gamma_level) {
  print("[de]: " + delta_level,"\t");
  print("[th]: " + theta_level,"\t");
  print("[al]: " + low_alpha_level,"\t");
  print("[ah]: " + high_alpha_level,"\t");
  print("[bl]: " + low_beta_level,"\t");
  print("[bh]: " + high_beta_level,"\t");
  print("[gl]: " + low_gamma_level,"\t");
  println("[gm]: " + mid_gamma_level);
  // append those values 
  channels[3].addDataPoint(delta_level);
  channels[4].addDataPoint(theta_level);
  channels[5].addDataPoint(low_alpha_level);
  channels[6].addDataPoint(high_alpha_level);
  channels[7].addDataPoint(low_beta_level);
  channels[8].addDataPoint(high_beta_level);
  channels[9].addDataPoint(low_gamma_level);
  channels[10].addDataPoint(mid_gamma_level);

}


void rawEvent(int[] raw) {
  //println("rawEvent Level: " + raw);
}  

void stop() {
  neuroSocket.stop();
  super.stop();
}

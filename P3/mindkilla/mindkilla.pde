/*
mindKiller para Moi
------------------
translate thinkgear json to osc
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

void setup() {
  size(100,100);
  ThinkGearSocket neuroSocket = new ThinkGearSocket(this);
  try {
    neuroSocket.start();
  }catch (Exception e) {
    println("Is ThinkGear running??");
  }
  smooth();
  noFill();
  strokeWeight(2);

  // osc
  oscP5 = new OscP5(this,12000);
  theReceiver = new NetAddress("192.168.0.160",8000);
}


void draw() {
  background(0);
}


void poorSignalEvent(int sig) {
  println("SignalEvent "+sig);
}


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
}


void rawEvent(int[] raw) {
  //println("rawEvent Level: " + raw);
}  

void stop() {
  neuroSocket.stop();
  super.stop();
}

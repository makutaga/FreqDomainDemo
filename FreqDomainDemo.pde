/** 時間領域，周波数領域説明用アプリケーション．
 *  Explanation of time domain and frequency domain
 */

import ddf.minim.*;
import ddf.minim.analysis.*;
import g4p_controls.*;

Minim minim;    
AudioInput in;

int nsamples = 256;
FloatList sig_t;
FloatList sig_x;
float [] sig_x_buf;
FFT fft;
float signalDuration = 1.0;
float sig_freq = 2.0;
float samp_f = nsamples / signalDuration;
FloatList spec_f;
float [] spec_f_buf;
FloatList spec_pow;

GraphBox graph_wave;
GraphBox graph_spec;

Plot plot_wave;
Plot plot_spec;

/**
	初期設定．
*/
void
setup() {
  size(900, 700);
  
  sig_t = new FloatList();
  sig_x = new FloatList();
  spec_f = new FloatList();
  spec_pow = new FloatList();
  createGUI();
  customGUI();
  
  graph_wave = new GraphBox(int(sp_wave.getX()), int(sp_wave.getY()),
      int(sp_wave.getWidth()), int(sp_wave.getHeight()));
  graph_wave.axis.setMargin(50, 10, 30, 30);
  graph_wave.axis.setRange(0.0, 0.0, nsamples, 200);
  graph_wave.axis.label_x = "time [s]";
  graph_wave.axis.label_y = "amplitude";
  plot_wave = new Plot(sig_t, sig_x);
  plot_wave.plot_line = true;
  plot_wave.plot_impulse = true;
  plot_wave.plot_marker = true;
  graph_wave.plots.add(plot_wave);
  
  graph_spec = new GraphBox(int(sp_spec.getX()), int(sp_spec.getY()),
      int(sp_spec.getWidth()), int(sp_spec.getHeight()));
  graph_spec.axis.setMargin(50, 10, 30, 30);
  graph_spec.axis.setRange(0.0, 0.0, nsamples, 200);
  graph_spec.axis.label_x = "frequency [Hz]";
  graph_spec.axis.label_y = "power^(1/2)";
  plot_spec = new Plot(spec_f, spec_pow);
  plot_spec.plot_line = true;
  plot_spec.plot_impulse = true;
  plot_spec.plot_marker = true;
  graph_spec.plots.add(plot_spec);
  
  setWave_sin();

}

//! Use this method to add additional statements
//! to customise the GUI controls
public void customGUI(){
  dl_nsamples.setSelected(3);  // 256 samples;
  tf_sigfreq.setText(String.valueOf(sig_freq));
}

/** 再描画関数．

 * 各GraphBoxのPGraphicインスタンスをコピーする．
 */
void
draw() {
  background(255);  
  sp_wave.setGraphic(graph_wave.pg);
  sp_spec.setGraphic(graph_spec.pg);
}

/** グラフの再描画．

 * GraphBoxにPGraphicにグラフを再描画する．
 * 画面に表示されるのは draw() 関数がコールされてから．
 */
void
updateGraph() {
  graph_wave.axis.setRange(0.0, sig_x.min() * 1.0, signalDuration, sig_x.max() * 1.0);
  graph_wave.update();
  
  calcSpectrum();
  
  graph_spec.axis.setRange(0.0, spec_pow.min(), spec_f.max(), spec_pow.max());
  graph_spec.update();
}

void mousePressed() {
  println("mousePressed(): " + mouseX + ", " + mouseY );
}

void setWave_sin() {
  sig_t.clear();
  sig_x.clear();
  for (int i = 0; i < nsamples; i ++) {
    sig_t.append(signalDuration / nsamples * i);
    sig_x.append(sin(2 * PI * sig_freq * sig_t.get(i)));
  }
  plot_wave.label = "sinusoidal wave";
  updateGraph();
}

void setWave_rectangle() {
  sig_t.clear();
  sig_x.clear();  
  for (int i = 0; i < nsamples; i ++) {
    sig_t.append(signalDuration / nsamples * i);
    sig_x.append(sig_t.get(i) * sig_freq % 1.0 > 0.5 ? -1.0 : 1.0);
  }
  plot_wave.label = "rectangular wave";
  updateGraph();
}

void calcSpectrum() {
  sig_x_buf = sig_x.array();
//  println("fs=", samp_f);
  fft = new FFT(sig_x_buf.length, samp_f);
  fft.forward(sig_x_buf);
  
//  println(fft.specSize());
  spec_f.clear();
  spec_pow.clear();
  for (int i = 0; i < fft.specSize(); i ++) {
    spec_f.append(fft.indexToFreq(i));
    spec_pow.append(fft.getBand(i));
//    println(spec_f.get(i), spec_pow.get(i));
  }
    
}

void setNSamples(int n) {
  nsamples = n;
  samp_f = nsamples / signalDuration;
  if (opt_rect.isSelected()) {
    setWave_rectangle();
  }
  else {
    setWave_sin();
  }
  
  updateGraph();
}

void setSignalFrequency(float f) {
  sig_freq = f;
   if (opt_rect.isSelected()) {
    setWave_rectangle();
  }
  else {
    setWave_sin();
  }
  updateGraph();

}

boolean isFloat(String str) {
  try {
    Float.parseFloat(str);
    return true;
  } catch (NumberFormatException e) {
    return false;
  }
}


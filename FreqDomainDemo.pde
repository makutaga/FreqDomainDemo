/** \mainpage
メインページ
時系列のFFTを用いた周波数解析について，触って理解できるアプリケーションの開発を目指します．

\section はじめに
なるべく多くのプラットフォームをサポートできる，すなわち実行形式のアプリケーションをなるべく多くのOS用に作成できるようにという見方から，
<a href="http://processing.org">Processing.org</a>を用いています．

またGUIの作成のために<a href="http://www.lagers.org.uk/g4p/">G4P</a>，周波数解析については<a href="http://code.compartmental.net/tools/minim/">minim</a> を利用しています．

*/

/** \file FreqDomainDemo.pde
 * @brief \~english Main file of application for explanation of time domain and frequency domain
          \~japanese 時間領域，周波数領域説明用アプリケーションのメインファイル
 */

import ddf.minim.*;
import ddf.minim.analysis.*;
import g4p_controls.*;

Minim minim;    
AudioInput in;

int nsamples = 256;		/**< 時系列のサンプル数 */
FloatList sig_t;		/**< 時系列の各サンプルの時間 */
FloatList sig_x;		/**< 時系列のサンプル値 */
FloatList isig_x;               /**< iFFTで再合成した時系列 */
float [] sig_x_buf;
FFT fft;
float signalDuration = 1.0;
float sig_freq = 2.0;
float samp_f = nsamples / signalDuration;
FloatList spec_f;
float [] spec_f_buf;
FloatList spec_pow;
float [] spec_re;
float [] spec_im;

GraphBox graph_wave;
GraphBox graph_spec;

Plot plot_wave;
Plot plot_iwave;
Plot plot_spec;

FloatList phase_re;
FloatList phase_im;
GraphBox graph_phase;
Plot plot_phase;

int mouse_pressed_x;
int mouse_pressed_y;

int selected_freq_idx;
float pre_re;
float pre_im;

/**
	\~english Initialization
	\~japanese 初期設定．
*/
void
setup() {
  size(900, 700);
  
  sig_t = new FloatList();
  sig_x = new FloatList();
  isig_x = new FloatList();
  spec_f = new FloatList();
  spec_pow = new FloatList();
  phase_re = new FloatList();
  phase_im = new FloatList();
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
  plot_iwave = new Plot(sig_t, isig_x);
  plot_iwave.plot_line = true;
  plot_iwave.plot_impulse = false;
  plot_iwave.plot_marker = true;
  plot_iwave.col_line = color(255, 255, 0);
  plot_iwave.col_marker = color(255, 255, 0);
  graph_wave.plots.add(plot_wave);
  graph_wave.plots.add(plot_iwave);
  
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
  
  graph_phase = new GraphBox(int(sp_phase.getX()), int(sp_phase.getY()),
    int(sp_phase.getWidth()), int(sp_phase.getHeight()));
  graph_phase.axis.setMargin(50, 10, 30, 30);
  graph_phase.axis.setRange(-1.0, -1.0, 1.0, 1.0);
  graph_phase.axis.label_x = "real part";
  graph_phase.axis.label_y = "imaginarly part";
  plot_phase = new Plot(phase_re, phase_im);
  plot_phase.plot_line = true;
  plot_phase.plot_impulse = false;
  plot_phase.plot_marker = true;
  graph_phase.plots.add(plot_phase);
  panel_phase.setVisible(false);

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
  graph_wave.axis.setRange(
    0.0,
    sig_x.min() > isig_x.min() ? isig_x.min() : sig_x.min(),
    signalDuration,
    sig_x.max() > isig_x.max() ? sig_x.max() : isig_x.max());
  graph_wave.update();
  
  
  graph_spec.axis.setRange(0.0, spec_pow.min(), spec_f.max(), spec_pow.max());
  graph_spec.update();
}

/** mousePressed イベントの処理．
 */
void mousePressed() {
  println("mousePressed(): " + mouseX + ", " + mouseY );
  mouse_pressed_x = mouseX;
  mouse_pressed_y = mouseY;
  if (graph_spec.isInside(mouseX, mouseY)) {
    selected_freq_idx = int(graph_spec.axis.vX(mouseX - graph_spec.box_x) / signalDuration + 0.5);
    pre_re = spec_re[selected_freq_idx];
    pre_im = spec_im[selected_freq_idx]; 
    println("mousePressed(): selected_freq_idx:", selected_freq_idx, pre_re, pre_im);
  }
  
}

/** mouseRelease イベントの処理
 */
void mouseReleased() {
  selected_freq_idx = -1;
}

/** mouseMoved イベントの処理
 */
void mouseMoved() {
  //println("mouseMoved():", mouseX, mouseY);
  if (graph_spec.isInside(mouseX, mouseY)) {
    int freq_index = int(graph_spec.axis.vX(mouseX - graph_spec.box_x) / signalDuration + 0.5);
    println(mouseX - graph_spec.box_x, graph_spec.axis.vX(mouseX - graph_spec.box_x), freq_index);
    
    panel_phase.setVisible(true);
    float panel_x = mouseX - panel_phase.getWidth() / 2;
    float panel_y = graph_spec.box_y - panel_phase.getHeight();
    if (panel_x < 0.0) {
      panel_x = 0.0;
    }
    else if (panel_x > width - panel_phase.getWidth()) {
      panel_x = width - panel_phase.getWidth();
    }
    panel_phase.moveTo(panel_x, panel_y);
    drawPhaseView(freq_index / signalDuration, freq_index);
  }
  else {
    panel_phase.setVisible(false);
  }
}

/** mouseDragged イベントの処理
 */
void
mouseDragged() {
  int dx = mouseX - mouse_pressed_x;
  int dy = mouseY - mouse_pressed_y;
  
  println("mouseDragged(): ", dx, dy);
  if (selected_freq_idx >= 0) {
    float new_amp = sqrt(pre_re * pre_re + pre_im * pre_im) - dy / graph_spec.axis.ppv_y;
    float new_phase = atan2(pre_im, pre_re) + dx * PI / 180.0;
    if (new_amp < 0.0) {
      new_amp = 0.0;
    }
    spec_re[selected_freq_idx] = new_amp * cos(new_phase);
    spec_im[selected_freq_idx] = new_amp * sin(new_phase);
    spec_re[spec_im.length - selected_freq_idx] = spec_re[selected_freq_idx];
    spec_im[spec_im.length - selected_freq_idx] = -spec_im[selected_freq_idx];
    println("mouseDragged: dx,dy:", dx, dy, new_amp, new_phase);
    drawPhaseView(0.0, selected_freq_idx);
    calcInvFourier();
    updateGraph();
  }
}

/** 位相グラフの描画
 */
void drawPhaseView(float f, int fidx) {
  graph_phase.axis.setRange(-spec_pow.max(), -spec_pow.max(), spec_pow.max(), spec_pow.max());
  phase_re.clear();
  phase_im.clear();
  phase_re.append(0.0);
  phase_im.append(0.0);
  phase_re.append(spec_re[fidx]);
  phase_im.append(spec_im[fidx]);
//  println("drawPhaseView: ", spec_re[fidx], spec_im[fidx]);
  graph_phase.update();
  sp_phase.setGraphic(graph_phase.pg);
}

/** 正弦波の時系列の作成

 時刻リスト ::sig_t と サンプル値リスト ::sig_x を計算し， updateGraph() が呼ばれる．
 */
void setWave_sin() {
  sig_t.clear();
  sig_x.clear();
  isig_x.clear();
  for (int i = 0; i < nsamples; i ++) {
    sig_t.append(signalDuration / nsamples * i);
    sig_x.append(sin(2 * PI * sig_freq * sig_t.get(i)));
    isig_x.append(0.0);
  }
  plot_wave.label = "sinusoidal wave";
  calcSpectrum();
  calcInvFourier();
  updateGraph();
}

/** 矩形波の時系列の作成

 時刻リスト ::sig_t と サンプル値リスト ::sig_x を計算し， updateGraph() が呼ばれる．
 */
void setWave_rectangle() {
  sig_t.clear();
  sig_x.clear(); 
  isig_x.clear(); 
  for (int i = 0; i < nsamples; i ++) {
    sig_t.append(signalDuration / nsamples * i);
    sig_x.append(sig_t.get(i) * sig_freq % 1.0 >= 0.5 ? -1.0 : 1.0);
    isig_x.append(0.0);
  }
  plot_wave.label = "rectangular wave";
  calcSpectrum();
  calcInvFourier();
  updateGraph();
}

/** スペクトラムの計算

 FFTによって時系列のスペクトラムを計算し，周波数のリスト ::spec_f ，パワのリスト ::spec_pow を求める．
 */
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
  spec_re = fft.getSpectrumReal();
  spec_im = fft.getSpectrumImaginary();
//  println("spec_re.length: ", spec_re.length);
}

/** 逆フーリエ変換
 */
void calcInvFourier() {
  spec_pow.clear();
  for (int i = 0; i < fft.specSize(); i ++) {
    spec_pow.append(sqrt(spec_re[i] * spec_re[i] + spec_im[i] * spec_im[i]));
  }
  float [] x_update = new float[nsamples];
  fft.inverse(spec_re, spec_im, x_update);
  for (int i = 0; i < nsamples; i ++) {
    isig_x.set(i, x_update[i]);
  }
}


/** サンプル数の設定

 時系列のサンプル数を設定し，時系列を再計算する．
 updateGraph() でグラフイメージを再描画する．

 \param n 時系列のサンプル数．
 */
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

/** 信号の周波数の設定

 時系列信号の周波数を設定し，時系列を再計算する．
 updateGraph() でグラフイメージを再描画する．

 \param f 周波数 [Hz]
 */
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

/** \a str が数値を表す文字列かどうかを判定．

 \c Float.parseFloat() を用いて判定する．

 \param str テストする文字列
 \return 数値を表す文字列であれば \c true ，そうでなければ \c false .
 */
boolean isFloat(String str) {
  try {
    Float.parseFloat(str);
    return true;
  } catch (NumberFormatException e) {
    return false;
  }
}


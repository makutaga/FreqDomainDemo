//! Axis class
/*!
  Maintain all about the AXIS
  */
  
class Axis {
  int area_width;    /**< グラフエリアの幅 [pixel]*/
  int area_height;   /**< グラフエリアの高さ [pixel] */
  int margin_l;      /**< グラフエリア内部のグラフまでの左側のマージン */
  int margin_t;      /**< グラフエリア内部のグラフまでの上側のマージン */
  int margin_r;      /**< グラフエリア内部のグラフまでの右側のマージン */
  int margin_b;      /**< グラフエリア内部のグラフまでの下側のマージン */
  color col_bg;      /**< 背景色 */
  color col_axis;    /**< 軸の色 */
  color col_tick;    /**< 目盛の色 */  
  float ofst_x;      /**< 横軸（x軸）オフセット．すなわち最小値．[value]*/
  float ofst_y;      /**< 縦軸（y軸）オフセット．すなわち最小値．[value]*/
  float ppv_x;       /**< 横軸（x軸）の縮尺．[pixel / value] */
  float ppv_y;       /**< 縦軸（y軸）の縮尺．[pixel / value] */
  float max_x;       /**< 横軸（x軸）の最大値．  [value] */
  float max_y;       /**< 縦軸（y軸）の最大値．  [value] */
  
  float prefered_tick_step;  /**< 目盛の推奨間隔 [pixel] */
  
  String label_x;    /**< 横軸ラベル */
  String label_y;    /**< 縦軸ラベル */
  
  Axis(int w, int h) {
    prefered_tick_step = 60;
    area_width = w;
    area_height = h;
    col_bg = color(0);
    col_axis = color(0, 255, 0);
    col_tick = color(0, 128, 0);
    int default_margin = 10;
    ofst_x = 0.0;
    ofst_y = 0.0;
    max_x = w - default_margin * 2;
    max_y = h - default_margin * 2;
    setMargin(default_margin, default_margin, default_margin, default_margin); 
    
    label_x = "x";
    label_y = "y";
  }
  void setMargin(int l, int t, int r, int b) {
    margin_l = l;
    margin_t = t;
    margin_r = r;
    margin_b = b;
    setRange(ofst_x, ofst_y, max_x, max_y);
  }
  void setRange(float x0, float y0, float x1, float y1) {
    ofst_x = x0;
    ofst_y = y0;
    ppv_x = (area_width - margin_l - margin_r) / (x1 - x0);
    ppv_y = (area_height - margin_t - margin_b) / (y1 - y0);
    max_x = x1;
    max_y = y1;
    //println("setRange()", ofst_x, ofst_y, ppv_x, ppv_y, max_x, max_y);
  }
  float pX(float x) {
    return (x - ofst_x) * ppv_x + margin_l;
  }
  float pY(float y) {
    return -(y - ofst_y) * ppv_y + area_height - margin_b; 
  }
  float vX(float px) {
    return (px - margin_l) / ppv_x + ofst_x; 
  }
  float vY(float py) {
    return (area_height - margin_b - py) / ppv_y + ofst_y; 
  }
  void update(PGraphics pg) {
    pg.background(col_bg);
    pg.stroke(col_axis);
    
    // draw axis
    drawZeroAxis(pg);
    drawTicks(pg);

  }
  void drawZeroAxis(PGraphics pg) {
    pg.stroke(col_axis);
    if (ofst_x * max_x <= 0.0) {
      pg.line(pX(0.0), margin_t, pX(0.0), area_height - margin_b); 
    }
    if (ofst_y * max_y <= 0.0) {
      pg.line(margin_l, pY(0.0), area_width - margin_r, pY(0.0));
    }
    
    pg.textAlign(CENTER, BOTTOM);
    pg.text(label_x, area_width / 2, area_height);
    pg.pushMatrix();
    pg.textAlign(CENTER, TOP);
    pg.translate(0, area_height / 2);
    pg.rotate(-PI / 2);
    pg.text(label_y, 0, 0);
    pg.popMatrix();
  }
  void drawTicks(PGraphics pg) {
    pg.stroke(col_tick);
    float tick_st_x = calcTickStep(max_x - ofst_x, area_width - margin_l - margin_r, prefered_tick_step); 
    float tick_st_y = calcTickStep(max_y - ofst_y, area_height - margin_t - margin_b, prefered_tick_step); 

    int tick_ix_min = ceil(vX(margin_l) / tick_st_x) ;
    int tick_ix_max = floor(vX(area_width - margin_r) / tick_st_x);
    int i;
    for (i = tick_ix_min; i <= tick_ix_max; i ++) {
      pg.line(pX(i * tick_st_x), margin_t, pX(i * tick_st_x), area_height - margin_b);
    }
    
    int tick_iy_min = ceil(vY(area_height - margin_b) / tick_st_y);
    int tick_iy_max = ceil(vY(margin_t) / tick_st_y);
    for (i = tick_iy_min; i <= tick_iy_max; i ++) {
      pg.line(margin_l, pY(i * tick_st_y), area_width - margin_r, pY(i * tick_st_y));
    }
    
    // tick label
    String fmt;
    pg.textAlign(CENTER, TOP);
    fmt = getTickFormat(tick_st_x);
    for (i = tick_ix_min; i <= tick_ix_max; i ++) {
      String s = String.format(fmt, i * tick_st_x);
      pg.text(s, pX(i * tick_st_x), area_height - margin_b);
    }
    
    pg.textAlign(RIGHT, BASELINE);
    fmt = getTickFormat(tick_st_y);
    for (i = tick_iy_min; i <= tick_iy_max; i ++) {
      String s = String.format(fmt, i * tick_st_y);
      pg.text(s, margin_l, pY(i * tick_st_y));
    }
  }
  
  float calcTickStep(float range_val, float range_pix, float prefered_pix) {
    float ppv = range_pix / range_val;
    float log_grid_step_val_0 = log(range_val * prefered_pix / range_pix) / log(10);
    float frac = floor(log_grid_step_val_0);
    float expo = pow(10.0, log_grid_step_val_0 - frac);
    float expo_new;
    if (expo < 1.5) {
      expo_new = 1;
    } else if (expo < 3.2) {
      expo_new = 2;
    } else if (expo < 7.5) {
      expo_new = 5;
    } else {
      expo_new = 10;
    }
    float grid_step_val = expo_new * pow(10.0, frac);
    return grid_step_val;    
  }
  
  String getTickFormat(float tick_step) {
    float ex = log(tick_step) / log(10);
    String fmt;
    if (ex >= 0.0) {
      fmt = new String("%.0f");
    }
    else {
      fmt = String.format("%%.%df", int(ceil(-ex)));
    }
    println(tick_step, ex, fmt);
    return fmt;
  }
  
}



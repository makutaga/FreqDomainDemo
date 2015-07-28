class Plot extends AbstractPlot {
  FloatList valx;
  FloatList valy;
  boolean plot_line;
  boolean plot_impulse;
  boolean plot_marker;
  int marker_size;
  color col_marker;
  
  Plot(FloatList x, FloatList y) {
    label = "line graph";
    println("LineGraph()");
    valx = x;
    valy = y;
    col_line = color(0, 255, 255);
    plot_line = true;
    plot_impulse = false;
    plot_marker = false;
    marker_size = 4;
    col_marker = col_line;
  }
  void update(PGraphics pg, Axis axis) {
    println("LineGraph::update(): " + label);
    
    if (plot_line) {
      draw_line(pg, axis);
    }
    if (plot_impulse) {
      draw_impulse(pg, axis);
    }
    if (plot_marker) {
      draw_marker(pg, axis);
    }
  }
  
  void draw_line(PGraphics pg, Axis axis) {
    pg.stroke(col_line);
    pg.noFill();
    pg.beginShape();
    for (int i = 0; i < valx.size(); i ++) {
      pg.vertex(axis.pX(valx.get(i)), axis.pY(valy.get(i)));
    }
    pg.endShape();
  }
  
  void draw_impulse(PGraphics pg, Axis axis) {
    pg.stroke(col_line);
    pg.noFill();
    float impulse_base;
    if (axis.ofst_y * axis.max_y <= 0.0) {
      impulse_base = axis.pY(0.0);
    }
    else if (axis.ofst_y > 0.0) {
      impulse_base = axis.pY(axis.ofst_y);
    }
    else {
      impulse_base = axis.pY(axis.max_y);
    }
    for (int i = 0; i < valx.size(); i++) {
      float px = axis.pX(valx.get(i));
      pg.line(px, impulse_base, px, axis.pY(valy.get(i)));
    }
  }
  
  void draw_marker(PGraphics pg, Axis axis) {
    pg.stroke(col_marker);
    pg.noFill();
    for (int i = 0; i < valx.size(); i++) {
      pg.ellipse(axis.pX(valx.get(i)), axis.pY(valy.get(i)), marker_size, marker_size);
    }
    
    
  }
}

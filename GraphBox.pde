/*! GraphBox class．グラフボックスクラス．
 *
 * GraphBox class
 */
class GraphBox {
  Axis axis;  
  ArrayList<AbstractPlot> plots;
  PGraphics pg;
  
  GraphBox(int x, int y, int w, int h) {
    
    axis = new Axis(w, h);
    plots = new ArrayList<AbstractPlot>();
    pg = createGraphics(w, h);
  }
  
  void update() {
    println("GraphBox::update()");
    
    pg.beginDraw();
    axis.update(pg);
    for (int g = 0; g < plots.size(); g ++) {
      plots.get(g).update(pg, axis);
    }
    pg.endDraw();
  }
}

class AbstractPlot {
  String label = "abstract graph";
  color col_line;
  color col_fill;
  AbstractPlot() {
    col_line = color(0, 255, 255);
    col_fill = color(0, 128, 128);
  }
  void update(PGraphics pg, Axis axis) {
    println("AbstractGraph::update(): " + label);
  }
}


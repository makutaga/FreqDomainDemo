/*! GraphBox class．グラフボックスクラス．
 
 GraphBox は1組の軸Axisと複数のプロットPlotを内包するコンテナを提供する．
 G4P GSketchPad 上に描画することとを想定しており，PGraphics オブジェクトの
 GraphBox::pg にグラフのイメージが描画される．

 サンプル
 \code
FloatList valx;
FloatList valy;
Plot plot;
GraphBox graph;

// G4P GUI component. Usually, following part is described in gui.pde, generated by the GUI Builder
GSketchPad sp;	// GSketchPad for a graph

// Initialization
void setup() {
	size(800, 500);

	// Below line is described in CreateGUI() in gui.pde when the GUI designed by the GUI Builder.
	sp = new GSketchPad(this, 10, 10, 780, 480);

	valx = new FloatList();
	valy = new FloatList();
	plot = new Plot(valx, valy);

	graph = new GraphBox(int(sp.getX()), int(sp.getY()), int(sp.getWidth()), int(sp.getHeight()));
	graph.axis.setMargin(50, 10, 30, 30);
	graph.axis.setRange(0.0, -1.0, 10.0, 1.0);
	graph.axis.label_x = "time [s]";
	graph.axis.label_y = "amplitude";
	graph.plots.add(plot);
}

// draw event
void draw() {
	valx.clear();
	valy.clear();
	for (int i = 0 i < 100; i ++) {
		valx.append(i * 0.1);
		valy.append(sin(2 * PI * valx.get(i)));
	}
	graph.update();
	sp.setGraphic(graph.pg);
}

 \endcode
 
 */
class GraphBox {
  Axis axis;  	///< 軸
  ArrayList<AbstractPlot> plots;	///< プロットのリスト
  PGraphics pg;	///< グラフのイメージ
  int box_x;	///< グラフボックスのx座標
  int box_y;	///< グラフボックスのy座標
  
  /**
   コンストラクタ．

   \param x GraphBox のx座標
   \param y GraphBox のy座標
   \param w GraphBox の幅
   \param h GraphBox の高さ
  */
  GraphBox(int x, int y, int w, int h) {
    box_x = x;
    box_y = y;
    axis = new Axis(w, h);
    plots = new ArrayList<AbstractPlot>();
    pg = createGraphics(w, h);
  }
  
  /**
   グラフイメージの再描画．

   Axis と Plot が GraphBox::pg に再描画される．
  */
  void update() {
    println("GraphBox::update()");
    
    pg.beginDraw();
    axis.update(pg);
    for (int g = 0; g < plots.size(); g ++) {
      plots.get(g).update(pg, axis);
    }
    pg.endDraw();
  }
  
  /**
  ウィンドウ座標がGraphBoxの内部かどうかの判定．

  \param px x座標．
  \param px y座標．
  \return 内部であれば\c true ，外部であれば \c false
  */
  boolean isInside(int px, int py) {
    return axis.isInside(px - box_x, py - box_y);
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


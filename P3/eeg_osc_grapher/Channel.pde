class Channel { 

  String name;
  int drawColor;
  String description;
  String path;
  boolean graphMe;
  boolean relative;
  int maxValue;
  int minValue;
  ArrayList<Point> points;
  boolean allowGlobal;
    


  Channel(String _name, int _drawColor, String _description, String _path) {
    name = _name;
    drawColor = _drawColor;
    description = _description;
    path = _path;
    allowGlobal = true;
    points = new ArrayList();
    points.clear();
    minValue = 10000;
    maxValue = 10;
  }
  
  
  void addDataPoint(int value) {
    
    long time = System.currentTimeMillis();
    
    if(value > maxValue) maxValue = value;
    if(value < minValue) minValue = value;
    
    points.add(new Point(time, value));
    
    // tk max length handling
  }
  
  Point getLatestPoint() {
    if(points.size() > 0) {
      return (Point)points.get(points.size() - 1);
    }
    else {
      return new Point(0, 0);
    }
  }


}

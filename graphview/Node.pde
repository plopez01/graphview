class Node {
  Long id;
  PVector pos;
  PVector speed = new PVector(0, 0);
  PVector acel = new PVector(0, 0);

  float extent;
  
  color c;
  
  Node(Long id, PVector pos, float extent, color c) {
    this.id = id;
    this.pos = pos;
    this.extent = extent;
    this.c = c;
  }

  void draw() {
    fill(c);
    stroke(0);
    circle(pos.x, pos.y, extent);
    fill(0);
    text(str(int(id)), pos.x - textWidth(str(int(id)))/2, pos.y + textAscent()/2.0);

    pos.add(speed).add(PVector.div(acel, 2));
    speed.add(acel);
    speed.mult(1-FIELD_FRICTION);
  }
}

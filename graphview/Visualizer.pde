class Visualizer {
  SimilarityProfile profile;
  List<Node> nodes = new ArrayList<>();
  Map<Long, Node> nodeMap = new HashMap<>();

  PVector pos;
  float scale;



  Visualizer(SimilarityProfile profile, float x, float y, float scale) {
    this.profile = profile;
    pos = new PVector(x, y);
    this.scale = scale;

    PVector nextPos = new PVector(x, y);
    for (long id : profile.ids()) {
      while (isInCollision(nextPos)) {
        float heading = random(0, 2*PI);
        PVector posDiff = new PVector(cos(heading), sin(heading));
        posDiff.mult(scale);
        nextPos = PVector.add(nextPos, posDiff);
      }

      Node node = new Node(id, nextPos, scale/2.0, color(255));
      nodes.add(node);
      nodeMap.put(id, node);
    }
  }

  void draw() {
    // Edge logic
    for (Node node : nodes) {
      node.acel.set(0, 0);
    }
    
    for (Node node1 : nodes) {
      for (Node node2 : nodes) {
        if (node1 == node2) continue;

        // Edge actual distance
        float dist = PVector.dist(node2.pos, node1.pos);
        if (dist == 0) continue;

        float relation = profile.get(node1.id, node2.id);
        // Edge rest distance
        float restDist = (1-relation)*200 + scale/2.0;

        float edgeDist = dist - restDist;

        // Edge dir unitary vector
        PVector dir = PVector.div(PVector.sub(node1.pos, node2.pos), dist);

        // Apply acceleration
        float acelMagnitude = FIELD_CONSTANT * edgeDist * relation;


        node2.acel.add(PVector.mult(dir, acelMagnitude));
        node1.acel.add(PVector.mult(dir, -acelMagnitude));



        stroke(0, 255*relation);
        line(node1.pos.x, node1.pos.y, node2.pos.x, node2.pos.y);
      }
    }
    // Draw Nodes
    for (Node node : nodes) {
      node.draw();
    }
  }

  Node getNode(PVector pos) {
    for (int i = nodes.size()-1; i >= 0 ; i--) {
      Node node = nodes.get(i);
      if (node.pos.dist(pos) <= node.extent/2) return node;
    }
    return null;
  }

  boolean isInCollision(PVector pos) {
    return getNode(pos) != null;
  }
}

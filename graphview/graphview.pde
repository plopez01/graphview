final int N_PRODUCTS = 5;
final float FIELD_CONSTANT = 0.005;
final float FIELD_FRICTION = 0.3;

SimilarityProfile profile = new SimilarityProfile();
Visualizer v;

List<Long> solution;

void setup() {
  //fullScreen(1);
  size(640, 480);
  generateNewCase();
  //profile.set(0, N_PRODUCTS-1, 0.9);
  v = new Visualizer(profile, width/2.0, height/2.0, 80);
}

void draw() {
  background(255);
  profile.draw(0, height-20*N_PRODUCTS, 20);

  v.draw();

  // Draw solution, improve
  for (int i = 0; i < N_PRODUCTS; i++) {
    Node n1 = v.nodeMap.get(solution.get(i % N_PRODUCTS));
    Node n2 = v.nodeMap.get(solution.get((i+1) % N_PRODUCTS));

    stroke(255, 0, 0);
    line(n1.pos.x, n1.pos.y, n2.pos.x, n2.pos.y);
  }

  text(int(frameRate), 0, textAscent());

  if (draggedNode != null) {
    draggedNode.pos = new PVector(mouseX, mouseY);
  }
}

void generateNewCase() {
  println("Generating new case");
  for (int y = 0; y < N_PRODUCTS; y++) {
    for (int x = 0; x < y; x++) {
      if (x == y) continue;
      profile.set(x, y, random(1)); // y - 1 == x ? 0.9 : 0
    }
  }

  dumpSimilarities();
  
  List<Long> initial = new ArrayList<>();

  for (int i = 0; i < N_PRODUCTS; i++) {
    initial.add(i, (long)i);
  }

  TwoOpt twoOpt = new TwoOpt(initial);
  solution = twoOpt.generate(profile);
  
  for (Long id : solution) {
    print(id + "L, ");
  }
  println(); 
}

void dumpSimilarities() {
  for (int y = 0; y < N_PRODUCTS; y++) {
    print("{");
    for (int x = 0; x < N_PRODUCTS; x++) {
      
      print(profile.get(x, y) + "f, "); // y - 1 == x ? 0.9 : 0
    }
    println(y < N_PRODUCTS-1 ? "}," : "}");
  }
}

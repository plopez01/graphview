Node draggedNode;

void mousePressed(){
  draggedNode = v.getNode(new PVector(mouseX, mouseY));
}

void mouseReleased(){
  draggedNode = null;
}

void keyPressed(){
  if (key == ' '){
    generateNewCase();
  }
}

import java.util.List;

public class TwoOpt {

  List<Long> path;

  SimilarityProfile distances;

  public TwoOpt(List<Long> path) {
    this.path = path;
  }

  public List<Long> generate(SimilarityProfile distances) {
    this.distances = distances;
    // Generate approximate solution with the Kruskal algorithm
    float currentLength = pathLength(distances, path);

    int n = path.size();
    boolean improved = true;
    while (improved) {

      improved = false;
      for (int i = 0; i < n - 1; i++) {
        for (int j = i + 2; j < n; j++) {

          float lengthDelta = dist(i, j) + dist(i+1, (j+1) % n) - (dist(i, i+1) + dist(j, (j+1) % n));
          // dist(i, j) + dist(i+1, (j+1) % n) - (dist(i, i+1) + dist(j, (j+1) % n));
          //-dist(i, i+1) - dist(j, (j+1)%n) + dist(i, j) + dist(i+1, (j+1)%n);
          //println(lengthDelta);

          if (lengthDelta < 0) {
            // swap edges
            swapEdges(path, i, j);
            currentLength += lengthDelta;
            improved = true;
          }
        }
      }
    }

    return path;
  }

  float dist(int i, int j) {
    return -distances.get(path.get(i), path.get(j));
  }

  void swapEdges(List<Long> path, int i, int j) {
    i += 1;
    while (i < j) {
      Long temp = path.get(i);
      path.set(i, path.get(j));
      path.set(j, temp);
      i++;
      j--;
    }
  }

  float pathLength(SimilarityProfile distances, List<Long> path) {
    int n = path.size();
    float length = distances.get(path.get(0), path.get(path.size()-1));

    for (int i = 0; i < n - 1; i++) {
      length += distances.get(path.get(i), path.get(i + 1));
    }

    return length;
  }
}

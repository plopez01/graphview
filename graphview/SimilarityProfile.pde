import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Holds a profile with all the similarities between different products, or more specifically their identifiers,
 * and allows to get and manipulate them, as well as checking if the profile is {@link #isCompleteFor(Collection) complete}.
 *
 * @author Alejandro Trillo
 */
public class SimilarityProfile {
  private final Map<Long, Map<Long, Float>> similarities = new HashMap<>(); // Map<Prod1, Map<Prod2, Similarity>>


  public void draw(float xpos, float ypos, float size) {
    noFill();
    stroke(0);
    square(xpos, ypos, N_PRODUCTS*size);
    for (int y = 0; y < N_PRODUCTS; y++) {
      for (int x = 0; x < N_PRODUCTS; x++) {
        if (x < y) continue;
        float similarity = profile.get(x, y);
        fill(255*(1-similarity));
        square(xpos + x*size, ypos + y*size, size);

        fill(0);
        text(x, xpos + x*size + size/2 - textWidth(str(x))/2, ypos - 5);
      }
      text(y, xpos + N_PRODUCTS*size + 5, ypos + y*size + size/2 + textAscent()/2);
    }
  }

  /**
   * Sets the similarity between p1 and p2 to the given similarity.
   * If either of the products aren't in the profile, they are added.
   * @param p1 The first product
   * @param p2 The second product
   * @param similarity The similarity to set
   * @throws IllegalArgumentException If p1 == p2, or if similarity isn't in [0, 1]
   */
  public void set(long p1, long p2, float similarity) {
    if (p1 == p2) throw new IllegalArgumentException("Cannot add a similarity to the same product");
    if (constrain(similarity, 0.0f, 1.0f) != similarity) throw new IllegalArgumentException("Similarity should be between 0 and 1");

    mapFor(p1).put(p2, similarity);
    mapFor(p2).put(p1, similarity);
  }

  /**
   * Gets the similarity between two products
   *
   * @param p1 The first product
   * @param p2 The seconds product
   * @return The similarity between p1 and p2, or 1 if p1 and p2 are equal
   * @throws IllegalArgumentException If either p1 or p2 aren't in the profile, of if p1 is not related to p2
   */
  public float get(long p1, long p2) {
    var p1Sims = similarities.get(p1);
    if (p1Sims == null) {
      throw new IllegalArgumentException("p1 is not in the profile");
    }
    if (p1 == p2) return 1;

    Float sim = p1Sims.get(p2);
    if (sim == null) {
      throw new IllegalArgumentException("p2 is not in the profile or not related to p1");
    }
    assert sim.floatValue() == similarities.get(p2).get(p1) :
    "must be symmetric";
    return sim;
  }

  /**
   * Removes the given product from the profile
   * @param p The product to remove
   */
  public void remove(long p) {
    similarities.remove(p);
    for (var it = similarities.values().iterator(); it.hasNext(); ) {
      var map = it.next();
      map.remove(p);
      if (map.isEmpty()) {
        it.remove();
      }
    }
  }

  /**
   * Removes the similarities for all identifiers that aren't in the given collection from this profile.
   * @param ids The ids to keep
   */
  public void retainOnly(Collection<Long> ids) {
    if (!(ids instanceof Set<?>))
      ids = new HashSet<>(ids); // removeAll can be n^2 if not a set, so quick copy

    var toRemove = new ArrayList<Long>(similarities.keySet());
    toRemove.removeAll(ids);
    for (long id : toRemove) {
      remove(id);
    }
  }

  /**
   * Returns whether this profile has similarities between all identifiers in the given collection.<p>
   *
   * This profile containing identifiers not in the given collection is considered an error, and will throw an
   * {@link IllegalStateException}.
   *
   * @param ids
   * @return true if this profile is full
   * @throws IllegalStateException if the profile has ids that aren't in the given collection
   */
  public boolean isCompleteFor(Collection<Long> ids) {
    if (!(ids instanceof Set<?>)) {
      // containsAll can be n^2 if not a Set, so let's pay one quick copy
      ids = new HashSet<>(ids);
    }
    if (!ids.containsAll(similarities.keySet())) {
      throw new IllegalStateException("Profile has ids not requested (stale?)");
    }
    if (ids.size() != similarities.size() || !similarities.keySet().containsAll(ids)) {
      return false;
    }
    // we've now already checked we only have the given ids stored, so a size check suffices
    for (var map : similarities.values()) {
      if (map.size() != ids.size() - 1) return false;
    }
    return true;
  }

  /**
   * Returns a map of the similarities of the given product to other products in this profile.<p>
   *
   * The returned map is disconnected from any changes to this {@link SimilarityProfile}.
   *
   * @param product The product to get similarities of
   * @return a map of similarities from the given product to others in this profile
   */
  public Map<Long, Float> similaritiesFor(long product) {
    var map = similarities.get(product);
    if (map == null) {
      return new HashMap<>();
    } else {
      // defensive copy
      return new HashMap<>(map);
    }
  }

  /**
   * {@return an array of ids present in this profile}
   */
  public long[] ids() {
    long[] ret = new long[similarities.size()];
    int i = 0;
    for (long id : similarities.keySet()) {
      ret[i] = id;
      i++;
    }
    return ret;
  }

  private Map<Long, Float> mapFor(long p1) {
    return similarities.computeIfAbsent(p1, __ -> new HashMap<>());
  }
}

/// Element-wise equality, for entities that hold lists.
bool listasIguales<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Entry-wise equality, for entities that hold maps.
bool mapasIguales<K, V>(Map<K, V> a, Map<K, V> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (final MapEntry(:key, :value) in a.entries) {
    if (!b.containsKey(key) || b[key] != value) return false;
  }
  return true;
}

/// Order-independent hash of a map, matching [mapasIguales].
int hashDeMapa<K, V>(Map<K, V> mapa) => Object.hashAllUnordered([
  for (final MapEntry(:key, :value) in mapa.entries) Object.hash(key, value),
]);

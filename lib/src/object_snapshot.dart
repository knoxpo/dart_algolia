part of algolia;

class AlgoliaObjectSnapshot {
  Algolia algolia;
  String objectID;
  String index;
  Map<String, Map<String, dynamic>> highlightResult;
  Map<String, dynamic> data;

  AlgoliaObjectReference get ref =>
      AlgoliaObjectReference._(algolia, index, objectID);

  // AlgoliaObjectSnapshot.fromMap(Map<String, dynamic> map) {
  AlgoliaObjectSnapshot.fromMap(algolia, index, Map<String, dynamic> map) {
    algolia = algolia;
    index = index;
    objectID = map['objectID'];
    Map<String, dynamic> newMapHighlightResult = map['_highlightResult'] != null
        ? Map<String, Map<String, dynamic>>.from(map['_highlightResult'])
        : null;
    highlightResult = newMapHighlightResult;
    // Map<String, dynamic> m = map;
    map.remove('objectID');
    map.remove('_highlightResult');
    data = map;
  }
}

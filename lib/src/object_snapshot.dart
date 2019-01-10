part of algolia;

class AlgoliaObjectSnapshot {
  Algolia algolia;
  String objectID;
  String index;
  Map<String, dynamic> highlightResult;
  Map<String, dynamic> snippetResult;
  Map<String, dynamic> data;

  AlgoliaObjectReference get ref =>
      AlgoliaObjectReference._(algolia, index, objectID);

  // AlgoliaObjectSnapshot.fromMap(Map<String, dynamic> map) {
  AlgoliaObjectSnapshot.fromMap(algolia, index, Map<String, dynamic> map) {
    algolia = algolia;
    index = index;
    objectID = map['objectID'];
    highlightResult = map['_highlightResult'];
    snippetResult = map['_snippetResult'];
    // Map<String, dynamic> m = map;
    map.remove('objectID');
    map.remove('_highlightResult');
    map.remove('_snippetResult');
    data = map;
  }
}

part of algolia;

// Implementation & bug solved by https://github.com/franvera
// - highlightResult [Bug] (commit ref: 0d76d24fe8aa347a0933920afe5ded43bdcbd68b)
// - snippetResult [Implementation] (commit ref: 0d76d24fe8aa347a0933920afe5ded43bdcbd68b)

class AlgoliaObjectSnapshot {
  Algolia algolia;
  String objectID;
  String index;
  Map<String, dynamic> highlightResult;
  Map<String, dynamic> snippetResult;
  Map<String, dynamic> data;

  AlgoliaObjectReference get ref =>
      AlgoliaObjectReference._(algolia, index, objectID);

  AlgoliaObjectSnapshot.fromMap(algolia, index, Map<String, dynamic> map) {
    algolia = algolia;
    index = index;
    objectID = map['objectID'];

    highlightResult = map['_highlightResult'];
    snippetResult = map['_snippetResult'];

    map.remove('objectID');
    map.remove('_highlightResult');
    map.remove('_snippetResult');
    data = map;
  }
}

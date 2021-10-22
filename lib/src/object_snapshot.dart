part of algolia;

// Implementation & bug solved by https://github.com/franvera
// - highlightResult [Bug] (commit ref: 0d76d24fe8aa347a0933920afe5ded43bdcbd68b)
// - snippetResult [Implementation] (commit ref: 0d76d24fe8aa347a0933920afe5ded43bdcbd68b)

class AlgoliaObjectSnapshot {
  final Algolia algolia;
  final String objectID;
  final String index;
  final Map<String, dynamic>? highlightResult;
  final Map<String, dynamic>? snippetResult;
  final Map<String, dynamic> _data;

  AlgoliaObjectReference get ref =>
      AlgoliaObjectReference._(algolia, index, objectID);

  AlgoliaObjectSnapshot._(this.algolia, this.index, Map<String, dynamic> map)
      : objectID = map['objectID'],
        highlightResult = map['_highlightResult'],
        snippetResult = map['_snippetResult'],
        _data = map;

  Map<String, dynamic> get data {
    var _d = _data;
    _d.remove('_highlightResult');
    _d.remove('_snippetResult');
    return _d;
  }

  @override
  String toString() {
    return _data.toString();
  }

  Map<String, dynamic> toMap() {
    return _data;
  }

  @Deprecated('Use `.raw()` instead.')
  Map<String, dynamic> raw() => _data;
}

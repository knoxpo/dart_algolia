part of algolia;

class AlgoliaFacetValueSnapshot {
  final Algolia algolia;
  final String? objectID;
  final String index;
  final int count;
  final String highlighted;
  final String value;
  final Map<String, dynamic> _data;

  AlgoliaObjectReference get ref =>
      AlgoliaObjectReference._(algolia, index, objectID);

  AlgoliaFacetValueSnapshot._(
      this.algolia, this.index, Map<String, dynamic> map)
      : objectID = map['objectID'],
        count = map['count'],
        value = map['value'],
        highlighted = map['highlighted'],
        _data = map;

  Map<String, dynamic> get data {
    var _d = _data;
    _d.remove('_highlightResult');
    _d.remove('_snippetResult');
    return _d;
  }

  Map<String, dynamic> raw() => _data;

  @override
  String toString() => _data.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AlgoliaFacetValueSnapshot &&
        other.value == value &&
        other.highlighted == highlighted &&
        other.count == count &&
        other.objectID == objectID &&
        other.data == data;
  }

  @override
  int get hashCode {
    return value.hashCode ^
        highlighted.hashCode ^
        count.hashCode ^
        data.hashCode ^
        objectID.hashCode ^
        algolia.hashCode ^
        _data.hashCode;
  }
}

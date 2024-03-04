part of '../algolia.dart';

class AlgoliaQuerySnapshot {
  AlgoliaQuerySnapshot._(this.algolia, this.index, Map<String, dynamic> map)
      : _map = map,
        hits = (map['hits'] as List<dynamic>? ?? [])
            .map((dynamic o) {
              var newMap = Map<String, dynamic>.from(o);
              return AlgoliaObjectSnapshot._(algolia, index, newMap);
            })
            .toList()
            .cast<AlgoliaObjectSnapshot>();

  final Algolia algolia;
  final String index;
  final Map<String, dynamic> _map;
  final List<AlgoliaObjectSnapshot> hits;

  String get params => _map['params'];
  String? get queryID => _map['queryID'];
  String get query => _map['query'];

  bool get empty => hits.isEmpty;
  bool get hasHits => hits.isNotEmpty;

  int get hitsPerPage => _map['hitsPerPage'] ?? 0;
  int get length => _map['length'] ?? 0;
  int get nbHits => _map['nbHits'] ?? 0;
  int get nbPages => _map['nbPages'] ?? 0;
  int get offset => _map['offset'] ?? 0;
  int get page => _map['page'] ?? 0;

  Map<String, dynamic> get facets => _map['facets'] ?? {};
  Map<String, dynamic> get facetsStats => _map['facets_stats'] ?? {};

  bool get exhaustiveNbHits => _map['exhaustiveNbHits'];
  int get processingTimeMS => _map['processingTimeMS'] ?? 0;

  Map<String, dynamic> toMap() => _map;

  @Deprecated('Use `.raw()` instead.')
  Map<String, dynamic> raw() => _map;

  @override
  String toString() => _map.toString();
}

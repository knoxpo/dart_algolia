part of algolia;

class AlgoliaQuerySnapshot {
  AlgoliaQuerySnapshot._(algolia, index, Map<String, dynamic> map)
      : algolia = algolia,
        index = index,
        _map = map,
        hits = (map['hits'] as List<dynamic>? ?? [])
            .map((dynamic o) {
              var newMap = Map<String, dynamic>.from(o);
              return AlgoliaObjectSnapshot._(algolia, index, newMap);
            })
            .toList()
            .cast<AlgoliaObjectSnapshot>(),
        empty = (map['hits'] as List<dynamic>? ?? []).isEmpty,
        nbHits = map['nbHits'],
        page = map['page'],
        nbPages = map['nbPages'],
        hitsPerPage = map['hitsPerPage'],
        processingTimeMS = map['processingTimeMS'],
        exhaustiveNbHits = map['exhaustiveNbHits'],
        query = map['query'],
        queryId = map["queryID"],
        params = map['params'],
        facets = map['facets'] ?? {},
        facetsStats = map['facets_stats'] ?? {};

  final List<AlgoliaObjectSnapshot> hits;
  final Algolia algolia;
  final bool empty;
  final int nbHits;
  final int page;
  final int nbPages;
  final int hitsPerPage;
  final int processingTimeMS;
  final bool exhaustiveNbHits;
  final String query;
  final String queryId;
  final String params;
  final String index;
  final Map<String, dynamic> facets;
  final Map<String, dynamic> facetsStats;
  final Map<String, dynamic> _map;

  @override
  String toString() {
    return _map.toString();
  }

  Map<String, dynamic> toMap() {
    return _map;
  }

  bool get hasHits {
    return hits.isNotEmpty;
  }
}

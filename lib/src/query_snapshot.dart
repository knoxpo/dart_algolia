part of algolia;

class AlgoliaQuerySnapshot {
  AlgoliaQuerySnapshot({
    hits,
    empty,
    nbHits,
    page,
    nbPages,
    hitsPerPage,
    processingTimeMS,
    exhaustiveNbHits,
    params,
    query,
  });

  List<AlgoliaObjectSnapshot>? hits;
  Algolia? algolia;
  bool? empty;
  int? nbHits;
  int? page;
  int? nbPages;
  int? hitsPerPage;
  int? processingTimeMS;
  bool? exhaustiveNbHits;
  String? query;
  String? params;
  String? index;
  Map<String, dynamic>? facets;
  Map<String, dynamic>? facetsStats;

  AlgoliaQuerySnapshot.fromMap(algolia, index, Map<String, dynamic> map) {
    algolia = algolia;
    index = index;
    List<AlgoliaObjectSnapshot> hitsReMap =
        (map['hits'] as List<dynamic>? ?? [])
            .map((dynamic o) {
              Map<String, dynamic> newMap = Map<String, dynamic>.from(o);
              return AlgoliaObjectSnapshot.fromMap(algolia, index, newMap);
            })
            .toList()
            .cast<AlgoliaObjectSnapshot>();
    hits = hitsReMap;
    empty = hits!.isEmpty;
    nbHits = map['nbHits'];
    page = map['page'];
    nbPages = map['nbPages'];
    hitsPerPage = map['hitsPerPage'];
    processingTimeMS = map['processingTimeMS'];
    exhaustiveNbHits = map['exhaustiveNbHits'];
    query = map['query'];
    params = map['params'];
    facets = map['facets'] ?? {};
    facetsStats = map['facets_stats'] ?? {};
  }
}

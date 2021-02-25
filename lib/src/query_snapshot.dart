part of algolia;

class AlgoliaQuerySnapshot {
  AlgoliaQuerySnapshot({
    this.hits,
    this.empty,
    this.nbHits,
    this.page,
    this.nbPages,
    this.hitsPerPage,
    this.processingTimeMS,
    this.exhaustiveNbHits,
    this.params,
    this.query,
  });

  List<AlgoliaObjectSnapshot> hits;
  Algolia algolia;
  bool empty;
  int nbHits;
  int page;
  int nbPages;
  int hitsPerPage;
  int processingTimeMS;
  bool exhaustiveNbHits;
  String query;
  String params;
  String index;
  Map<String, dynamic> facets;
  Map<String, dynamic> facetsStats;

  AlgoliaQuerySnapshot.fromMap(algolia, index, Map<String, dynamic> map) {
    this.algolia = algolia;
    this.index = index;
    List<AlgoliaObjectSnapshot> hitsReMap = (map['hits'] as List<dynamic> ?? [])
        .map((dynamic o) {
          Map<String, dynamic> newMap = Map<String, dynamic>.from(o);
          return AlgoliaObjectSnapshot.fromMap(algolia, index, newMap);
        })
        .toList()
        .cast<AlgoliaObjectSnapshot>();
    this.hits = hitsReMap;
    this.empty = this.hits.isEmpty;
    this.nbHits = map['nbHits'];
    this.page = map['page'];
    this.nbPages = map['nbPages'];
    this.hitsPerPage = map['hitsPerPage'];
    this.processingTimeMS = map['processingTimeMS'];
    this.exhaustiveNbHits = map['exhaustiveNbHits'];
    this.query = map['query'];
    this.params = map['params'];
    this.facets = map['facets'] != null ? map['facets'] : {};
    this.facetsStats = map['facets_stats'] != null ? map['facets_stats'] : {};
  }
}

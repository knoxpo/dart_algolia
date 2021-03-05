part of algolia;

class AlgoliaIndexesSnapshot {
  AlgoliaIndexesSnapshot._(this.algolia, Map<String, dynamic> map)
      : items = map['items'] != null
            ? (map['items'] as List<dynamic>)
                .map((dynamic o) {
                  Map<String, dynamic> newMap = Map<String, dynamic>.from(o);
                  return AlgoliaIndexSnapshot.fromMap(algolia, newMap);
                })
                .toList()
                .cast<AlgoliaIndexSnapshot>()
            : [],
        nbPages = map['nbPages'] ?? 0;

  List<AlgoliaIndexSnapshot> items;
  Algolia algolia;
  int nbPages;
}

class AlgoliaIndexSnapshot {
  late Algolia algolia;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? entries;
  int? dataSize;
  int? fileSize;
  int? lastBuildTimeS;
  int? numberOfPendingTask;
  bool? pendingTask;

  AlgoliaIndexReference get ref => AlgoliaIndexReference._(algolia, name!);

  AlgoliaIndexSnapshot.fromMap(algolia, Map<String, dynamic> map) {
    algolia = algolia;
    name = map['name'];
    createdAt = DateTime.parse(map['createdAt']);
    updatedAt = DateTime.parse(map['updatedAt']);
    entries = map['entries'];
    dataSize = map['dataSize'];
    fileSize = map['fileSize'];
    lastBuildTimeS = map['lastBuildTimeS'];
    numberOfPendingTask = map['numberOfPendingTask'];
    pendingTask = map['pendingTask'];
  }
}

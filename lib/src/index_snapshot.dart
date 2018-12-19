part of algolia;

class AlgoliaIndexesSnapshot {
  AlgoliaIndexesSnapshot._(this.algolia, Map<String, dynamic> map)
      : items = (map['items'] as List<dynamic>)
                .map((dynamic o) {
                  Map<String, dynamic> newMap = Map<String, dynamic>.from(o);
                  return AlgoliaIndexSnapshot.fromMap(algolia, newMap);
                })
                .toList()
                .cast<AlgoliaIndexSnapshot>() ??
            [],
        nbPages = map['nbPages'] ?? 0;

  List<AlgoliaIndexSnapshot> items;
  Algolia algolia;
  int nbPages;
}

class AlgoliaIndexSnapshot {
  Algolia algolia;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  int entries;
  int dataSize;
  int fileSize;
  int lastBuildTimeS;
  int numberOfPendingTask;
  bool pendingTask;

  AlgoliaIndexReference get ref => AlgoliaIndexReference._(algolia, name);

  AlgoliaIndexSnapshot.fromMap(algolia, Map<String, dynamic> map) {
    this.algolia = algolia;
    this.name = map['name'];
    this.createdAt = DateTime.parse(map['createdAt']);
    this.updatedAt = DateTime.parse(map['updatedAt']);
    this.entries = map['entries'];
    this.dataSize = map['dataSize'];
    this.fileSize = map['fileSize'];
    this.lastBuildTimeS = map['lastBuildTimeS'];
    this.numberOfPendingTask = map['numberOfPendingTask'];
    this.pendingTask = map['pendingTask'];
  }
}

part of '../algolia.dart';

class AlgoliaIndexesSnapshot {
  AlgoliaIndexesSnapshot._(this.algolia, Map<String, dynamic> map)
      : _map = map,
        items = map['items'] != null
            ? (map['items'] as List<dynamic>)
                .map((dynamic o) {
                  var newMap = Map<String, dynamic>.from(o);
                  return AlgoliaIndexSnapshot._(algolia, newMap);
                })
                .toList()
                .cast<AlgoliaIndexSnapshot>()
            : [],
        nbPages = map['nbPages'] ?? 0;

  final Algolia algolia;
  final List<AlgoliaIndexSnapshot> items;
  final int nbPages;
  final Map<String, dynamic> _map;

  @override
  String toString() {
    return _map.toString();
  }

  Map<String, dynamic> toMap() {
    return _map;
  }
}

class AlgoliaIndexSnapshot {
  AlgoliaIndexSnapshot._(this.algolia, Map<String, dynamic> map)
      : _map = map,
        name = map['name'],
        createdAt = DateTime.parse(map['createdAt']),
        updatedAt = DateTime.parse(map['updatedAt']),
        entries = map['entries'],
        dataSize = map['dataSize'],
        fileSize = map['fileSize'],
        lastBuildTimeS = map['lastBuildTimeS'],
        numberOfPendingTask = map['numberOfPendingTask'],
        pendingTask = map['pendingTask'];

  AlgoliaIndexReference get ref => AlgoliaIndexReference._(algolia, name);

  final Algolia algolia;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? entries;
  final int? dataSize;
  final int? fileSize;
  final int? lastBuildTimeS;
  final int? numberOfPendingTask;
  final bool pendingTask;
  final Map<String, dynamic> _map;

  @override
  String toString() {
    return _map.toString();
  }

  Map<String, dynamic> toMap() => _map;
}

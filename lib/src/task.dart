
part of algolia;

class AlgoliaTask {
  AlgoliaTask._(this.algolia, String index, Map<String, dynamic> data)
      : _index = index,
        _data = data,
        taskID = data['taskID'],
        assert(algolia != null);
  final Algolia algolia;
  final String _index;
  final int taskID;
  final Map<String, dynamic> _data;

  Map<String, dynamic> get data {
    Map<String, dynamic> d = Map<String, dynamic>.from(_data);
    d.remove('taskID');
    return d;
  }
}

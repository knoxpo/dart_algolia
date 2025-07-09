part of '../algolia.dart';

class AlgoliaTask {
  AlgoliaTask._(this.algolia, String? index, Map<String, dynamic> data)
      : _index = index,
        _data = data,
        taskID = data['taskID'];
  final Algolia algolia;
  final String? _index;
  final int? taskID;
  final Map<String, dynamic> _data;

  Map<String, dynamic> get data {
    var d = Map<String, dynamic>.from(_data);
    d.remove('taskID');
    return d;
  }

  Future<void> waitTask() async {
    const baseDelay = 100;
    const maxDelay = 5000;
    var delay = 0;
    var loop = 0;
    while (!await Future.delayed(Duration(milliseconds: delay), taskStatus)) {
      ++loop;
      delay = (baseDelay * loop * loop).clamp(baseDelay, maxDelay);
    }
  }

  Future<bool> taskStatus() async {
    var response = await algolia._apiCall(
      ApiRequestType.get,
      'indexes/$_index/task/$taskID',
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return body['status'] == 'published';
  }
}

part of algolia;

class AlgoliaObjectReference {
  AlgoliaObjectReference._(this.algolia, String? index, String? objectId)
      : _index = index,
        _objectId = objectId;

  final Algolia algolia;
  final String? _index;
  final String? _objectId;

  String? get index => _index;

  String? get objectID => _objectId;

  String? get encodedObjectID =>
      _objectId != null ? Uri.encodeFull(_objectId!) : null;
  String? get encodedIndex => _index != null ? Uri.encodeFull(_index!) : null;

  /// Get the object referred to by this [AlgoliaObjectReference].
  ///
  /// If the object does not yet exist, it will be created.
  Future<AlgoliaObjectSnapshot> getObject() async {
    assert(_index != null, 'You can\'t get an object without an index.');
    assert(_objectId != null, 'You can\'t get an object without an objectID.');
    var response = await algolia._apiCall(
      ApiRequestType.get,
      'indexes/$encodedIndex/$encodedObjectID',
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return AlgoliaObjectSnapshot._(algolia, _index!, body);
  }

  /// Writes to the object referred to by this [AlgoliaObjectReference].
  ///
  /// If the object does not yet exist, it will be created.
  Future<AlgoliaTask> setData(Map<String, dynamic> data) async {
    assert(_index != null && _index != '*' && _index != '',
        'IndexName is required, but it has `*` multiple flag or `null`.');

    var url = 'indexes/$encodedIndex';

    if (_objectId != null) {
      url += '/$encodedObjectID';
    }
    if (data['objectID'] != null && _objectId == null) {
      url += "/${Uri.encodeFull(data['objectID'])}";
    } else if (data['objectID'] != null) {
      data.remove('objectID');
    }
    var response = await algolia._apiCall(
      ApiRequestType.put,
      url,
      data: data,
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaTask._(algolia, _index, body);
  }

  ///
  /// **UpdateData**
  ///
  /// Updates fields in the object referred to by this [AlgoliaObjectReference].
  ///
  /// Values in [data] may be of any supported Algolia type.
  ///
  /// If no object exists yet, the update will fail.
  Future<AlgoliaTask> updateData(Map<String, dynamic> data) async {
    assert(_index != null && _index != '*' && _index != '',
        'IndexName is required, but it has `*` multiple flag or `null`.');
    var url = 'indexes/$encodedIndex';
    if (_objectId != null) {
      url = '$url/$encodedObjectID';
    }
    data['objectID'] = _objectId;

    var response = await algolia._apiCall(
      ApiRequestType.put,
      url,
      data: data,
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaTask._(algolia, _index, body);
  }

  ///
  /// **PartialUpdateObject**
  ///
  /// Updates fields in the object referred to by this [AlgoliaObjectReference].
  ///
  /// Values in [data] may be of any supported Algolia type.
  ///
  /// If no object exists yet, the update will fail.
  ///
  /// ---
  ///
  ///  **Usage**
  ///   - `createIfNotExists`: When true, a partial update on a nonexistent object will create the
  ///      object, assuming an empty object as the basis. When false, a partial
  ///      update on a nonexistent object will be ignored.
  ///
  Future<AlgoliaTask> partialUpdateObject(Map<String, dynamic> data,
      {bool createIfNotExists = true}) async {
    assert(_objectId != null || createIfNotExists,
        'You can\'t partialUpdateObject when createIfNotExists=false and data without an objectID.');
    assert(_index != null && _index != '*' && _index != '',
        'IndexName is required, but it has `*` multiple flag or `null`.');

    var url = 'indexes/$encodedIndex';
    if (_objectId != null) {
      url = '$url/$encodedObjectID/partial';
    }
    data['objectID'] = _objectId;
    data['createIfNotExists'] = createIfNotExists;
    var response = await algolia._apiCall(
      ApiRequestType.post,
      url,
      data: data,
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaTask._(algolia, _index, body);
  }

  /// Delete the object referred to by this [AlgoliaObjectReference].
  ///
  /// If no object exists yet, the update will fail.
  Future<AlgoliaTask> deleteObject() async {
    assert(
        _objectId != null, 'You can\'t delete an object without an objectID.');

    var url = 'indexes/$encodedIndex';
    if (_objectId != null) {
      url = '$url/$encodedObjectID';
    }
    var response = await algolia._apiCall(
      ApiRequestType.delete,
      url,
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaTask._(algolia, _index, body);
  }
}

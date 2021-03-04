part of algolia;

class AlgoliaObjectReference {
  AlgoliaObjectReference._(this.algolia, String index, String objectId)
      : _index = index,
        _objectId = objectId,
        assert(algolia != null);

  final Algolia algolia;
  final String _index;
  final String _objectId;

  String get index => _index;
  String get objectID => _objectId;

  /// Get the object referred to by this [AlgoliaObjectReference].
  ///
  /// If the object does not yet exist, it will be created.
  Future<AlgoliaObjectSnapshot> getObject() async {
    assert(_objectId != null, 'You can\'t get an object without an objectID.');
    try {
      String url = '${algolia._host}indexes/$_index/$_objectId';
      Response response = await get(
        Uri.parse(url),
        headers: algolia._header,
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaObjectSnapshot.fromMap(algolia, _index, body);
    } catch (err) {
      return err;
    }
  }

  /// Writes to the object referred to by this [AlgoliaObjectReference].
  ///
  /// If the object does not yet exist, it will be created.
  Future<AlgoliaTask> setData(Map<String, dynamic> data) async {
    try {
      assert(_index != null && _index != '*' && _index != '',
          'IndexName is required, but it has `*` multiple flag or `null`.');
      String url = '${algolia._host}indexes/$_index';
      if (_objectId != null) {
        url = '$url/$_objectId';
      }
      Response response = await post(
        Uri.parse(url),
        headers: algolia._header,
        body: utf8.encode(json.encode(data, toEncodable: jsonEncodeHelper)),
        encoding: Encoding.getByName('utf-8'),
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaTask._(algolia, _index, body);
    } catch (err) {
      return err;
    }
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
    try {
      assert(_index != null && _index != '*' && _index != '',
          'IndexName is required, but it has `*` multiple flag or `null`.');
      String url = '${algolia._host}indexes/$_index';
      if (_objectId != null) {
        url = '$url/$_objectId';
      }
      data['objectID'] = _objectId;
      Response response = await put(
        Uri.parse(url),
        headers: algolia._header,
        body: utf8.encode(json.encode(data, toEncodable: jsonEncodeHelper)),
        encoding: Encoding.getByName('utf-8'),
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaTask._(algolia, _index, body);
    } catch (err) {
      return err;
    }
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
    try {
      String url = '${algolia._host}indexes/$_index';
      if (_objectId != null) {
        url = '$url/$_objectId/partial';
      }
      data['objectID'] = _objectId;
      data['createIfNotExists'] = createIfNotExists;
      Response response = await put(
        Uri.parse(url),
        headers: algolia._header,
        body: utf8.encode(json.encode(data, toEncodable: jsonEncodeHelper)),
        encoding: Encoding.getByName('utf-8'),
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaTask._(algolia, _index, body);
    } catch (err) {
      return err;
    }
  }

  /// Delete the object referred to by this [AlgoliaObjectReference].
  ///
  /// If no object exists yet, the update will fail.
  Future<AlgoliaTask> deleteObject() async {
    assert(
        _objectId != null, 'You can\'t delete an object without an objectID.');
    try {
      String url = '${algolia._host}indexes/$_index';
      if (_objectId != null) {
        url = '$url/$_objectId';
      }
      Response response = await delete(
        Uri.parse(url),
        headers: algolia._header,
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaTask._(algolia, _index, body);
    } catch (err) {
      return err;
    }
  }
}

part of algolia;

///
/// **AlgoliaIndexReference**
///
/// A AlgoliaIndexReference object can be used for adding object, getting
/// object references, manage the index and querying for objects (using
/// the methods inherited from [AlgoliaQuery]).
///
class AlgoliaIndexReference extends AlgoliaQuery {
  AlgoliaIndexReference._(Algolia algolia, String index)
      : super._(algolia: algolia, index: index);

  ///
  /// ID of the referenced index.
  ///
  String get index => _index;

  ///
  /// **Settings**
  ///
  /// Delete the index referred to by this [AlgoliaIndexReference].
  ///
  AlgoliaIndexSettings get settings =>
      AlgoliaIndexSettings._(this.algolia, this._index);

  AlgoliaObjectReference object([String path]) {
    String objectId;
    assert(index != null, 'For object reference you required indexName');
    if (path == null) {
      // final String key = 'PushIdGenerator.generatePushChildName()';
      // objectId = key;
    } else {
      objectId = path;
    }
    return AlgoliaObjectReference._(algolia, index, objectId);
  }

  ///
  /// **AlgoliaBatch**
  ///
  /// Creates a write batch, used for performing multiple writes as a single
  /// atomic operation.
  ///
  /// Perform multiple write operations in a single API call.
  ///
  /// In order to reduce the amount of time spent on network round trips, you
  /// can perform multiple write operations at once. All operations will be
  /// applied in the order they are specified.
  ///
  /// **Operations you can batch**
  /// The following actions are supported:
  ///   - `addObject`: Add an object. Equivalent to Add an object without ID.
  ///   - `updateObject`: Add or replace an existing object. You must set the
  ///      objectID attribute to indicate the object to update. Equivalent to
  ///      Add/update an object by ID.
  ///   - `partialUpdateObject`: Partially update an object. You must set the
  ///      objectID attribute to indicate the object to update. Equivalent to
  ///      Partially update an object.
  ///   - `partialUpdateObjectNoCreate`: Same as partialUpdateObject, except
  ///      that the object is not created if the object designed by objectID
  ///      does not exist.
  ///   - `deleteObject`: Delete an object. You must set the objectID attribute
  ///      to indicate the object to delete. Equivalent to Delete an object.
  ///   - `delete`: Delete the index. Equivalent to Delete an index.
  ///   - `clear`: Remove the index’s content, but keep settings and index-
  ///      specific API keys untouched. Equivalent to Clear objects.
  ///
  AlgoliaBatch batch() => AlgoliaBatch._(algolia, index);

  ///
  /// **AddObject**
  ///
  /// Returns a `AlgoliaObjectReference` with an auto-generated ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  ///
  Future<AlgoliaTask> addObject(Map<String, dynamic> data) async {
    final AlgoliaObjectReference newDocument = object();
    return await newDocument.setData(data);
  }

  ///
  /// **GetObjects**///
  ///
  /// Retrieve objects from the index referred to by this [AlgoliaIndexReference].
  ///
  @override
  Future<AlgoliaQuerySnapshot> getObjects([List<String> objectIds]) async {
    assert(index != null, 'You can\'t get objects without an indexName.');
    try {
      String url = '${algolia._host}indexes/$index/objects';
      final List<Map> objects = List.generate(objectIds.length,
          (int i) => {'indexName': index, 'objectID': objectIds[i]});
      final Map requests = {'requests': objects};
      Response response = await post(
        url,
        headers: algolia._header,
        body: utf8.encode(json.encode(requests, toEncodable: jsonEncodeHelper)),
        encoding: Encoding.getByName('utf-8'),
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaQuerySnapshot.fromMap(algolia, _index, body);
    } catch (err) {
      return err;
    }
  }

  ///
  /// **ClearIndex**
  ///
  /// Clear the index referred to by this [AlgoliaIndexReference].
  ///
  Future<AlgoliaTask> clearIndex() async {
    assert(index != null, 'You can\'t clear an objects without an indexName.');
    try {
      String url = '${algolia._host}indexes/$index/clear';
      Response response = await post(
        url,
        headers: algolia._header,
        encoding: Encoding.getByName('utf-8'),
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaTask._(algolia, index, body);
    } catch (err) {
      return err;
    }
  }

  ///
  /// **DeleteIndex**
  ///
  /// Delete the index referred to by this [AlgoliaIndexReference].
  ///
  Future<AlgoliaTask> deleteIndex() async {
    assert(index != null, 'You can\'t clear an objects without an indexName.');
    try {
      String url = '${algolia._host}indexes/$index';
      Response response = await delete(
        url,
        headers: algolia._header,
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaTask._(algolia, index, body);
    } catch (err) {
      return err;
    }
  }
}

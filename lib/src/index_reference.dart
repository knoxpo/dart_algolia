part of algolia;

/// Scopes of the data to copy when copying an index.
/// When copying, you may specify optional scopes to the operation. Doing
/// so results in a partial copy: only the specified scopes are copied,
/// replacing the corresponding scopes in the destination.
enum CopyScope { Settings, Synonyms, Rules }

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
  /// **AddObjects**
  ///
  /// Returns a `AlgoliaTask` with an auto-generated Task ID, after
  /// populating it with provided [data].
  ///
  /// The unique key generated is prefixed with a client-generated timestamp
  /// so that the resulting list will be chronologically-sorted.
  ///
  Future<AlgoliaTask> addObjects(List<Map<String, dynamic>> objects) async {
    final AlgoliaBatch batch = this.batch();
    for (final obj in objects) {
      batch.addObject(obj);
    }
    return await batch.commit();
  }

  ///
  /// **GetObjects**
  ///
  /// Retrieve objects from the index referred to by this [AlgoliaIndexReference].
  ///
  Future<List<AlgoliaObjectSnapshot>> getObjectsByIds(
      [List<String> objectIds]) async {
    assert(index != null, 'You can\'t get objects without an indexName.');
    try {
      String url = '${algolia._host}indexes/*/objects';
      final List<Map> objects = List.generate(objectIds.length,
          (int i) => {'indexName': index, 'objectID': objectIds[i]});
      final Map requests = {'requests': objects};
      Response response = await post(
        Uri.parse(url),
        headers: algolia._header,
        body: utf8.encode(json.encode(requests, toEncodable: jsonEncodeHelper)),
        encoding: Encoding.getByName('utf-8'),
      );
      Map<String, dynamic> result = json.decode(response.body);
      List<dynamic> results = result['results'];
      return List.generate(results.length, (i) {
        return AlgoliaObjectSnapshot.fromMap(algolia, _index, results[i]);
      });
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
        Uri.parse(url),
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
  /// **MoveIndex**
  ///
  /// Move the index referred to by this [AlgoliaIndexReference].
  ///
  Future<AlgoliaTask> moveIndex({@required String destination}) async {
    return await _copyOrMoveIndex(destination: destination, copy: false);
  }

  ///
  /// **CopyIndex**
  ///
  /// Copy the index referred to by this [AlgoliaIndexReference].
  ///
  /// [scopes] represent the scopes of the index to copy. When absent, a full copy
  /// is performed. When present, only the selected scopes are copied. When you
  /// use the scopes parameter, you will no longer be copying records (objects)
  /// but only the specified scopes.
  Future<AlgoliaTask> copyIndex(
      {@required String destination, List<CopyScope> scopes}) async {
    return await _copyOrMoveIndex(
        destination: destination, copy: true, scopes: scopes);
  }

  Future<AlgoliaTask> _copyOrMoveIndex({
    @required String destination,
    @required bool copy,
    List<CopyScope> scopes,
  }) async {
    assert(index != null,
        'You can\'t copy or move an index without an indexName.');
    assert(destination != null,
        'You can\'t copy or move an index without a destination.');
    assert(copy != null,
        'You can\'t copy or move an index without selecting which operation.');
    try {
      String url = '${algolia._host}indexes/$index/operation';
      final Map<String, dynamic> data = {
        'operation': copy ? 'copy' : 'move',
        'destination': destination,
      };
      if (scopes != null) {
        data['scope'] = scopes.map<String>((s) => _scopeToString(s)).toList();
      }
      Response response = await post(
        Uri.parse(url),
        headers: algolia._header,
        encoding: Encoding.getByName('utf-8'),
        body: utf8.encode(json.encode(data, toEncodable: jsonEncodeHelper)),
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaTask._(algolia, index, body);
    } catch (err) {
      return err;
    }
  }

  String _scopeToString(CopyScope scope) {
    return scope
        .toString()
        .substring(scope.toString().indexOf('.') + 1)
        .toLowerCase();
  }

  ///
  /// **ReplaceAllObjects**
  ///
  /// Replace all the objerts in the index referred to by this [AlgoliaIndexReference].
  ///
  Future<AlgoliaTask> replaceAllObjects(
      List<Map<String, dynamic>> objects) async {
    assert(
        index != null, 'You can\'t replace all objects without an indexName.');
    try {
      final AlgoliaIndexReference tempIndex = algolia.index(Uuid().v4());
      final AlgoliaTask copyTask = await copyIndex(
        destination: tempIndex.index,
        scopes: [
          CopyScope.Settings,
          CopyScope.Synonyms,
          CopyScope.Rules,
        ],
      );
      await copyTask.waitTask();
      final AlgoliaTask batchTask = await tempIndex.addObjects(objects);
      await batchTask.waitTask();
      return await tempIndex.moveIndex(destination: index);
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
        Uri.parse(url),
        headers: algolia._header,
      );
      Map<String, dynamic> body = json.decode(response.body);
      return AlgoliaTask._(algolia, index, body);
    } catch (err) {
      return err;
    }
  }
}

class AlgoliaMultiIndexesReference {
  AlgoliaMultiIndexesReference._(Algolia algolia,
      {List<AlgoliaQuery> queries}) {
    _algolia = algolia;
    if (queries != null) {
      this._queries = queries;
    } else {
      this._queries = [];
    }
  }

  List<AlgoliaQuery> _queries;
  Algolia _algolia;

  List<AlgoliaQuery> get queries => this._queries;

  AlgoliaMultiIndexesReference addQuery(AlgoliaQuery query) {
    assert(query != null);
    _queries.add(query);
    return AlgoliaMultiIndexesReference._(
      this._algolia,
      queries: _queries,
    );
  }

  AlgoliaMultiIndexesReference addQueries(List<AlgoliaQuery> queries) {
    assert(queries != null && queries.isNotEmpty);
    _queries.addAll(queries);
    return AlgoliaMultiIndexesReference._(
      this._algolia,
      queries: _queries,
    );
  }

  AlgoliaMultiIndexesReference clearQueries() => AlgoliaMultiIndexesReference._(
        this._algolia,
        queries: [],
      );

  String _encodeMap(Map data) {
    Uri outgoingUri = new Uri(
      scheme: '',
      host: '',
      path: '',
      queryParameters: data,
    );
    return outgoingUri.toString().substring(3);
  }

  Future<List<AlgoliaQuerySnapshot>> getObjects() async {
    assert(queries != null && _queries.isNotEmpty,
        'You require at least one query added before performing `.getObject()`');
    List<Map<String, dynamic>> requests = [];
    for (AlgoliaQuery q in this._queries) {
      AlgoliaQuery _q = q;
      if (_q.parameters.containsKey('minimumAroundRadius')) {
        assert(
            (_q.parameters.containsKey('aroundLatLng') ||
                _q.parameters.containsKey('aroundLatLngViaIP')),
            'This setting only works within the context of a circular geo search, enabled by `aroundLatLng` or `aroundLatLngViaIP`.');
      }
      if (_q.parameters['attributesToRetrieve'] == null) {
        _q = _q._copyWithParameters(<String, dynamic>{
          'attributesToRetrieve': const ['*']
        });
      }
      requests.add({
        'indexName': q._index,
        'params': _encodeMap(q.parameters),
      });
    }
    String url = '${_algolia._host}indexes/*/queries';
    Response response = await post(
      Uri.parse(url),
      headers: _algolia._header,
      body: utf8.encode(json.encode({
        'requests': requests,
        'strategy': 'none',
      }, toEncodable: jsonEncodeHelper)),
      encoding: Encoding.getByName('utf-8'),
    );
    Map<String, dynamic> body = json.decode(response.body);
    List<Map<String, dynamic>> results =
        (body['results'] as List).cast<Map<String, dynamic>>();
    List<AlgoliaQuerySnapshot> snapshots = <AlgoliaQuerySnapshot>[];
    if (results.isNotEmpty) {
      for (Map<String, dynamic> snap in results) {
        snapshots
            .add(AlgoliaQuerySnapshot.fromMap(_algolia, snap['index'], snap));
      }
    }
    return snapshots;
  }
}

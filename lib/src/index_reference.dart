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
  AlgoliaIndexSettings get settings => AlgoliaIndexSettings._(algolia, _index);

  ///
  /// **Synonyms**
  ///
  /// Synonyms were originally set via the index settings, and a Get
  /// settings call would return all synonyms as part of the
  /// settings JSON data.
  ///
  AlgoliaSynonymsReference get synonyms =>
      AlgoliaSynonymsReference._(algolia, _index);

  AlgoliaObjectReference object([String? path]) {
    String? objectId;
    if (path == null) {
      // final String key = 'PushIdGenerator.generatePushChildName()';
      // objectId = key;
    } else {
      objectId = path;
    }

    return AlgoliaObjectReference._(algolia, index, objectId);
  }

  ///
  /// **FacetQuerys**
  ///
  /// Search for values of a given facet, optionally restricting the returned
  /// values to those contained in objects matching other search criteria.
  ///
  /// When the query is successful, the HTTP response is a 200 OK. It
  /// contains values that match the queried text, and that are contained in
  /// at least one object matching the other search parameters.
  ///
  /// -------------------------------
  /// **NOTE**
  /// Pagination is not supported. The page and hitsPerPage parameters will
  /// be ignored. By default, maximum 10 values are returned. This can be
  /// adjusted via `maxFacetHits`.
  /// -------------------------------
  ///
  ///
  /// The response body contains the following fields:
  ///  - `facetHits` (array): Matched values. Each hit contains the following
  ///     fields:
  ///     - `value` (string): Raw value of the facet
  ///     - `highlighted` (string): Highlighted facet value
  ///     - `count` (integer): How many objects contain this facet value.
  ///        This takes into account the extra search parameters specified
  ///        in the query. Like for a regular search query, the counts may
  ///        not be exhaustive. See the related discussion.
  ///
  Future<List<AlgoliaFacetValueSnapshot>> facetQuery(
    String facetName, {
    String params = '',
    String facetQuery = '',
    int maxFacetHits = 10,
  }) async {
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/facets/${Uri.encodeFull(facetName)}/query',
      data: {
        'params': params,
        'facetQuery': facetQuery,
        'maxFacetHits': maxFacetHits,
      },
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 500)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return (body['facetHits'] as List<dynamic>)
        .map((e) => AlgoliaFacetValueSnapshot._(algolia, index, e))
        .toList();
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
    if (data['objectID'] != null) {
      final newDocument = object();
      return await newDocument.setData(data);
    }
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex',
      data: data,
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaTask._(algolia, _index, body);
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
    final batch = this.batch();
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
      [List<String> objectIds = const []]) async {
    final objects = List<Map>.generate(objectIds.length,
        (int i) => {'indexName': index, 'objectID': objectIds[i]});
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/*/objects',
      data: {'requests': objects},
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    List<dynamic> results = body['results'];
    return List.generate(results.length, (i) {
      return AlgoliaObjectSnapshot._(algolia, _index, results[i]);
    });
  }

  ///
  /// **ClearIndex**
  ///
  /// Clear the index referred to by this [AlgoliaIndexReference].
  ///
  Future<AlgoliaTask> clearIndex() async {
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/clear',
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return AlgoliaTask._(algolia, index, body);
  }

  ///
  /// **MoveIndex**
  ///
  /// Move the index referred to by this [AlgoliaIndexReference].
  ///
  Future<AlgoliaTask> moveIndex({required String destination}) async {
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
      {required String destination, List<CopyScope>? scopes}) async {
    return await _copyOrMoveIndex(
        destination: destination, copy: true, scopes: scopes);
  }

  Future<AlgoliaTask> _copyOrMoveIndex({
    required String destination,
    required bool copy,
    List<CopyScope>? scopes,
  }) async {
    final data = <String, dynamic>{
      'operation': copy ? 'copy' : 'move',
      'destination': destination,
    };
    if (scopes != null) {
      data['scope'] = scopes.map<String>((s) => _scopeToString(s)).toList();
    }
    var response = await algolia._apiCall(
      ApiRequestType.post,
      'indexes/$encodedIndex/operation',
      data: data,
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaTask._(algolia, index, body);
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
    final tempIndex = algolia.index(Uuid().v4());
    final copyTask = await copyIndex(
      destination: tempIndex.index,
      scopes: [
        CopyScope.Settings,
        CopyScope.Synonyms,
        CopyScope.Rules,
      ],
    );
    await copyTask.waitTask();
    final batchTask = await tempIndex.addObjects(objects);
    await batchTask.waitTask();
    return await tempIndex.moveIndex(destination: index);
  }

  ///
  /// **DeleteIndex**
  ///
  /// Delete the index referred to by this [AlgoliaIndexReference].
  ///
  Future<AlgoliaTask> deleteIndex() async {
    var response = await algolia._apiCall(
      ApiRequestType.delete,
      'indexes/$encodedIndex',
    );
    Map<String, dynamic> body = json.decode(response.body);
    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
    return AlgoliaTask._(algolia, index, body);
  }
}

class AlgoliaMultiIndexesReference {
  AlgoliaMultiIndexesReference._(Algolia algolia, {List<AlgoliaQuery>? queries})
      : _algolia = algolia,
        _queries = queries ?? [];

  final List<AlgoliaQuery>? _queries;
  final Algolia _algolia;

  List<AlgoliaQuery>? get queries => _queries;

  AlgoliaMultiIndexesReference addQuery(AlgoliaQuery query) {
    // ignore: unnecessary_null_comparison
    assert(query != null);
    _queries!.add(query);
    return AlgoliaMultiIndexesReference._(
      _algolia,
      queries: _queries,
    );
  }

  AlgoliaMultiIndexesReference addQueries(List<AlgoliaQuery> queries) {
    assert(queries.isNotEmpty);
    _queries!.addAll(queries);
    return AlgoliaMultiIndexesReference._(
      _algolia,
      queries: _queries,
    );
  }

  AlgoliaMultiIndexesReference clearQueries() => AlgoliaMultiIndexesReference._(
        _algolia,
        queries: [],
      );

  String _encodeMap(Map data) {
    var outgoingUri = Uri(
      scheme: '',
      host: '',
      path: '',
      queryParameters: (data as Map<String, dynamic>?)?.map((key, value) {
        if (value is List) {
          return MapEntry(key, value);
        }
        return MapEntry(key, value.toString());
      }),
    );
    return outgoingUri.toString().substring(3);
  }

  Future<List<AlgoliaQuerySnapshot>> getObjects() async {
    assert(queries != null && _queries!.isNotEmpty,
        'You require at least one query added before performing `.getObject()`');
    var requests = <Map<String, dynamic>>[];
    for (var q in _queries!) {
      var _q = q;
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
    var response = await _algolia._apiCall(
      ApiRequestType.post,
      'indexes/*/queries',
      data: {
        'requests': requests,
        'strategy': 'none',
      },
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    var results = (body['results'] as List).cast<Map<String, dynamic>>();
    var snapshots = <AlgoliaQuerySnapshot>[];
    if (results.isNotEmpty) {
      for (var snap in results) {
        snapshots.add(AlgoliaQuerySnapshot._(_algolia, snap['index'], snap));
      }
    }
    return snapshots;
  }
}

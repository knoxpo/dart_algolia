part of algolia;

/// **AlgoliaBatch**
/// A [AlgoliaBatch] is a series of write operations to be performed as one unit.
///
/// Operations done on a [AlgoliaBatch] do not take effect until you [commit].
///
/// Once committed, no further operations can be performed on the [AlgoliaBatch],
/// nor can it be committed again.
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
class AlgoliaBatch {
  AlgoliaBatch._(
    this.algolia,
    String index, {
    List<AlgoliaBatchRequest> actions,
  })  : _actions = actions ?? <AlgoliaBatchRequest>[],
        _index = index;
  Algolia algolia;
  String _index;

  /// Indicator to whether or not this [AlgoliaBatch] has been committed.
  bool _committed = false;

  List<AlgoliaBatchRequest> _actions;

  ///
  /// **Commit**
  ///
  /// Commits all of the writes in this write batch as a single atomic unit.
  ///
  /// Calling this method prevents any future operations from being added.
  Future<AlgoliaTask> commit() async {
    if (!_committed) {
      if (_actions.isNotEmpty) {
        _committed = true;
        List<Map<String, dynamic>> actions =
            _actions.map((a) => a.toMap()).toList();
        Response response = await post(
          Uri.parse('${algolia._host}indexes/$_index/batch'),
          headers: algolia._header,
          body: utf8.encode(json
              .encode({'requests': actions}, toEncodable: jsonEncodeHelper)),
          encoding: Encoding.getByName('utf-8'),
        );
        Map<String, dynamic> body = json.decode(response.body);
        return AlgoliaTask._(algolia, _index, body);
      } else {
        throw StateError("This batch has no actions to commit.");
      }
    } else {
      throw StateError("This batch has already been committed.");
    }
  }

  ///
  /// **AddObject**
  ///
  /// add to the object referred to by [object].
  ///
  /// Add an object. Equivalent to Add an object without ID.
  ///
  void addObject(Map<String, dynamic> data) {
    if (!_committed) {
      assert(data['objectID'] == null,
          'In batch action [addObject] objectID field is not allowed, or use [updateObject].');
      _actions.add(AlgoliaBatchRequest(action: 'addObject', body: data));
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  ///
  /// **UpdateObject**
  ///
  /// update the object referred to by [object].
  ///
  /// Add or replace an existing object. You must set the objectID attribute to
  /// indicate the object to update. Equivalent to Add/update an object by ID.
  ///
  void updateObject(Map<String, dynamic> data) {
    if (!_committed) {
      _actions.add(AlgoliaBatchRequest(action: 'updateObject', body: data));
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  ///
  /// **PartialUpdateObject**
  ///
  /// partialUpdateObject the object referred to by [object].
  ///
  /// Partially update an object. You must set the objectID attribute
  /// to indicate the object to update. Equivalent to Partially update
  /// an object.
  ///
  void partialUpdateObject(Map<String, dynamic> data) {
    if (!_committed) {
      assert(_index != null && _index != '*' && _index != '',
          'IndexName is required, but it has `*` multiple flag or `null`.');
      _actions
          .add(AlgoliaBatchRequest(action: 'partialUpdateObject', body: data));
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  ///
  /// **ClearIndex**
  ///
  /// partialUpdateObjectNoCreate the object referred to by [object].
  ///
  /// Same as partialUpdateObject, except that the object is not created
  /// if the object designed by objectID does not exist.
  ///
  void partialUpdateObjectNoCreate(Map<String, dynamic> data) {
    if (!_committed) {
      assert(_index != null && _index != '*' && _index != '',
          'IndexName is required, but it has `*` multiple flag or `null`.');
      assert(data['objectID'] != null,
          'In batch action [partialUpdateObjectNoCreate] objectID field is required.');
      _actions.add(AlgoliaBatchRequest(
          action: 'partialUpdateObjectNoCreate', body: data));
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  ///
  /// **DeleteObject**
  ///
  /// Delete an object. You must set the objectID attribute to indicate
  /// the object to delete. Equivalent to Delete an object.
  ///
  void deleteObject(String objectID) {
    if (!_committed) {
      _actions.add(AlgoliaBatchRequest(action: 'deleteObject', body: {
        'objectID': objectID,
      }));
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  ///
  /// **DeleteIndex**
  ///
  /// Delete the index. Equivalent to Delete an index.
  ///
  void deleteIndex() {
    if (!_committed) {
      _actions.add(AlgoliaBatchRequest(action: 'delete', body: {}));
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }

  ///
  /// **ClearIndex**
  ///
  /// Remove the index’s content, but keep settings and index-specific
  /// API keys untouched. Equivalent to Clear objects.
  ///
  void clearIndex() {
    if (!_committed) {
      _actions.add(AlgoliaBatchRequest(action: 'clear', body: {}));
    } else {
      throw StateError(
          "This batch has been committed and can no longer be changed.");
    }
  }
}

/// Batch list element wrapper class [AlgoliaBatchRequest] for commit.
class AlgoliaBatchRequest {
  AlgoliaBatchRequest({
    @required this.action,
    @required this.body,
  });
  String action;
  Map<String, dynamic> body;

  Map<String, dynamic> toMap() => {
        'action': action,
        'body': body,
      };
}

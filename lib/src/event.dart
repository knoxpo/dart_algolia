part of algolia;

enum AlgoliaEventType {
  click,
  conversion,
  view,
}

class AlgoliaEvent {
  AlgoliaEvent({
    required this.eventType,
    required this.eventName,
    required this.index,
    required this.userToken,
    this.timestamp,
    this.queryID,
    this.objectIDs,
    this.filters,
    this.positions,
  }) {
    assert(eventName.isNotEmpty && eventName.length <= 64,
        'eventName - Format: any ASCII character, except control points with a length between 1 and 64.');
    assert(RegExp(r'[a-zA-Z0-9_-]{1,64}').hasMatch(eventName),
        'eventName - Format: [a-zA-Z0-9_-]{1,64}');
    assert((objectIDs?.isEmpty ?? true) || (filters?.isEmpty ?? true),
        'An event can’t have both objectIDs and filters at the same time.');
    if ((queryID?.isNotEmpty ?? false) && eventType == AlgoliaEventType.click) {
      assert(
          (positions?.isNotEmpty ?? false) &&
              (objectIDs?.isNotEmpty ?? false) &&
              positions?.length == objectIDs?.length,
          'positions and objectIDs field is required if a queryID is provided. One position must be provided for each objectID. Only include this parameter when sending click events.');
    }
  }

  ///
  /// **eventType**
  ///
  /// An eventType can be a `click`, a `conversion`, or a `view`.
  ///
  final AlgoliaEventType eventType;

  ///
  /// **eventName**
  ///
  /// A user-defined string used to categorize events.
  ///
  /// **Format:**
  /// any ASCII character, except control points with a length between 1 and 64.
  ///
  final String eventName;

  ///
  /// **index**
  ///
  /// Name of the targeted index.
  ///
  /// **Format:**
  /// same as the index name used by the search engine.
  ///
  final String index;

  ///
  /// **index**
  ///
  /// Name of the targeted index.
  ///
  /// **Format:**
  /// same as the index name used by the search engine.
  ///
  final String userToken;

  ///
  /// **timestamp**
  ///
  /// Time of the event expressed in milliseconds since the Unix epoch. Default: now()
  ///
  final DateTime? timestamp;

  ///
  /// **queryID**
  ///
  /// Algolia `queryID`. This is required when an event is tied to a search.
  ///
  /// It can be found in the Search API results response.
  ///
  final String? queryID;

  ///
  /// **objectIDs**
  ///
  /// An array of index `objectID`. Limited to 20 objects.
  ///
  /// An event can’t have both `objectIDs` and `filters` at the same time.
  ///
  final List<String>? objectIDs;

  ///
  /// **filters**
  ///
  /// An array of filters. Limited to 10 filters.
  ///
  /// **Format:**
  /// ${attribute}:${value}, like brand:apple.
  ///
  /// An event can’t have both `objectIDs` and `filters` at the same time.
  ///
  final List<String>? filters;

  ///
  /// **positions**
  ///
  /// Position of the click in the list of Algolia search results.
  ///
  /// This field is
  /// **required**
  /// if a `queryID` is provided. One position must be provided for each `objectID`.
  ///
  /// The position value must be absolute, not relative, to the result page. For example, when clicking on the third record of the second results page, assuming 10 results per page, the position should be 13. Since page starts at 0, you can use the following formula:
  /// ```$positionOnPage + $page * hitsPerPage```
  ///
  /// Note: For InstantSearch implementations, this position is available through the hit.__position attribute
  ///
  /// **Only**
  /// include this parameter when sending click events.
  final List<int>? positions;

  Map<String, dynamic> toMap() {
    var body = <String, dynamic>{
      'eventType': eventType.toString().split('.')[1],
      'eventName': eventName,
      'index': index,
      'userToken': userToken,
    };
    if (timestamp != null) {
      body['timestamp'] = timestamp!.millisecondsSinceEpoch;
    }
    if (queryID != null) body['queryID'] = queryID;
    if (objectIDs != null) body['objectIDs'] = objectIDs;
    if (filters != null) body['filters'] = filters;
    if (positions != null) body['positions'] = positions;
    return body;
  }
}

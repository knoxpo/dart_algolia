part of algolia;

enum AlgoliaEventType {
  click,
  conversion,
  view,
}

extension AlgoliaEventTypeExtention on AlgoliaEventType {
  String toMap() {
    return toString().split('.').last;
  }
}

///
/// Initital implemention by [@algirdasmac](https://github.com/algirdasmac) committed on 15 Jun
/// [PR](https://github.com/knoxpo/dart_algolia/pull/56/commits/8dc068ed16f7cf0c6747ec28d0e17fcf7b433f7f)
///
class AlgoliaEvent {
  AlgoliaEvent({
    required this.eventType,
    required this.eventName,
    required this.index,
    required this.userToken,
    this.queryID,
    this.objectIDs,
    this.timestamp,
    this.filters,
    this.positions,
  })  : assert(
          eventName.isNotEmpty && eventName.length <= 64,
          'eventName - Format: any ASCII character, '
          'except control points with a length between 1 and 64.',
        ),
        assert(
          RegExp(r'[a-zA-Z0-9_-]{1,64}').hasMatch(eventName),
          'eventName - Format: [a-zA-Z0-9_-]{1,64}',
        ),
        assert(
          (objectIDs?.isEmpty ?? true) || (filters?.isEmpty ?? true),
          'An event can’t have both objectIDs and filters at the same time.',
        ),
        assert(
          !((queryID?.isNotEmpty ?? false) &&
                  eventType == AlgoliaEventType.click) ||
              ((positions?.isNotEmpty ?? false) &&
                  (objectIDs?.isNotEmpty ?? false) &&
                  positions?.length == objectIDs?.length),
          'positions and objectIDs field is required if a queryID is provided. '
          'One position must be provided for each objectId. '
          'Only include this parameter when sending click events.',
        );

  /// An eventType can be a `click`, a `conversion`, or a `view`.
  final AlgoliaEventType eventType;

  /// A user-defined string used to categorize events.
  ///
  /// **Format:**
  /// any ASCII character, except control points with a length between 1 and 64.
  final String eventName;

  /// Name of the targeted index.
  ///
  /// **Format:**
  /// same as the index name used by the search engine.
  final String index;

  /// Name of the targeted index.
  ///
  /// **Format:**
  /// same as the index name used by the search engine.
  final String userToken;

  /// Time of the event expressed in milliseconds since the Unix epoch. Default: now()
  final DateTime? timestamp;

  /// Algolia `queryID`. This is required when an event is tied to a search.
  ///
  /// It can be found in the Search API results response.
  final String? queryID;

  /// An array of index `objectId`. Limited to 20 objects.
  ///
  /// An event can’t have both `objectIDs` and `filters` at the same time.
  final List<String>? objectIDs;

  /// An array of filters. Limited to 10 filters.
  ///
  /// **Format:**
  /// ${attribute}:${value}, like brand:apple.
  ///
  /// An event can’t have both `objectIDs` and `filters` at the same time.
  final List<String>? filters;

  /// Position of the click in the list of Algolia search results.
  ///
  /// This field is
  /// **required**
  /// if a `queryID` is provided. One position must be provided for each
  /// `objectID`.
  ///
  /// The position value must be absolute, not relative, to the result page.
  /// For example, when clicking on the third record of the second results page,
  /// assuming 10 results per page, the position should be 13. Since page starts
  /// at 0, you can use the following formula:
  /// ```$positionOnPage + $page * hitsPerPage```
  ///
  /// Note: For InstantSearch implementations, this position is available
  /// through the hit.__position attribute
  ///
  /// **Only**
  /// include this parameter when sending click events.
  final List<int>? positions;

  Map<String, dynamic> toMap() {
    var body = <String, dynamic>{
      'eventType': eventType.toMap(),
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

  AlgoliaEvent copyWith({
    AlgoliaEventType? eventType,
    String? eventName,
    String? index,
    String? userToken,
    DateTime? timestamp,
    String? queryID,
    List<String>? objectIDs,
    List<String>? filters,
    List<int>? positions,
  }) {
    return AlgoliaEvent(
      eventType: eventType ?? this.eventType,
      eventName: eventName ?? this.eventName,
      index: index ?? this.index,
      userToken: userToken ?? this.userToken,
      timestamp: timestamp ?? this.timestamp,
      queryID: queryID ?? this.queryID,
      objectIDs: objectIDs ?? this.objectIDs,
      filters: filters ?? this.filters,
      positions: positions ?? this.positions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AlgoliaEvent &&
        other.eventType == eventType &&
        other.eventName == eventName &&
        other.index == index &&
        other.userToken == userToken &&
        other.timestamp == timestamp &&
        other.queryID == queryID &&
        other.objectIDs.hashCode == objectIDs.hashCode &&
        other.filters.hashCode == filters.hashCode &&
        other.positions.hashCode == positions.hashCode;
  }

  @override
  int get hashCode {
    return eventType.hashCode ^
        eventName.hashCode ^
        index.hashCode ^
        userToken.hashCode ^
        timestamp.hashCode ^
        queryID.hashCode ^
        objectIDs.hashCode ^
        filters.hashCode ^
        positions.hashCode;
  }

  @override
  String toString() {
    return 'AlgoliaEvent(eventType: $eventType, eventName: $eventName, index: $index, userToken: $userToken, timestamp: $timestamp, queryID: $queryID, objectIDs: $objectIDs, filters: $filters, positions: $positions)';
  }
}

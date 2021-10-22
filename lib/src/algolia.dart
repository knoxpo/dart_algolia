part of algolia;

class Algolia {
  const Algolia.init({
    required String applicationId,
    required String apiKey,
    this.extraHeaders = const {},
  })  : applicationId = applicationId,
        _apiKey = apiKey;

  const Algolia._({
    required String applicationId,
    required String apiKey,
    this.extraHeaders = const {},
  })  : applicationId = applicationId,
        _apiKey = apiKey;

  final String applicationId;
  final String _apiKey;
  final Map<String, String> extraHeaders;

  Algolia get instance => Algolia._(
        applicationId: applicationId,
        apiKey: _apiKey,
        extraHeaders: _headers,
      );

  String get _host => 'https://$applicationId-dsn.algolia.net/1/';

  String get _insightsHost => 'https://insights.algolia.io/1/';

  Map<String, String> get _headers {
    var map = <String, String>{
      'X-Algolia-Application-Id': applicationId,
      'X-Algolia-API-Key': _apiKey,
      'Content-Type': 'application/json',
    };
    map.addEntries(extraHeaders.entries);
    return map;
  }

  Algolia setHeader(String key, String value) {
    var map = extraHeaders;
    map[key] = value;
    return Algolia._(
      applicationId: applicationId,
      apiKey: _apiKey,
      extraHeaders: _headers,
    );
  }

  AlgoliaIndexReference index(String index) {
    return AlgoliaIndexReference._(this, index);
  }

  AlgoliaMultiIndexesReference get multipleQueries =>
      AlgoliaMultiIndexesReference._(this);

  Future<AlgoliaIndexesSnapshot> getIndices() async {
    var _url = '${_host}indexes';
    var response = await http.get(
      Uri.parse(_url),
      headers: _headers,
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }

    return AlgoliaIndexesSnapshot._(this, body);
  }

  /// Pushes an array of events to the Insights API.
  ///
  /// An event is
  ///  - an action: `eventName`
  ///  - performed in a context: `eventType`
  ///  - at some point in time provided: `timestamp`
  ///  - by an end user: `userToken`
  ///  - on something: `index`
  ///
  ///
  /// **Notes:**
  ///  - The number of events that can be sent at the same time is limited to 1000.
  ///  - To be accepted, all events sent must be valid.
  ///  - When an event is tied to an Algolia search, it must also provide a `queryID`. If that event is a click, their absolute `positions` should also be passed.
  ///  - We consider that an index provides access to 2 resources: objects and filters. An event can only interact with a single resource type,
  ///    but not necessarily on a single item. As such an event will accept an array of `objectIDs` or `filters`.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/rest-api/insights.
  Future<void> pushEvents(List<AlgoliaEvent> events) async {
    if (events.isEmpty) return;
    final url = '${_insightsHost}events';
    final eventList = events.map((e) => e.toMap()).toList();
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: utf8.encode(json.encode({'events': eventList})),
      encoding: Encoding.getByName('utf-8'),
    );
    Map<String, dynamic> body = json.decode(response.body);

    if (!(response.statusCode >= 200 && response.statusCode < 300)) {
      throw AlgoliaError._(body, response.statusCode);
    }
  }
}

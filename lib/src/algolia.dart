part of algolia;

enum ApiRequestType {
  get,
  put,
  post,
  delete,
  patch,
}

class Algolia {
  /// Version of the package.
  static final version = "1.1.1";

  /// `Algolia` is a class that has a constructor `init()` that takes in a `applicationId`, `apiKey`,
  /// `extraHeaders` and `extraUserAgents`.
  const Algolia.init({
    required this.applicationId,
    required String apiKey,
    this.extraHeaders = const {},
    this.extraUserAgents = const [],
  }) : _apiKey = apiKey;

  /// A internal constructor.
  const Algolia._({
    required this.applicationId,
    required String apiKey,
    this.extraHeaders = const {},
    this.extraUserAgents = const [],
  }) : _apiKey = apiKey;

  /// A variable that is used to store the application id.
  final String applicationId;

  /// A private variable that is used to store the api key.
  final String _apiKey;

  /// Used to store the extra headers that are passed in the constructor.
  final Map<String, String> extraHeaders;

  /// Used to add extra user agents to the request.
  final List<String> extraUserAgents;

  /// A getter that returns a new instance of Algolia.
  Algolia get instance => Algolia._(
        applicationId: applicationId,
        apiKey: _apiKey,
        extraHeaders: _headers,
        extraUserAgents: _userAgents,
      );

  String get _host => 'https://$applicationId-dsn.algolia.net/1/';
  String get _hostWrite => 'https://$applicationId.algolia.net/1/';
  String get _hostFallback1 => 'https://$applicationId-1.algolianet.com/1/';
  String get _hostFallback2 => 'https://$applicationId-2.algolianet.com/1/';
  String get _hostFallback3 => 'https://$applicationId-3.algolianet.com/1/';
  String get _insightsHost => 'https://insights.algolia.io/1/';

  List<String> get _userAgents {
    final os = "${Platform.operatingSystem} ${Platform.operatingSystemVersion}";
    final dart = "Dart ${Platform.version}";
    final client = "Algolia for Dart (unofficial) ($version)";
    return [os, dart, client, ...extraUserAgents];
  }

  Map<String, String> get _headers {
    var map = <String, String>{
      'X-Algolia-Application-Id': applicationId,
      'X-Algolia-API-Key': _apiKey,
      'Content-Type': 'application/json',
      'User-Agent': _userAgents.join(";"),
    };
    map.addEntries(extraHeaders.entries);
    return map;
  }

  /// It tries to make an API call, and if it fails, it tries to make the same API call again, but with
  /// a different host
  ///
  /// Args:
  ///   requestType (ApiRequestType): The type of request you want to make.
  ///   url (String): The url of the API endpoint.
  ///   data (dynamic): The data to be sent to the server.
  ///
  /// Returns:
  ///   A Future<http.Response>
  Future<http.Response> _apiCall(ApiRequestType requestType, String url,
      {dynamic data}) async {
    // ignore: prefer_function_declarations_over_variables
    final action = (int retry) {
      String host = _hostWrite;
      if (requestType == ApiRequestType.get && retry == 0) {
        host = _host;
      } else if (retry == 1) {
        host = _hostFallback1;
      } else if (retry == 2) {
        host = _hostFallback2;
      } else if (retry == 3) {
        host = _hostFallback3;
      }

      switch (requestType) {
        case ApiRequestType.get:
          return http.get(
            Uri.parse('$host$url'),
            headers: _headers,
          );
        case ApiRequestType.post:
          return http.post(
            Uri.parse('$host$url'),
            headers: _headers,
            encoding: Encoding.getByName('utf-8'),
            body: data != null
                ? utf8.encode(json.encode(data, toEncodable: jsonEncodeHelper))
                : null,
          );
        case ApiRequestType.put:
          return http.put(
            Uri.parse('$host$url'),
            headers: _headers,
            encoding: Encoding.getByName('utf-8'),
            body: data != null
                ? utf8.encode(json.encode(data, toEncodable: jsonEncodeHelper))
                : null,
          );
        case ApiRequestType.patch:
          return http.patch(
            Uri.parse('$host$url'),
            headers: _headers,
            encoding: Encoding.getByName('utf-8'),
            body: data != null
                ? utf8.encode(json.encode(data, toEncodable: jsonEncodeHelper))
                : null,
          );
        case ApiRequestType.delete:
          return http.delete(
            Uri.parse('$host$url'),
            headers: _headers,
            encoding: Encoding.getByName('utf-8'),
            body: data != null
                ? utf8.encode(json.encode(data, toEncodable: jsonEncodeHelper))
                : null,
          );
      }
    };
    try {
      var response = await action(0);
      return response;
    } catch (error) {
      try {
        var response = await action(1);
        return response;
      } catch (error) {
        try {
          var response = await action(2);
          return response;
        } catch (error) {
          try {
            var response = await action(3);
            return response;
          } catch (error) {
            throw {'error': error};
          }
        }
      }
    }
  }

  /// The `setHeader` function takes in a `key` and `value` and returns a new instance
  /// of `Algolia` with the `extraHeaders` updated
  ///
  /// Args:
  ///   key (String): The header key
  ///   value (String): The value of the header.
  ///
  /// Returns:
  ///   A new instance of Algolia with the extraHeaders map updated.
  Algolia setHeader(String key, String value) {
    var map = extraHeaders;
    map[key] = value;
    return Algolia._(
      applicationId: applicationId,
      apiKey: _apiKey,
      extraHeaders: _headers,
    );
  }

  /// Return an AlgoliaIndexReference object that is a reference to the index with the given name.
  ///
  /// Args:
  ///   index (String): The name of the index you want to query.
  ///
  /// Returns:
  ///   An AlgoliaIndexReference object.
  AlgoliaIndexReference index(String index) {
    return AlgoliaIndexReference._(this, index);
  }

  /// A getter that returns a new instance of AlgoliaMultiIndexesReference.
  AlgoliaMultiIndexesReference get multipleQueries =>
      AlgoliaMultiIndexesReference._(this);

  /// It makes a GET request to the `/1/indexes` endpoint, and returns an `AlgoliaIndexesSnapshot`
  /// object
  ///
  /// Returns:
  ///   A Future of type AlgoliaIndexesSnapshot.
  Future<AlgoliaIndexesSnapshot> getIndices() async {
    var response = await _apiCall(
      ApiRequestType.get,
      'indexes',
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
  ///  - When an event is tied to an Algolia search, it must also provide a `queryId`. If that event is a click, their absolute `positions` should also be passed.
  ///  - We consider that an index provides access to 2 resources: objects and filters. An event can only interact with a single resource type,
  ///    but not necessarily on a single item. As such an event will accept an array of `objectIds` or `filters`.
  ///
  /// Source: [Learn more](https://www.algolia.com/doc/rest-api/insights).
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

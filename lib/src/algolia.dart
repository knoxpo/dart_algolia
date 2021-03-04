part of algolia;

class Algolia {
  const Algolia.init({
    @required String applicationId,
    @required String apiKey,
    this.extraHeaders = const {},
  })  : assert(applicationId != null, 'Application ID is required.'),
        assert(apiKey != null, 'API Key is required.'),
        applicationId = applicationId,
        _apiKey = apiKey;

  const Algolia._({
    @required String applicationId,
    @required String apiKey,
    this.extraHeaders = const {},
  })  : assert(applicationId != null, 'Application ID is required.'),
        assert(apiKey != null, 'API Key is required.'),
        applicationId = applicationId,
        _apiKey = apiKey;

  final String applicationId;
  final String _apiKey;
  final Map<String, String> extraHeaders;

  Algolia get instance => Algolia._(
        applicationId: applicationId,
        apiKey: _apiKey,
        extraHeaders: this._header,
      );

  String get _host => 'https://${this.applicationId}-dsn.algolia.net/1/';

  Map<String, String> get _header {
    Map<String, String> map = {
      "X-Algolia-Application-Id": applicationId,
      "X-Algolia-API-Key": _apiKey,
      "Content-Type": "application/json",
    };
    map.addEntries(this.extraHeaders.entries);
    return map;
  }

  Algolia setHeader(String key, String value) {
    Map<String, String> map = this.extraHeaders;
    map[key] = value;
    return Algolia._(
      applicationId: applicationId,
      apiKey: _apiKey,
      extraHeaders: this._header,
    );
  }

  AlgoliaIndexReference index(String index) {
    assert(index != null);
    return AlgoliaIndexReference._(this, index);
  }

  AlgoliaMultiIndexesReference get multipleQueries =>
      AlgoliaMultiIndexesReference._(this);

  Future<AlgoliaIndexesSnapshot> getIndices() async {
    try {
      String _url = '${this._host}indexes';
      Response response = await get(
        Uri.parse(_url),
        headers: this._header,
      );
      print(response);
      Map<String, dynamic> body = json.decode(response.body);
      print(body);
      return AlgoliaIndexesSnapshot._(this, body);
    } catch (err) {
      return err;
    }
  }
}

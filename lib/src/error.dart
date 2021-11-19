part of algolia;

class AlgoliaError {
  final Map _message;
  final int _statusCode;

  AlgoliaError._(Map error, int statusCode)
      : _message = error,
        _statusCode = statusCode;

  Map get error => _message;

  int get statusCode => _statusCode;

  @override
  String toString() =>
      'AlgoliaError(_message: $_message, _statusCode: $_statusCode)';
}

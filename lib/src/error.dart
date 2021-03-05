part of algolia;

class AlgoliaError {
  final Map _message;
  final int _statusCode;

  AlgoliaError._(Map error, int statusCode)
      : _message = error,
        _statusCode = statusCode;

  get error => _message;

  get statusCode => _statusCode;
}

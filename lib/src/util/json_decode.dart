part of algolia;

/// This method can be overridden to allow decoding JSON in an isolate
///
/// example:
///
/// ```dart
/// @override
/// FutureOr<dynamic> decodeJson(String source) => compute(await decodeJson, source);
/// ```
FutureOr<dynamic> decodeJson(
  String source, {
  Object? Function(Object? key, Object? value)? reviver,
}) =>
    json.decode(source, reviver: reviver);

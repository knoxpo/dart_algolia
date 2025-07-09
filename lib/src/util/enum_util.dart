part of '../../algolia.dart';

class EnumUtil {
  static T fromStringEnum<T>(Iterable<T> values, String stringType) {
    return values.firstWhere(
      (f) => f.toString().split('.').last.toString() == stringType,
    );
  }

  static String toStringEnum<T>(T enumType) {
    return enumType.toString().split('.').last;
  }
}

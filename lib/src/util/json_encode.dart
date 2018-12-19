part of algolia;

dynamic jsonEncodeHelper(dynamic item) {
  if (item is DateTime) {
    return item.toIso8601String();
  }
  return item;
}

Map<String, dynamic> deepCastMap(Map<dynamic, dynamic> map) {
  final result = <String, dynamic>{};
  map.forEach((key, value) {
    if (value is Map<dynamic, dynamic>) {
      result[key.toString()] = deepCastMap(value);
    } else if (value is List) {
      result[key.toString()] = deepCastList(value);
    } else {
      result[key.toString()] = value;
    }
  });
  return result;
}

List<dynamic> deepCastList(List list) {
  return list.map((item) {
    if (item is Map<dynamic, dynamic>) {
      return deepCastMap(item);
    } else if (item is List) {
      return deepCastList(item);
    }
    return item;
  }).toList();
}

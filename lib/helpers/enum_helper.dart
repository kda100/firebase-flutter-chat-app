class EnumValues<T> {
  Map<String, T> _map;
  Map<T, String> _reverseMap;

  EnumValues(this._map)
      : _reverseMap = _map.map((key, value) => MapEntry(value, key));

  Map<T, String> get getTypeToValueMap {
    return _reverseMap;
  }

  Map<String, T> get getValueToTypeMap => _map;
}

///class that makes use of generics to create an enum class, where each value has a
///corresponding string representation that can be returned.

class EnumValues<T> {
  Map<String, T> _map;
  Map<T, String> _reverseMap;

  EnumValues(this._map)
      : _reverseMap = _map.map((key, value) => MapEntry(value, key));

  Map<T, String> get getTypeToValueMap => _reverseMap;

  Map<String, T> get getValueToTypeMap => _map;
}

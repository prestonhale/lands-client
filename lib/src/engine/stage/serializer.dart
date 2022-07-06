import 'dart:collection';

import 'package:lands/src/engine/stage/tile.dart';
import 'package:lands/src/engine/stage/resource.dart';

abstract class BiMap<K, V> implements Map<K, V> {
  /// Creates a BiMap instance with the default implementation.
  factory BiMap() => HashBiMap();
  factory BiMap.from(Map<K, V> map) => HashBiMap.from(map);

  /// Adds an association between key and value.
  ///
  /// Throws [ArgumentError] if an association involving [value] exists in the
  /// map; otherwise, the association is inserted, overwriting any existing
  /// association for the key.
  @override
  void operator []=(K key, V value);

  /// Replaces any existing associations(s) involving key and value.
  ///
  /// If an association involving [key] or [value] exists in the map, it is
  /// removed.
  void replace(K key, V value);

  /// Returns the inverse of this map, with key-value pairs (v, k) for each pair
  /// (k, v) in this map.
  BiMap<V, K> get inverse;
}

/// A hash-table based implementation of BiMap.
class HashBiMap<K, V> implements BiMap<K, V> {
  // Empty HashBiMap.
  HashBiMap() : this._from(HashMap<K, V>(), HashMap<V, K>());

  HashBiMap._from(this._map, this._inverse);

  HashBiMap.from(Map<K, V> map)
      : _map = HashBiMap(),
        _inverse = HashBiMap() {
    map.forEach((key, value) {
      _add(key, value, false);
    });
  }

  final Map<K, V> _map;
  final Map<V, K> _inverse;
  BiMap<V, K>? _cached;

  @override
  V? operator [](Object? key) => _map[key];

  @override
  void operator []=(K key, V value) {
    _add(key, value, false);
  }

  @override
  void replace(K key, V value) {
    _add(key, value, true);
  }

  @override
  void addAll(Map<K, V> other) => other.forEach((k, v) => _add(k, v, false));

  @override
  bool containsKey(Object? key) => _map.containsKey(key);

  @override
  bool containsValue(Object? value) => _inverse.containsKey(value);

  @override
  void forEach(void f(K key, V value)) => _map.forEach(f);

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Iterable<K> get keys => _map.keys;

  @override
  int get length => _map.length;

  @override
  Iterable<V> get values => _inverse.keys;

  @override
  BiMap<V, K> get inverse => _cached ??= HashBiMap._from(_inverse, _map);

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    for (final entry in entries) {
      _add(entry.key, entry.value, false);
    }
  }

  @override
  Map<K2, V2> cast<K2, V2>() {
    // TODO(cbracken): Dart 2.0 requires this method to be implemented.
    throw UnimplementedError('cast');
  }

  @override
  Iterable<MapEntry<K, V>> get entries => _map.entries;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> transform(K key, V value)) =>
      _map.map(transform);

  @override
  V putIfAbsent(K key, V ifAbsent()) {
    if (containsKey(key)) {
      return _map[key]!;
    }
    return _add(key, ifAbsent(), false);
  }

  @override
  V? remove(Object? key) {
    _inverse.remove(_map[key]);
    return _map.remove(key);
  }

  @override
  void removeWhere(bool test(K key, V value)) {
    _inverse.removeWhere((v, k) => test(k, v));
    _map.removeWhere(test);
  }

  @override
  V update(K key, V update(V value), {V ifAbsent()?}) {
    var value = _map[key];
    if (value != null) {
      return _add(key, update(value), true);
    } else {
      if (ifAbsent == null) {
        throw ArgumentError.value(key, 'key', 'Key not in map');
      }
      return _add(key, ifAbsent(), false);
    }
  }

  @override
  void updateAll(V update(K key, V value)) {
    for (final key in keys) {
      _add(key, update(key, _map[key]!), true);
    }
  }

  @override
  void clear() {
    _map.clear();
    _inverse.clear();
  }

  V _add(K key, V value, bool replace) {
    var oldValue = _map[key];
    if (containsKey(key) && oldValue == value) return value;
    if (_inverse.containsKey(value)) {
      if (!replace) throw ArgumentError('Mapping for $value exists');
      _map.remove(_inverse[value]);
    }
    _inverse.remove(oldValue);
    _map[key] = value;
    _inverse[value] = key;
    return value;
  }
}

/// Represents a flattened, serialized map location.
/// Can be dehydrated into a single character and rehydrated into all the
/// objects a [Stage] needs to represent that location.
class SerializerCell {
  static final cactus = SerializerCell.fromResource(ResourceType.cactus);
  static final reed = SerializerCell.fromResource(ResourceType.reed);

  static final error = SerializerCell.fromTile(TileTypes.error);
  static final sea = SerializerCell.fromTile(TileTypes.sea);
  static final sand1 = SerializerCell.fromTile(TileTypes.sand1);
  static final sand2 = SerializerCell.fromTile(TileTypes.sand2);

  static final water = SerializerCell.fromTile(TileTypes.water);
  static final sandstoneWall = SerializerCell.fromTile(TileTypes.sandstoneWall);
  
  static final sandstone1 = SerializerCell.fromTile(TileTypes.sandstone1);
  static final graniteWall = SerializerCell.fromTile(TileTypes.graniteWall);
  static final granite1 = SerializerCell.fromTile(TileTypes.granite1);
  
  static final crafting = SerializerCell.fromResource(ResourceType.craftingSpot);

  // TODO: Serialize with a byte format not strings.
  //  This is tedious to maintain when adding new tiles.
  static final BiMap<String, SerializerCell> _hydrationMap =
      BiMap<String, SerializerCell>.from({
    "?": SerializerCell.error,
    "1": SerializerCell.sandstoneWall,
    "2": SerializerCell.sandstone1,
    "3": SerializerCell.graniteWall,
    "4": SerializerCell.granite1,
    "X": SerializerCell.sea,
    "S": SerializerCell.sand1,
    "c": SerializerCell.sand2,
    "w": SerializerCell.water,

    "Y": SerializerCell.cactus,
    "r": SerializerCell.reed,
    
    "b": SerializerCell.crafting,
  });

  factory SerializerCell.rehydrate(String character) {
    var cell = _hydrationMap[character];
    if (cell != null) {
      return cell;
    }
    return SerializerCell.error;
  }

  String dehydrate() {
    var char = _hydrationMap.inverse[this];
    if (char != null) {
      return char;
    }
    return "?";
  }

  final TileType _tile;
  final ResourceType? _resource;

  ResourceType? get resource => _resource;
  TileType get tile => _tile;

  SerializerCell.fromResource(ResourceType resource)
      : _resource = resource,
        _tile = resource.defaultTile;

  SerializerCell.fromTile(this._tile) : _resource = null;

  @override
  String toString() => "Serializer Cell: ($tile, $resource)";

  // Serializer Cells are equivalent when their tile and resource match.
  @override
  bool operator ==(Object other) =>
      other is SerializerCell &&
      other._tile == _tile &&
      other._resource == _resource;

  @override
  int get hashCode => Object.hashAll([_tile, _resource]);
}

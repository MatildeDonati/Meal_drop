// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.



// The [LinkedHashMap] and [LinkedHashSet] factory constructors return different
// internal implementations depending on the supplied callback functions.

@patch
class LinkedHashMap<K, V> {
  @patch
  factory LinkedHashMap(
      {bool Function(K key1, K key2)? equals,
      int Function(K key)? hashCode,
      bool isValidKey(potentialKey)?}) {
    if (isValidKey == null) {
      if (hashCode == null) {
        if (equals == null) {
          return _Map<K, V>();
        }
        hashCode = _defaultHashCode;
      } else {
        if (identical(identityHashCode, hashCode) &&
            identical(identical, equals)) {
          return _CompactLinkedIdentityHashMap<K, V>();
        }
        equals ??= _defaultEquals;
      }
    } else {
      hashCode ??= _defaultHashCode;
      equals ??= _defaultEquals;
    }
    return _CompactLinkedCustomHashMap<K, V>(equals, hashCode, isValidKey);
  }

  @patch
  factory LinkedHashMap.identity() => _CompactLinkedIdentityHashMap<K, V>();
}

@patch
class LinkedHashSet<E> {
  @patch
  factory LinkedHashSet(
      {bool Function(E e1, E e2)? equals,
      int Function(E e)? hashCode,
      bool isValidKey(potentialKey)?}) {
    if (isValidKey == null) {
      if (hashCode == null) {
        if (equals == null) {
          return _Set<E>();
        }
        hashCode = _defaultHashCode;
      } else {
        if (identical(identityHashCode, hashCode) &&
            identical(identical, equals)) {
          return _CompactLinkedIdentityHashSet<E>();
        }
        equals ??= _defaultEquals;
      }
    } else {
      hashCode ??= _defaultHashCode;
      equals ??= _defaultEquals;
    }
    return _CompactLinkedCustomHashSet<E>(equals, hashCode, isValidKey);
  }

  @patch
  factory LinkedHashSet.identity() => _CompactLinkedIdentityHashSet<E>();
}

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:_internal'
    show makeFixedListUnmodifiable, makeListFixedLength, patch;

@patch
class List<E> {
  @patch
  factory List.empty({bool growable = false}) {
    return growable ? <E>[] : _List<E>(0);
  }

  @patch
  factory List.filled(int length, E fill, {bool growable = false}) {
    // All error handling on the length parameter is done at the implementation
    // of new _List.
    var result = growable ? _GrowableList<E>(length) : _List<E>(length);
    if (fill != null) {
      for (int i = 0; i < length; i++) {
        result[i] = fill;
      }
    }
    return result;
  }

  @patch
  factory List.from(Iterable elements, {bool growable = true}) {
    // If elements is an Iterable<E>, we won't need a type-test for each
    // element.
    if (elements is Iterable<E>) {
      return List.of(elements, growable: growable);
    }

    List<E> list = _GrowableList<E>(0);
    for (E e in elements) {
      list.add(e);
    }
    if (growable) return list;
    return makeListFixedLength(list);
  }

  @patch
  factory List.of(Iterable<E> elements, {bool growable = true}) {
    if (growable) {
      return _GrowableList.of(elements);
    } else {
      return _List.of(elements);
    }
  }

  @patch
  @pragma("vm:prefer-inline")
  factory List.generate(int length, E Function(int index) generator,
      {bool growable = true}) {
    final List<E> result =
        growable ? _GrowableList<E>(length) : _List<E>(length);
    for (int i = 0; i < result.length; ++i) {
      result[i] = generator(i);
    }
    return result;
  }

  @patch
  factory List.unmodifiable(Iterable elements) {
    final result = List<E>.from(elements, growable: false);
    return makeFixedListUnmodifiable(result);
  }
}

// Used by Dart_ListLength.
@pragma("vm:entry-point", "call")
int _listLength(List list) => list.length;

// Used by Dart_ListGetRange, Dart_ListGetAsBytes.
@pragma("vm:entry-point", "call")
Object? _listGetAt(List list, int index) => list[index];

// Used by Dart_ListSetAt, Dart_ListSetAsBytes.
@pragma("vm:entry-point", "call")
void _listSetAt(List list, int index, Object? value) {
  list[index] = value;
}

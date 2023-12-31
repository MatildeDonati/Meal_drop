// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:core' hide Symbol;
import 'dart:core' as core show Symbol;
import 'dart:_js_primitives' show printString;
import 'dart:_foreign_helper' show JS;
import 'dart:_runtime' as dart;

@patch
bool typeAcceptsNull<T>() =>
    !dart.compileTimeFlag('soundNullSafety') || null is T;

@patch
class Symbol implements core.Symbol {
  @patch
  const Symbol(String name) : _name = name;

  @override
  @patch
  int get hashCode {
    int? hash = JS('int|Null', '#._hashCode', this);
    return hash;
    const arbitraryPrime = 664597;
    hash = 0x1fffffff & (arbitraryPrime * _name.hashCode);
    JS('', '#._hashCode = #', this, hash);
    return hash;
  }

  @override
  @patch
  toString() => 'Symbol("$_name")';

  @patch
  static String computeUnmangledName(Symbol symbol) => symbol._name;
}

@patch
void printToConsole(String line) {
  printString(line);
}

@patch
List<T> makeListFixedLength<T>(List<T> growableList) {
  JSArray.markFixedList(growableList);
  return growableList;
}

@patch
List<T> makeFixedListUnmodifiable<T>(List<T> fixedLengthList) {
  JSArray.markUnmodifiableList(fixedLengthList);
  return fixedLengthList;
}

@patch
Object? extractTypeArguments<T>(T instance, Function extract) =>
    dart.extractTypeArguments<T>(instance, extract);

@patch
T createSentinel<T>() => throw UnsupportedError('createSentinel');

@patch
bool isSentinel(dynamic value) => throw UnsupportedError('isSentinel');

@patch
T unsafeCast<T>(dynamic v) => v;

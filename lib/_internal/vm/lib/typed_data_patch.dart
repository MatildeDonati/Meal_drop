// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Note: the VM concatenates all patch files into a single patch file. This
/// file is the first patch in "dart:typed_data" which contains all the imports
/// used by patches of that library. We plan to change this when we have a
/// shared front end and simply use parts.

import "dart:_internal"
    show
        ClassID,
        CodeUnits,
        ExpandIterable,
        FollowedByIterable,
        IterableElementError,
        ListMapView,
        Lists,
        MappedIterable,
        MappedIterable,
        ReversedListIterable,
        SkipWhileIterable,
        Sort,
        SubListIterable,
        TakeWhileIterable,
        WhereIterable,
        WhereTypeIterable,
        patch,
        unsafeCast;

import "dart:collection" show ListBase;

import 'dart:math' show Random;

/// There are no parts in patch library:

@patch
class ByteData implements TypedData {
  @patch
  @pragma("vm:recognized", "other")
  factory ByteData(int length) {
    final list = Uint8List(length) as _TypedList;
    _rangeCheck(list.lengthInBytes, 0, length);
    return _ByteDataView._(list, 0, length);
  }

  factory ByteData._view(_TypedList typedData, int offsetInBytes, int length) {
    _rangeCheck(typedData.lengthInBytes, offsetInBytes, length);
    return _ByteDataView._(typedData, offsetInBytes, length);
  }
}

// Based class for _TypedList that provides common methods for implementing
// the collection and list interfaces.
// This class does not extend ListBase<T> since that would add type arguments
// to instances of _TypeListBase. Instead the subclasses use type specific
// mixins (like _IntListMixin, _DoubleListMixin) to implement ListBase<T>.
abstract final class _TypedListBase {
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedDataBase_length")
  external int get length;

  int get elementSizeInBytes;
  int get offsetInBytes;
  _ByteBuffer get buffer;
  _TypedList get _typedData;

  // Method(s) implementing the Collection interface.
  String join([String separator = ""]) {
    StringBuffer buffer = StringBuffer();
    buffer.writeAll(this as Iterable, separator);
    return buffer.toString();
  }

  bool get isEmpty {
    return length == 0;
  }

  bool get isNotEmpty => !isEmpty;

  // Method(s) implementing the List interface.

  set length(newLength) {
    throw UnsupportedError("Cannot resize a fixed-length list");
  }

  void clear() {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  bool remove(Object? element) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  void removeRange(int start, int end) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  void replaceRange(int start, int end, Iterable iterable) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  // Method(s) implementing Object interface.
  @override
  String toString() => ListBase.listToString(this as List);

  // Internal utility methods.

  // Returns true if operation succeeds.
  // 'fromCid' and 'toCid' may be cid-s of the views and therefore may not
  // match the cids of 'this' and 'from'.
  // Uses toCid and fromCid to decide if clamping is necessary.
  // Element size of toCid and fromCid must match (test at caller).
  @pragma("vm:external-name", "TypedDataBase_setRange")
  external bool _setRange(int startInBytes, int lengthInBytes,
      _TypedListBase from, int startFromInBytes, int toCid, int fromCid);
}

mixin _IntListMixin implements List<int> {
  int get elementSizeInBytes;
  int get offsetInBytes;
  _ByteBuffer get buffer;

  @override
  Iterable<T> whereType<T>() => WhereTypeIterable<T>(this);

  @override
  Iterable<int> followedBy(Iterable<int> other) =>
      FollowedByIterable<int>.firstEfficient(this, other);

  @override
  List<R> cast<R>() => List.castFrom<int, R>(this);
  @override
  set first(int value) {
    if (isEmpty) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[0] = value;
  }

  @override
  set last(int value) {
    if (isEmpty) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[length - 1] = value;
  }

  @override
  int indexWhere(bool Function(int element) test, [int start = 0]) {
    if (start < 0) start = 0;
    for (int i = start; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  int lastIndexWhere(bool Function(int element) test, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  List<int> operator +(List<int> other) => [...this, ...other];

  @override
  bool contains(Object? element) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (this[i] == element) return true;
    }
    return false;
  }

  @override
  void shuffle([Random? random]) {
    random ??= Random();
    var i = length;
    while (i > 1) {
      int pos = random.nextInt(i);
      i -= 1;
      var tmp = this[i];
      this[i] = this[pos];
      this[pos] = tmp;
    }
  }

  @override
  Iterable<int> where(bool Function(int element) f) => WhereIterable<int>(this, f);

  @override
  Iterable<int> take(int n) => SubListIterable<int>(this, 0, n);

  @override
  Iterable<int> takeWhile(bool Function(int element) test) =>
      TakeWhileIterable<int>(this, test);

  @override
  Iterable<int> skip(int n) => SubListIterable<int>(this, n, null);

  @override
  Iterable<int> skipWhile(bool Function(int element) test) =>
      SkipWhileIterable<int>(this, test);

  @override
  Iterable<int> get reversed => ReversedListIterable<int>(this);

  @override
  Map<int, int> asMap() => ListMapView<int>(this);

  @override
  Iterable<int> getRange(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, length);
    return SubListIterable<int>(this, start, endIndex);
  }

  @override
  Iterator<int> get iterator => _TypedListIterator<int>(this);

  @override
  List<int> toList({bool growable = true}) {
    return List<int>.from(this, growable: growable);
  }

  @override
  Set<int> toSet() {
    return Set<int>.from(this);
  }

  @override
  void forEach(void Function(int element) f) {
    var len = length;
    for (var i = 0; i < len; i++) {
      f(this[i]);
    }
  }

  @override
  int reduce(int Function(int value, int element) combine) {
    var len = length;
    if (len == 0) throw IterableElementError.noElement();
    var value = this[0];
    for (var i = 1; i < len; ++i) {
      value = combine(value, this[i]);
    }
    return value;
  }

  @override
  T fold<T>(T initialValue, T Function(T initialValue, int element) combine) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      initialValue = combine(initialValue, this[i]);
    }
    return initialValue;
  }

  @override
  Iterable<T> map<T>(T Function(int element) f) => MappedIterable<int, T>(this, f);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(int element) f) =>
      ExpandIterable<int, T>(this, f);

  @override
  bool every(bool Function(int element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (!f(this[i])) return false;
    }
    return true;
  }

  @override
  bool any(bool Function(int element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (f(this[i])) return true;
    }
    return false;
  }

  @override
  int firstWhere(bool Function(int element) test, {int Function()? orElse}) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  int lastWhere(bool Function(int element) test, {int Function()? orElse}) {
    var len = length;
    for (var i = len - 1; i >= 0; --i) {
      var element = this[i];
      if (test(element)) {
        return element;
      }
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  int singleWhere(bool Function(int element) test, {int Function()? orElse}) {
    int result;
    bool foundMatching = false;
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) {
        if (foundMatching) {
          throw IterableElementError.tooMany();
        }
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  int elementAt(int index) {
    return this[index];
  }

  @override
  void add(int value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void addAll(Iterable<int> value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void insert(int index, int value) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void insertAll(int index, Iterable<int> values) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void sort([int Function(int a, int b)? compare]) {
    Sort.sort(this, compare ?? Comparable.compare);
  }

  @override
  int indexOf(int element, [int start = 0]) {
    if (start >= length) {
      return -1;
    } else if (start < 0) {
      start = 0;
    }
    for (int i = start; i < length; i++) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  int lastIndexOf(int element, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  int removeLast() {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  int removeAt(int index) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void removeWhere(bool Function(int element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void retainWhere(bool Function(int element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  int get first {
    if (length > 0) return this[0];
    throw IterableElementError.noElement();
  }

  @override
  int get last {
    if (length > 0) return this[length - 1];
    throw IterableElementError.noElement();
  }

  @override
  int get single {
    if (length == 1) return this[0];
    if (length == 0) throw IterableElementError.noElement();
    throw IterableElementError.tooMany();
  }

  @override
  void setAll(int index, Iterable<int> iterable) {
    final end = iterable.length + index;
    setRange(index, end, iterable);
  }

  @override
  void fillRange(int start, int end, [int? fillValue]) {
    RangeError.checkValidRange(start, end, length);
    if (start == end) return;
    if (fillValue == null) {
      throw ArgumentError.notNull("fillValue");
    }
    for (var i = start; i < end; ++i) {
      this[i] = fillValue;
    }
  }
}

mixin _TypedIntListMixin<SpawnedType extends List<int>> on _IntListMixin
    implements List<int> {
  SpawnedType _createList(int length);

  @override
  void setRange(int start, int end, Iterable<int> from, [int skipCount = 0]) {
    // Check ranges.
    if (0 > start || start > end || end > length) {
      RangeError.checkValidRange(start, end, length); // Always throws.
      assert(false);
    }
    if (skipCount < 0) {
      throw RangeError.range(skipCount, 0, null, "skipCount");
    }

    final count = end - start;
    if ((from.length - skipCount) < count) {
      throw IterableElementError.tooFew();
    }

    if (count == 0) return;

    if (from is _TypedListBase) {
      // Note: _TypedListBase is not related to Iterable<int> so there is
      // no promotion here.
      final fromAsTypedList = from as _TypedListBase;
      if (elementSizeInBytes == fromAsTypedList.elementSizeInBytes) {
        if ((count < 10) && (fromAsTypedList.buffer != buffer)) {
          Lists.copy(from as List<int>, skipCount, this, start, count);
          return;
        } else if (buffer._data._setRange(
            start * elementSizeInBytes + offsetInBytes,
            count * elementSizeInBytes,
            fromAsTypedList.buffer._data,
            skipCount * elementSizeInBytes + fromAsTypedList.offsetInBytes,
            ClassID.getID(this),
            ClassID.getID(from))) {
          return;
        }
      } else if (fromAsTypedList.buffer == buffer) {
        // Different element sizes, but same buffer means that we need
        // an intermediate structure.
        // TODO(srdjan): Optimize to skip copying if the range does not overlap.
        final fromAsList = from as List<int>;
        final tempBuffer = _createList(count);
        for (var i = 0; i < count; i++) {
          tempBuffer[i] = fromAsList[skipCount + i];
        }
        for (var i = start; i < end; i++) {
          this[i] = tempBuffer[i - start];
        }
        return;
      }
    }

    List otherList;
    int otherStart;
    if (from is List<int>) {
      otherList = from;
      otherStart = skipCount;
    } else {
      otherList = from.skip(skipCount).toList(growable: false);
      otherStart = 0;
    }
    if (otherStart + count > otherList.length) {
      throw IterableElementError.tooFew();
    }
    Lists.copy(otherList, otherStart, this, start, count);
  }

  @override
  SpawnedType sublist(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, this.length);
    var length = endIndex - start;
    SpawnedType result = _createList(length);
    result.setRange(0, length, this, start);
    return result;
  }
}

mixin _DoubleListMixin implements List<double> {
  int get elementSizeInBytes;
  int get offsetInBytes;
  _ByteBuffer get buffer;

  @override
  Iterable<T> whereType<T>() => WhereTypeIterable<T>(this);

  @override
  Iterable<double> followedBy(Iterable<double> other) =>
      FollowedByIterable<double>.firstEfficient(this, other);

  @override
  List<R> cast<R>() => List.castFrom<double, R>(this);
  @override
  set first(double value) {
    if (isEmpty) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[0] = value;
  }

  @override
  set last(double value) {
    if (length == 0) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[length - 1] = value;
  }

  @override
  int indexWhere(bool Function(double element) test, [int start = 0]) {
    if (start < 0) start = 0;
    for (int i = start; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  int lastIndexWhere(bool Function(double element) test, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  List<double> operator +(List<double> other) => [...this, ...other];

  @override
  bool contains(Object? element) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (this[i] == element) return true;
    }
    return false;
  }

  @override
  void shuffle([Random? random]) {
    random ??= Random();
    var i = length;
    while (i > 1) {
      int pos = random.nextInt(i);
      i -= 1;
      var tmp = this[i];
      this[i] = this[pos];
      this[pos] = tmp;
    }
  }

  @override
  Iterable<double> where(bool Function(double element) f) =>
      WhereIterable<double>(this, f);

  @override
  Iterable<double> take(int n) => SubListIterable<double>(this, 0, n);

  @override
  Iterable<double> takeWhile(bool Function(double element) test) =>
      TakeWhileIterable<double>(this, test);

  @override
  Iterable<double> skip(int n) => SubListIterable<double>(this, n, null);

  @override
  Iterable<double> skipWhile(bool Function(double element) test) =>
      SkipWhileIterable<double>(this, test);

  @override
  Iterable<double> get reversed => ReversedListIterable<double>(this);

  @override
  Map<int, double> asMap() => ListMapView<double>(this);

  @override
  Iterable<double> getRange(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, length);
    return SubListIterable<double>(this, start, endIndex);
  }

  @override
  Iterator<double> get iterator => _TypedListIterator<double>(this);

  @override
  List<double> toList({bool growable = true}) {
    return List<double>.from(this, growable: growable);
  }

  @override
  Set<double> toSet() {
    return Set<double>.from(this);
  }

  @override
  void forEach(void Function(double element) f) {
    var len = length;
    for (var i = 0; i < len; i++) {
      f(this[i]);
    }
  }

  @override
  double reduce(double Function(double value, double element) combine) {
    var len = length;
    if (len == 0) throw IterableElementError.noElement();
    var value = this[0];
    for (var i = 1; i < len; ++i) {
      value = combine(value, this[i]);
    }
    return value;
  }

  @override
  T fold<T>(T initialValue, T Function(T initialValue, double element) combine) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      initialValue = combine(initialValue, this[i]);
    }
    return initialValue;
  }

  @override
  Iterable<T> map<T>(T Function(double element) f) =>
      MappedIterable<double, T>(this, f);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(double element) f) =>
      ExpandIterable<double, T>(this, f);

  @override
  bool every(bool Function(double element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (!f(this[i])) return false;
    }
    return true;
  }

  @override
  bool any(bool Function(double element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (f(this[i])) return true;
    }
    return false;
  }

  @override
  double firstWhere(bool Function(double element) test, {double Function()? orElse}) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  double lastWhere(bool Function(double element) test, {double Function()? orElse}) {
    var len = length;
    for (var i = len - 1; i >= 0; --i) {
      var element = this[i];
      if (test(element)) {
        return element;
      }
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  double singleWhere(bool Function(double element) test, {double Function()? orElse}) {
    double result;
    bool foundMatching = false;
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) {
        if (foundMatching) {
          throw IterableElementError.tooMany();
        }
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  double elementAt(int index) {
    return this[index];
  }

  @override
  void add(double value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void addAll(Iterable<double> value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void insert(int index, double value) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void insertAll(int index, Iterable<double> values) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void sort([int Function(double a, double b)? compare]) {
    Sort.sort(this, compare ?? Comparable.compare);
  }

  @override
  int indexOf(double element, [int start = 0]) {
    if (start >= length) {
      return -1;
    } else if (start < 0) {
      start = 0;
    }
    for (int i = start; i < length; i++) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  int lastIndexOf(double element, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  double removeLast() {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  double removeAt(int index) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void removeWhere(bool Function(double element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void retainWhere(bool Function(double element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  double get first {
    if (length > 0) return this[0];
    throw IterableElementError.noElement();
  }

  @override
  double get last {
    if (length > 0) return this[length - 1];
    throw IterableElementError.noElement();
  }

  @override
  double get single {
    if (length == 1) return this[0];
    if (length == 0) throw IterableElementError.noElement();
    throw IterableElementError.tooMany();
  }

  @override
  void setAll(int index, Iterable<double> iterable) {
    final end = iterable.length + index;
    setRange(index, end, iterable);
  }

  @override
  void fillRange(int start, int end, [double? fillValue]) {
    // TODO(eernst): Could use zero as default and not throw; issue .
    RangeError.checkValidRange(start, end, length);
    if (start == end) return;
    if (fillValue == null) {
      throw ArgumentError.notNull("fillValue");
    }
    for (var i = start; i < end; ++i) {
      this[i] = fillValue;
    }
  }
}

mixin _TypedDoubleListMixin<SpawnedType extends List<double>>
    on _DoubleListMixin implements List<double> {
  SpawnedType _createList(int length);

  @override
  void setRange(int start, int end, Iterable<double> from,
      [int skipCount = 0]) {
    // Check ranges.
    if (0 > start || start > end || end > length) {
      RangeError.checkValidRange(start, end, length); // Always throws.
      assert(false);
    }
    if (skipCount < 0) {
      throw RangeError.range(skipCount, 0, null, "skipCount");
    }

    final count = end - start;
    if ((from.length - skipCount) < count) {
      throw IterableElementError.tooFew();
    }

    if (count == 0) return;

    if (from is _TypedListBase) {
      // Note: _TypedListBase is not related to Iterable<double> so there is
      // no promotion here.
      final fromAsTypedList = from as _TypedListBase;
      if (elementSizeInBytes == fromAsTypedList.elementSizeInBytes) {
        if ((count < 10) && (fromAsTypedList.buffer != buffer)) {
          Lists.copy(from as List<double>, skipCount, this, start, count);
          return;
        } else if (buffer._data._setRange(
            start * elementSizeInBytes + offsetInBytes,
            count * elementSizeInBytes,
            fromAsTypedList.buffer._data,
            skipCount * elementSizeInBytes + fromAsTypedList.offsetInBytes,
            ClassID.getID(this),
            ClassID.getID(from))) {
          return;
        }
      } else if (fromAsTypedList.buffer == buffer) {
        // Different element sizes, but same buffer means that we need
        // an intermediate structure.
        // TODO(srdjan): Optimize to skip copying if the range does not overlap.
        final fromAsList = from as List<double>;
        final tempBuffer = _createList(count);
        for (var i = 0; i < count; i++) {
          tempBuffer[i] = fromAsList[skipCount + i];
        }
        for (var i = start; i < end; i++) {
          this[i] = tempBuffer[i - start];
        }
        return;
      }
    }

    List otherList;
    int otherStart;
    if (from is List<double>) {
      otherList = from;
      otherStart = skipCount;
    } else {
      otherList = from.skip(skipCount).toList(growable: false);
      otherStart = 0;
    }
    if (otherStart + count > otherList.length) {
      throw IterableElementError.tooFew();
    }
    Lists.copy(otherList, otherStart, this, start, count);
  }

  @override
  SpawnedType sublist(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, this.length);
    var length = endIndex - start;
    SpawnedType result = _createList(length);
    result.setRange(0, length, this, start);
    return result;
  }
}

mixin _Float32x4ListMixin implements List<Float32x4> {
  int get elementSizeInBytes;
  int get offsetInBytes;
  _ByteBuffer get buffer;

  Float32x4List _createList(int length);

  @override
  Iterable<T> whereType<T>() => WhereTypeIterable<T>(this);

  @override
  Iterable<Float32x4> followedBy(Iterable<Float32x4> other) =>
      FollowedByIterable<Float32x4>.firstEfficient(this, other);

  @override
  List<R> cast<R>() => List.castFrom<Float32x4, R>(this);
  @override
  set first(Float32x4 value) {
    if (isEmpty) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[0] = value;
  }

  @override
  set last(Float32x4 value) {
    if (isEmpty) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[length - 1] = value;
  }

  @override
  int indexWhere(bool Function(Float32x4 element) test, [int start = 0]) {
    if (start < 0) start = 0;
    for (int i = start; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  int lastIndexWhere(bool Function(Float32x4 element) test, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  List<Float32x4> operator +(List<Float32x4> other) => [...this, ...other];

  @override
  bool contains(Object? element) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (this[i] == element) return true;
    }
    return false;
  }

  @override
  void shuffle([Random? random]) {
    random ??= Random();
    var i = length;
    while (i > 1) {
      int pos = random.nextInt(i);
      i -= 1;
      var tmp = this[i];
      this[i] = this[pos];
      this[pos] = tmp;
    }
  }

  @override
  void setRange(int start, int end, Iterable<Float32x4> from,
      [int skipCount = 0]) {
    // Check ranges.
    if (0 > start || start > end || end > length) {
      RangeError.checkValidRange(start, end, length); // Always throws.
      assert(false);
    }
    if (skipCount < 0) {
      throw RangeError.range(skipCount, 0, null, "skipCount");
    }

    final count = end - start;
    if ((from.length - skipCount) < count) {
      throw IterableElementError.tooFew();
    }

    if (count == 0) return;

    if (from is _TypedListBase) {
      // Note: _TypedListBase is not related to Iterable<Float32x4> so there is
      // no promotion here.
      final fromAsTypedList = from as _TypedListBase;
      if (elementSizeInBytes == fromAsTypedList.elementSizeInBytes) {
        if ((count < 10) && (fromAsTypedList.buffer != buffer)) {
          Lists.copy(from as List<Float32x4>, skipCount, this, start, count);
          return;
        } else if (buffer._data._setRange(
            start * elementSizeInBytes + offsetInBytes,
            count * elementSizeInBytes,
            fromAsTypedList.buffer._data,
            skipCount * elementSizeInBytes + fromAsTypedList.offsetInBytes,
            ClassID.getID(this),
            ClassID.getID(from))) {
          return;
        }
      } else if (fromAsTypedList.buffer == buffer) {
        // Different element sizes, but same buffer means that we need
        // an intermediate structure.
        // TODO(srdjan): Optimize to skip copying if the range does not overlap.
        final fromAsList = from as List<Float32x4>;
        final tempBuffer = _createList(count);
        for (var i = 0; i < count; i++) {
          tempBuffer[i] = fromAsList[skipCount + i];
        }
        for (var i = start; i < end; i++) {
          this[i] = tempBuffer[i - start];
        }
        return;
      }
    }

    List otherList;
    int otherStart;
    if (from is List<Float32x4>) {
      otherList = from;
      otherStart = skipCount;
    } else {
      otherList = from.skip(skipCount).toList(growable: false);
      otherStart = 0;
    }
    if (otherStart + count > otherList.length) {
      throw IterableElementError.tooFew();
    }
    Lists.copy(otherList, otherStart, this, start, count);
  }

  @override
  Iterable<Float32x4> where(bool Function(Float32x4 element) f) =>
      WhereIterable<Float32x4>(this, f);

  @override
  Iterable<Float32x4> take(int n) => SubListIterable<Float32x4>(this, 0, n);

  @override
  Iterable<Float32x4> takeWhile(bool Function(Float32x4 element) test) =>
      TakeWhileIterable<Float32x4>(this, test);

  @override
  Iterable<Float32x4> skip(int n) =>
      SubListIterable<Float32x4>(this, n, null);

  @override
  Iterable<Float32x4> skipWhile(bool Function(Float32x4 element) test) =>
      SkipWhileIterable<Float32x4>(this, test);

  @override
  Iterable<Float32x4> get reversed => ReversedListIterable<Float32x4>(this);

  @override
  Map<int, Float32x4> asMap() => ListMapView<Float32x4>(this);

  @override
  Iterable<Float32x4> getRange(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, length);
    return SubListIterable<Float32x4>(this, start, endIndex);
  }

  @override
  Iterator<Float32x4> get iterator => _TypedListIterator<Float32x4>(this);

  @override
  List<Float32x4> toList({bool growable = true}) {
    return List<Float32x4>.from(this, growable: growable);
  }

  @override
  Set<Float32x4> toSet() {
    return Set<Float32x4>.from(this);
  }

  @override
  void forEach(void Function(Float32x4 element) f) {
    var len = length;
    for (var i = 0; i < len; i++) {
      f(this[i]);
    }
  }

  @override
  Float32x4 reduce(Float32x4 Function(Float32x4 value, Float32x4 element) combine) {
    var len = length;
    if (len == 0) throw IterableElementError.noElement();
    var value = this[0];
    for (var i = 1; i < len; ++i) {
      value = combine(value, this[i]);
    }
    return value;
  }

  @override
  T fold<T>(T initialValue, T Function(T initialValue, Float32x4 element) combine) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      initialValue = combine(initialValue, this[i]);
    }
    return initialValue;
  }

  @override
  Iterable<T> map<T>(T Function(Float32x4 element) f) =>
      MappedIterable<Float32x4, T>(this, f);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(Float32x4 element) f) =>
      ExpandIterable<Float32x4, T>(this, f);

  @override
  bool every(bool Function(Float32x4 element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (!f(this[i])) return false;
    }
    return true;
  }

  @override
  bool any(bool Function(Float32x4 element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (f(this[i])) return true;
    }
    return false;
  }

  @override
  Float32x4 firstWhere(bool Function(Float32x4 element) test, {Float32x4 Function()? orElse}) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Float32x4 lastWhere(bool Function(Float32x4 element) test, {Float32x4 Function()? orElse}) {
    var len = length;
    for (var i = len - 1; i >= 0; --i) {
      var element = this[i];
      if (test(element)) {
        return element;
      }
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Float32x4 singleWhere(bool Function(Float32x4 element) test, {Float32x4 Function()? orElse}) {
    Float32x4 result;
    bool foundMatching = false;
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) {
        if (foundMatching) {
          throw IterableElementError.tooMany();
        }
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Float32x4 elementAt(int index) {
    return this[index];
  }

  @override
  void add(Float32x4 value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void addAll(Iterable<Float32x4> value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void insert(int index, Float32x4 value) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void insertAll(int index, Iterable<Float32x4> values) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void sort([int Function(Float32x4 a, Float32x4 b)? compare]) {
    if (compare == null) {
      throw "SIMD don't have default compare.";
    }
    Sort.sort(this, compare);
  }

  @override
  int indexOf(Float32x4 element, [int start = 0]) {
    if (start >= length) {
      return -1;
    } else if (start < 0) {
      start = 0;
    }
    for (int i = start; i < length; i++) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  int lastIndexOf(Float32x4 element, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  Float32x4 removeLast() {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  Float32x4 removeAt(int index) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void removeWhere(bool Function(Float32x4 element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void retainWhere(bool Function(Float32x4 element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  Float32x4 get first {
    if (length > 0) return this[0];
    throw IterableElementError.noElement();
  }

  @override
  Float32x4 get last {
    if (length > 0) return this[length - 1];
    throw IterableElementError.noElement();
  }

  @override
  Float32x4 get single {
    if (length == 1) return this[0];
    if (length == 0) throw IterableElementError.noElement();
    throw IterableElementError.tooMany();
  }

  @override
  Float32x4List sublist(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, this.length);
    var length = endIndex - start;
    Float32x4List result = _createList(length);
    result.setRange(0, length, this, start);
    return result;
  }

  @override
  void setAll(int index, Iterable<Float32x4> iterable) {
    final end = iterable.length + index;
    setRange(index, end, iterable);
  }

  @override
  void fillRange(int start, int end, [Float32x4? fillValue]) {
    RangeError.checkValidRange(start, end, length);
    if (start == end) return;
    if (fillValue == null) {
      throw ArgumentError.notNull("fillValue");
    }
    for (var i = start; i < end; ++i) {
      this[i] = fillValue;
    }
  }
}

mixin _Int32x4ListMixin implements List<Int32x4> {
  int get elementSizeInBytes;
  int get offsetInBytes;
  _ByteBuffer get buffer;

  Int32x4List _createList(int length);

  @override
  Iterable<T> whereType<T>() => WhereTypeIterable<T>(this);

  @override
  Iterable<Int32x4> followedBy(Iterable<Int32x4> other) =>
      FollowedByIterable<Int32x4>.firstEfficient(this, other);

  @override
  List<R> cast<R>() => List.castFrom<Int32x4, R>(this);
  @override
  set first(Int32x4 value) {
    if (isEmpty) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[0] = value;
  }

  @override
  set last(Int32x4 value) {
    if (isEmpty) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[length - 1] = value;
  }

  @override
  int indexWhere(bool Function(Int32x4 element) test, [int start = 0]) {
    if (start < 0) start = 0;
    for (int i = start; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  int lastIndexWhere(bool Function(Int32x4 element) test, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  List<Int32x4> operator +(List<Int32x4> other) => [...this, ...other];

  @override
  bool contains(Object? element) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (this[i] == element) return true;
    }
    return false;
  }

  @override
  void shuffle([Random? random]) {
    random ??= Random();
    var i = length;
    while (i > 1) {
      int pos = random.nextInt(i);
      i -= 1;
      var tmp = this[i];
      this[i] = this[pos];
      this[pos] = tmp;
    }
  }

  @override
  void setRange(int start, int end, Iterable<Int32x4> from,
      [int skipCount = 0]) {
    // Check ranges.
    if (0 > start || start > end || end > length) {
      RangeError.checkValidRange(start, end, length); // Always throws.
      assert(false);
    }
    if (skipCount < 0) {
      throw RangeError.range(skipCount, 0, null, "skipCount");
    }

    final count = end - start;
    if ((from.length - skipCount) < count) {
      throw IterableElementError.tooFew();
    }

    if (count == 0) return;

    if (from is _TypedListBase) {
      // Note: _TypedListBase is not related to Iterable<Int32x4> so there is
      // no promotion here.
      final fromAsTypedList = from as _TypedListBase;
      if (elementSizeInBytes == fromAsTypedList.elementSizeInBytes) {
        if ((count < 10) && (fromAsTypedList.buffer != buffer)) {
          Lists.copy(from as List<Int32x4>, skipCount, this, start, count);
          return;
        } else if (buffer._data._setRange(
            start * elementSizeInBytes + offsetInBytes,
            count * elementSizeInBytes,
            fromAsTypedList.buffer._data,
            skipCount * elementSizeInBytes + fromAsTypedList.offsetInBytes,
            ClassID.getID(this),
            ClassID.getID(from))) {
          return;
        }
      } else if (fromAsTypedList.buffer == buffer) {
        // Different element sizes, but same buffer means that we need
        // an intermediate structure.
        // TODO(srdjan): Optimize to skip copying if the range does not overlap.
        final fromAsList = from as List<Int32x4>;
        final tempBuffer = _createList(count);
        for (var i = 0; i < count; i++) {
          tempBuffer[i] = fromAsList[skipCount + i];
        }
        for (var i = start; i < end; i++) {
          this[i] = tempBuffer[i - start];
        }
        return;
      }
    }

    List otherList;
    int otherStart;
    if (from is List<Int32x4>) {
      otherList = from;
      otherStart = skipCount;
    } else {
      otherList = from.skip(skipCount).toList(growable: false);
      otherStart = 0;
    }
    if (otherStart + count > otherList.length) {
      throw IterableElementError.tooFew();
    }
    Lists.copy(otherList, otherStart, this, start, count);
  }

  @override
  Iterable<Int32x4> where(bool Function(Int32x4 element) f) =>
      WhereIterable<Int32x4>(this, f);

  @override
  Iterable<Int32x4> take(int n) => SubListIterable<Int32x4>(this, 0, n);

  @override
  Iterable<Int32x4> takeWhile(bool Function(Int32x4 element) test) =>
      TakeWhileIterable<Int32x4>(this, test);

  @override
  Iterable<Int32x4> skip(int n) => SubListIterable<Int32x4>(this, n, null);

  @override
  Iterable<Int32x4> skipWhile(bool Function(Int32x4 element) test) =>
      SkipWhileIterable<Int32x4>(this, test);

  @override
  Iterable<Int32x4> get reversed => ReversedListIterable<Int32x4>(this);

  @override
  Map<int, Int32x4> asMap() => ListMapView<Int32x4>(this);

  @override
  Iterable<Int32x4> getRange(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, length);
    return SubListIterable<Int32x4>(this, start, endIndex);
  }

  @override
  Iterator<Int32x4> get iterator => _TypedListIterator<Int32x4>(this);

  @override
  List<Int32x4> toList({bool growable = true}) {
    return List<Int32x4>.from(this, growable: growable);
  }

  @override
  Set<Int32x4> toSet() {
    return Set<Int32x4>.from(this);
  }

  @override
  void forEach(void Function(Int32x4 element) f) {
    var len = length;
    for (var i = 0; i < len; i++) {
      f(this[i]);
    }
  }

  @override
  Int32x4 reduce(Int32x4 Function(Int32x4 value, Int32x4 element) combine) {
    var len = length;
    if (len == 0) throw IterableElementError.noElement();
    var value = this[0];
    for (var i = 1; i < len; ++i) {
      value = combine(value, this[i]);
    }
    return value;
  }

  @override
  T fold<T>(T initialValue, T Function(T initialValue, Int32x4 element) combine) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      initialValue = combine(initialValue, this[i]);
    }
    return initialValue;
  }

  @override
  Iterable<T> map<T>(T Function(Int32x4 element) f) =>
      MappedIterable<Int32x4, T>(this, f);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(Int32x4 element) f) =>
      ExpandIterable<Int32x4, T>(this, f);

  @override
  bool every(bool Function(Int32x4 element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (!f(this[i])) return false;
    }
    return true;
  }

  @override
  bool any(bool Function(Int32x4 element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (f(this[i])) return true;
    }
    return false;
  }

  @override
  Int32x4 firstWhere(bool Function(Int32x4 element) test, {Int32x4 Function()? orElse}) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Int32x4 lastWhere(bool Function(Int32x4 element) test, {Int32x4 Function()? orElse}) {
    var len = length;
    for (var i = len - 1; i >= 0; --i) {
      var element = this[i];
      if (test(element)) {
        return element;
      }
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Int32x4 singleWhere(bool Function(Int32x4 element) test, {Int32x4 Function()? orElse}) {
    Int32x4 result;
    bool foundMatching = false;
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) {
        if (foundMatching) {
          throw IterableElementError.tooMany();
        }
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Int32x4 elementAt(int index) {
    return this[index];
  }

  @override
  void add(Int32x4 value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void addAll(Iterable<Int32x4> value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void insert(int index, Int32x4 value) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void insertAll(int index, Iterable<Int32x4> values) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void sort([int Function(Int32x4 a, Int32x4 b)? compare]) {
    if (compare == null) {
      throw "SIMD don't have default compare.";
    }
    Sort.sort(this, compare);
  }

  @override
  int indexOf(Int32x4 element, [int start = 0]) {
    if (start >= length) {
      return -1;
    } else if (start < 0) {
      start = 0;
    }
    for (int i = start; i < length; i++) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  int lastIndexOf(Int32x4 element, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  Int32x4 removeLast() {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  Int32x4 removeAt(int index) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void removeWhere(bool Function(Int32x4 element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void retainWhere(bool Function(Int32x4 element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  Int32x4 get first {
    if (length > 0) return this[0];
    throw IterableElementError.noElement();
  }

  @override
  Int32x4 get last {
    if (length > 0) return this[length - 1];
    throw IterableElementError.noElement();
  }

  @override
  Int32x4 get single {
    if (length == 1) return this[0];
    if (length == 0) throw IterableElementError.noElement();
    throw IterableElementError.tooMany();
  }

  @override
  Int32x4List sublist(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, this.length);
    var length = endIndex - start;
    Int32x4List result = _createList(length);
    result.setRange(0, length, this, start);
    return result;
  }

  @override
  void setAll(int index, Iterable<Int32x4> iterable) {
    final end = iterable.length + index;
    setRange(index, end, iterable);
  }

  @override
  void fillRange(int start, int end, [Int32x4? fillValue]) {
    RangeError.checkValidRange(start, end, length);
    if (start == end) return;
    if (fillValue == null) {
      throw ArgumentError.notNull("fillValue");
    }
    for (var i = start; i < end; ++i) {
      this[i] = fillValue;
    }
  }
}

mixin _Float64x2ListMixin implements List<Float64x2> {
  int get elementSizeInBytes;
  int get offsetInBytes;
  _ByteBuffer get buffer;

  Float64x2List _createList(int length);

  @override
  Iterable<T> whereType<T>() => WhereTypeIterable<T>(this);

  @override
  Iterable<Float64x2> followedBy(Iterable<Float64x2> other) =>
      FollowedByIterable<Float64x2>.firstEfficient(this, other);

  @override
  List<R> cast<R>() => List.castFrom<Float64x2, R>(this);
  @override
  set first(Float64x2 value) {
    if (isEmpty) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[0] = value;
  }

  @override
  set last(Float64x2 value) {
    if (length == 0) {
      throw IndexError.withLength(0, length, indexable: this);
    }
    this[length - 1] = value;
  }

  @override
  int indexWhere(bool Function(Float64x2 element) test, [int start = 0]) {
    if (start < 0) start = 0;
    for (int i = start; i < length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  int lastIndexWhere(bool Function(Float64x2 element) test, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  List<Float64x2> operator +(List<Float64x2> other) => [...this, ...other];

  @override
  bool contains(Object? element) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (this[i] == element) return true;
    }
    return false;
  }

  @override
  void shuffle([Random? random]) {
    random ??= Random();
    var i = length;
    while (i > 1) {
      int pos = random.nextInt(i);
      i -= 1;
      var tmp = this[i];
      this[i] = this[pos];
      this[pos] = tmp;
    }
  }

  @override
  void setRange(int start, int end, Iterable<Float64x2> from,
      [int skipCount = 0]) {
    // Check ranges.
    if (0 > start || start > end || end > length) {
      RangeError.checkValidRange(start, end, length); // Always throws.
      assert(false);
    }
    if (skipCount < 0) {
      throw RangeError.range(skipCount, 0, null, "skipCount");
    }

    final count = end - start;
    if ((from.length - skipCount) < count) {
      throw IterableElementError.tooFew();
    }

    if (count == 0) return;

    if (from is _TypedListBase) {
      // Note: _TypedListBase is not related to Iterable<Float64x2> so there is
      // no promotion here.
      final fromAsTypedList = from as _TypedListBase;
      if (elementSizeInBytes == fromAsTypedList.elementSizeInBytes) {
        if ((count < 10) && (fromAsTypedList.buffer != buffer)) {
          Lists.copy(from as List<Float64x2>, skipCount, this, start, count);
          return;
        } else if (buffer._data._setRange(
            start * elementSizeInBytes + offsetInBytes,
            count * elementSizeInBytes,
            fromAsTypedList.buffer._data,
            skipCount * elementSizeInBytes + fromAsTypedList.offsetInBytes,
            ClassID.getID(this),
            ClassID.getID(from))) {
          return;
        }
      } else if (fromAsTypedList.buffer == buffer) {
        // Different element sizes, but same buffer means that we need
        // an intermediate structure.
        // TODO(srdjan): Optimize to skip copying if the range does not overlap.
        final fromAsList = from as List<Float64x2>;
        final tempBuffer = _createList(count);
        for (var i = 0; i < count; i++) {
          tempBuffer[i] = fromAsList[skipCount + i];
        }
        for (var i = start; i < end; i++) {
          this[i] = tempBuffer[i - start];
        }
        return;
      }
    }

    List otherList;
    int otherStart;
    if (from is List<Float64x2>) {
      otherList = from;
      otherStart = skipCount;
    } else {
      otherList = from.skip(skipCount).toList(growable: false);
      otherStart = 0;
    }
    if (otherStart + count > otherList.length) {
      throw IterableElementError.tooFew();
    }
    Lists.copy(otherList, otherStart, this, start, count);
  }

  @override
  Iterable<Float64x2> where(bool Function(Float64x2 element) f) =>
      WhereIterable<Float64x2>(this, f);

  @override
  Iterable<Float64x2> take(int n) => SubListIterable<Float64x2>(this, 0, n);

  @override
  Iterable<Float64x2> takeWhile(bool Function(Float64x2 element) test) =>
      TakeWhileIterable<Float64x2>(this, test);

  @override
  Iterable<Float64x2> skip(int n) =>
      SubListIterable<Float64x2>(this, n, null);

  @override
  Iterable<Float64x2> skipWhile(bool Function(Float64x2 element) test) =>
      SkipWhileIterable<Float64x2>(this, test);

  @override
  Iterable<Float64x2> get reversed => ReversedListIterable<Float64x2>(this);

  @override
  Map<int, Float64x2> asMap() => ListMapView<Float64x2>(this);

  @override
  Iterable<Float64x2> getRange(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, length);
    return SubListIterable<Float64x2>(this, start, endIndex);
  }

  @override
  Iterator<Float64x2> get iterator => _TypedListIterator<Float64x2>(this);

  @override
  List<Float64x2> toList({bool growable = true}) {
    return List<Float64x2>.from(this, growable: growable);
  }

  @override
  Set<Float64x2> toSet() {
    return Set<Float64x2>.from(this);
  }

  @override
  void forEach(void Function(Float64x2 element) f) {
    var len = length;
    for (var i = 0; i < len; i++) {
      f(this[i]);
    }
  }

  @override
  Float64x2 reduce(Float64x2 Function(Float64x2 value, Float64x2 element) combine) {
    var len = length;
    if (len == 0) throw IterableElementError.noElement();
    var value = this[0];
    for (var i = 1; i < len; ++i) {
      value = combine(value, this[i]);
    }
    return value;
  }

  @override
  T fold<T>(T initialValue, T Function(T initialValue, Float64x2 element) combine) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      initialValue = combine(initialValue, this[i]);
    }
    return initialValue;
  }

  @override
  Iterable<T> map<T>(T Function(Float64x2 element) f) =>
      MappedIterable<Float64x2, T>(this, f);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(Float64x2 element) f) =>
      ExpandIterable<Float64x2, T>(this, f);

  @override
  bool every(bool Function(Float64x2 element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (!f(this[i])) return false;
    }
    return true;
  }

  @override
  bool any(bool Function(Float64x2 element) f) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      if (f(this[i])) return true;
    }
    return false;
  }

  @override
  Float64x2 firstWhere(bool Function(Float64x2 element) test, {Float64x2 Function()? orElse}) {
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) return element;
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Float64x2 lastWhere(bool Function(Float64x2 element) test, {Float64x2 Function()? orElse}) {
    var len = length;
    for (var i = len - 1; i >= 0; --i) {
      var element = this[i];
      if (test(element)) {
        return element;
      }
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Float64x2 singleWhere(bool Function(Float64x2 element) test, {Float64x2 Function()? orElse}) {
    Float64x2 result;
    bool foundMatching = false;
    var len = length;
    for (var i = 0; i < len; ++i) {
      var element = this[i];
      if (test(element)) {
        if (foundMatching) {
          throw IterableElementError.tooMany();
        }
        result = element;
        foundMatching = true;
      }
    }
    if (foundMatching) return result;
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  Float64x2 elementAt(int index) {
    return this[index];
  }

  @override
  void add(Float64x2 value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void addAll(Iterable<Float64x2> value) {
    throw UnsupportedError("Cannot add to a fixed-length list");
  }

  @override
  void insert(int index, Float64x2 value) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void insertAll(int index, Iterable<Float64x2> values) {
    throw UnsupportedError("Cannot insert into a fixed-length list");
  }

  @override
  void sort([int Function(Float64x2 a, Float64x2 b)? compare]) {
    if (compare == null) {
      throw "SIMD don't have default compare.";
    }
    Sort.sort(this, compare);
  }

  @override
  int indexOf(Float64x2 element, [int start = 0]) {
    if (start >= length) {
      return -1;
    } else if (start < 0) {
      start = 0;
    }
    for (int i = start; i < length; i++) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  int lastIndexOf(Float64x2 element, [int? start]) {
    int startIndex =
        (start == null || start >= length) ? length - 1 : start;
    for (int i = startIndex; i >= 0; i--) {
      if (this[i] == element) return i;
    }
    return -1;
  }

  @override
  Float64x2 removeLast() {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  Float64x2 removeAt(int index) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void removeWhere(bool Function(Float64x2 element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  void retainWhere(bool Function(Float64x2 element) test) {
    throw UnsupportedError("Cannot remove from a fixed-length list");
  }

  @override
  Float64x2 get first {
    if (length > 0) return this[0];
    throw IterableElementError.noElement();
  }

  @override
  Float64x2 get last {
    if (length > 0) return this[length - 1];
    throw IterableElementError.noElement();
  }

  @override
  Float64x2 get single {
    if (length == 1) return this[0];
    if (length == 0) throw IterableElementError.noElement();
    throw IterableElementError.tooMany();
  }

  @override
  Float64x2List sublist(int start, [int? end]) {
    int endIndex = RangeError.checkValidRange(start, end, this.length);
    var length = endIndex - start;
    Float64x2List result = _createList(length);
    result.setRange(0, length, this, start);
    return result;
  }

  @override
  void setAll(int index, Iterable<Float64x2> iterable) {
    final end = iterable.length + index;
    setRange(index, end, iterable);
  }

  @override
  void fillRange(int start, int end, [Float64x2? fillValue]) {
    RangeError.checkValidRange(start, end, length);
    if (start == end) return;
    if (fillValue == null) {
      throw ArgumentError.notNull("fillValue");
    }
    for (var i = start; i < end; ++i) {
      this[i] = fillValue;
    }
  }
}

@pragma("vm:entry-point")
final class _ByteBuffer implements ByteBuffer {
  final _TypedList _data;

  _ByteBuffer(this._data);

  @pragma("vm:entry-point")
  factory _ByteBuffer._New(data) => _ByteBuffer(data);

  // Forward calls to _data.
  int get lengthInBytes => _data.lengthInBytes;
  @override
  int get hashCode => _data.hashCode;
  @override
  bool operator ==(Object other) =>
      (other is _ByteBuffer) && identical(_data, other._data);

  ByteData asByteData([int offsetInBytes = 0, int? length]) {
    length ??= lengthInBytes - offsetInBytes;
    _rangeCheck(_data.lengthInBytes, offsetInBytes, length);
    return _ByteDataView._(_data, offsetInBytes, length);
  }

  Int8List asInt8List([int offsetInBytes = 0, int? length]) {
    length ??= (lengthInBytes - offsetInBytes) ~/ Int8List.bytesPerElement;
    _rangeCheck(
        lengthInBytes, offsetInBytes, length * Int8List.bytesPerElement);
    return _Int8ArrayView._(_data, offsetInBytes, length);
  }

  Uint8List asUint8List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Uint8List.bytesPerElement;
    _rangeCheck(
        lengthInBytes, offsetInBytes, length * Uint8List.bytesPerElement);
    return _Uint8ArrayView._(_data, offsetInBytes, length);
  }

  Uint8ClampedList asUint8ClampedList([int offsetInBytes = 0, int? length]) {
    length ??= (lengthInBytes - offsetInBytes) ~/
        Uint8ClampedList.bytesPerElement;
    _rangeCheck(lengthInBytes, offsetInBytes,
        length * Uint8ClampedList.bytesPerElement);
    return _Uint8ClampedArrayView._(_data, offsetInBytes, length);
  }

  Int16List asInt16List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Int16List.bytesPerElement;
    _rangeCheck(
        lengthInBytes, offsetInBytes, length * Int16List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Int16List.bytesPerElement);
    return _Int16ArrayView._(_data, offsetInBytes, length);
  }

  Uint16List asUint16List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Uint16List.bytesPerElement;
    _rangeCheck(
        lengthInBytes, offsetInBytes, length * Uint16List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Uint16List.bytesPerElement);
    return _Uint16ArrayView._(_data, offsetInBytes, length);
  }

  Int32List asInt32List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Int32List.bytesPerElement;
    _rangeCheck(
        lengthInBytes, offsetInBytes, length * Int32List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Int32List.bytesPerElement);
    return _Int32ArrayView._(_data, offsetInBytes, length);
  }

  Uint32List asUint32List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Uint32List.bytesPerElement;
    _rangeCheck(
        lengthInBytes, offsetInBytes, length * Uint32List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Uint32List.bytesPerElement);
    return _Uint32ArrayView._(_data, offsetInBytes, length);
  }

  Int64List asInt64List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Int64List.bytesPerElement;
    _rangeCheck(
        lengthInBytes, offsetInBytes, length * Int64List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Int64List.bytesPerElement);
    return _Int64ArrayView._(_data, offsetInBytes, length);
  }

  Uint64List asUint64List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Uint64List.bytesPerElement;
    _rangeCheck(
        lengthInBytes, offsetInBytes, length * Uint64List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Uint64List.bytesPerElement);
    return _Uint64ArrayView._(_data, offsetInBytes, length);
  }

  Float32List asFloat32List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Float32List.bytesPerElement;
    _rangeCheck(lengthInBytes, offsetInBytes,
        length * Float32List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Float32List.bytesPerElement);
    return _Float32ArrayView._(_data, offsetInBytes, length);
  }

  Float64List asFloat64List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Float64List.bytesPerElement;
    _rangeCheck(lengthInBytes, offsetInBytes,
        length * Float64List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Float64List.bytesPerElement);
    return _Float64ArrayView._(_data, offsetInBytes, length);
  }

  Float32x4List asFloat32x4List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Float32x4List.bytesPerElement;
    _rangeCheck(lengthInBytes, offsetInBytes,
        length * Float32x4List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Float32x4List.bytesPerElement);
    return _Float32x4ArrayView._(_data, offsetInBytes, length);
  }

  Int32x4List asInt32x4List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Int32x4List.bytesPerElement;
    _rangeCheck(lengthInBytes, offsetInBytes,
        length * Int32x4List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Int32x4List.bytesPerElement);
    return _Int32x4ArrayView._(_data, offsetInBytes, length);
  }

  Float64x2List asFloat64x2List([int offsetInBytes = 0, int? length]) {
    length ??=
        (lengthInBytes - offsetInBytes) ~/ Float64x2List.bytesPerElement;
    _rangeCheck(lengthInBytes, offsetInBytes,
        length * Float64x2List.bytesPerElement);
    _offsetAlignmentCheck(offsetInBytes, Float64x2List.bytesPerElement);
    return _Float64x2ArrayView._(_data, offsetInBytes, length);
  }
}

abstract final class _TypedList extends _TypedListBase {
  @override
  int get elementSizeInBytes;

  // Default method implementing parts of the TypedData interface.
  @override
  int get offsetInBytes {
    return 0;
  }

  int get lengthInBytes {
    return length * elementSizeInBytes;
  }

  @override
  _ByteBuffer get buffer => _ByteBuffer(this);

  // Internal utility methods.

  @override
  _TypedList get _typedData => this;

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  @pragma("vm:external-name", "TypedData_GetInt8")
  external int _getInt8(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetInt8")
  external void _setInt8(int offsetInBytes, int value);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  @pragma("vm:external-name", "TypedData_GetUint8")
  external int _getUint8(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetUint8")
  external void _setUint8(int offsetInBytes, int value);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  @pragma("vm:external-name", "TypedData_GetInt16")
  external int _getInt16(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetInt16")
  external void _setInt16(int offsetInBytes, int value);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  @pragma("vm:external-name", "TypedData_GetUint16")
  external int _getUint16(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetUint16")
  external void _setUint16(int offsetInBytes, int value);

  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_GetInt32")
  external int _getInt32(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetInt32")
  external void _setInt32(int offsetInBytes, int value);

  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_GetUint32")
  external int _getUint32(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetUint32")
  external void _setUint32(int offsetInBytes, int value);

  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_GetInt64")
  external int _getInt64(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetInt64")
  external void _setInt64(int offsetInBytes, int value);

  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_GetUint64")
  external int _getUint64(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetUint64")
  external void _setUint64(int offsetInBytes, int value);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  @pragma("vm:external-name", "TypedData_GetFloat32")
  external double _getFloat32(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetFloat32")
  external void _setFloat32(int offsetInBytes, double value);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  @pragma("vm:external-name", "TypedData_GetFloat64")
  external double _getFloat64(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetFloat64")
  external void _setFloat64(int offsetInBytes, double value);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "TypedData_GetFloat32x4")
  external Float32x4 _getFloat32x4(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetFloat32x4")
  external void _setFloat32x4(int offsetInBytes, Float32x4 value);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "TypedData_GetInt32x4")
  external Int32x4 _getInt32x4(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetInt32x4")
  external void _setInt32x4(int offsetInBytes, Int32x4 value);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "TypedData_GetFloat64x2")
  external Float64x2 _getFloat64x2(int offsetInBytes);
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "TypedData_SetFloat64x2")
  external void _setFloat64x2(int offsetInBytes, Float64x2 value);

  /// Stores the [CodeUnits] as UTF-16 units into this TypedData at
  /// positions [start]..[end] (uint16 indices).
  void _setCodeUnits(
      CodeUnits units, int byteStart, int length, int skipCount) {
    assert(byteStart + length * Uint16List.bytesPerElement <= lengthInBytes);
    String string = CodeUnits.stringOf(units);
    int sliceEnd = skipCount + length;
    RangeError.checkValidRange(
        skipCount, sliceEnd, string.length, "skipCount", "skipCount + length");
    for (int i = 0; i < length; i++) {
      _setUint16(byteStart + i * Uint16List.bytesPerElement,
          string.codeUnitAt(skipCount + i));
    }
  }
}

@patch
class Int8List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int8List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Int8Array_new")
  external factory Int8List(int length);

  @patch
  factory Int8List.fromList(List<int> elements) {
    return Int8List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int8List extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Int8List>
    implements Int8List {
  factory _Int8List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getInt8(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setInt8(index, _toInt8(value));
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int8List _createList(int length) {
    return Int8List(length);
  }
}

@patch
class Uint8List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint8List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Uint8Array_new")
  external factory Uint8List(int length);

  @patch
  factory Uint8List.fromList(List<int> elements) {
    return Uint8List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint8List extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint8List>
    implements Uint8List {
  factory _Uint8List._uninstantiable() {
    throw "Unreachable";
  }

  // Methods implementing List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getUint8(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setUint8(index, _toUint8(value));
  }

  // Methods implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint8List _createList(int length) {
    return Uint8List(length);
  }
}

@patch
class Uint8ClampedList {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint8ClampedList)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Uint8ClampedArray_new")
  external factory Uint8ClampedList(int length);

  @patch
  factory Uint8ClampedList.fromList(List<int> elements) {
    return Uint8ClampedList(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint8ClampedList extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint8ClampedList>
    implements Uint8ClampedList {
  factory _Uint8ClampedList._uninstantiable() {
    throw "Unreachable";
  }

  // Methods implementing List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getUint8(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setUint8(index, _toClampedUint8(value));
  }

  // Methods implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint8ClampedList _createList(int length) {
    return Uint8ClampedList(length);
  }
}

@patch
class Int16List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int16List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Int16Array_new")
  external factory Int16List(int length);

  @patch
  factory Int16List.fromList(List<int> elements) {
    return Int16List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int16List extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Int16List>
    implements Int16List {
  factory _Int16List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedInt16(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedInt16(index, _toInt16(value));
  }

  @override
  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    if (iterable is CodeUnits) {
      end = RangeError.checkValidRange(start, end, this.length);
      int length = end - start;
      int byteStart = offsetInBytes + start * Int16List.bytesPerElement;
      _setCodeUnits(iterable, byteStart, length, skipCount);
    } else {
      super.setRange(start, end, iterable, skipCount);
    }
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int16List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int16List _createList(int length) {
    return Int16List(length);
  }

  int _getIndexedInt16(int index) {
    return _getInt16(index * Int16List.bytesPerElement);
  }

  void _setIndexedInt16(int index, int value) {
    _setInt16(index * Int16List.bytesPerElement, value);
  }
}

@patch
class Uint16List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint16List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Uint16Array_new")
  external factory Uint16List(int length);

  @patch
  factory Uint16List.fromList(List<int> elements) {
    return Uint16List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint16List extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint16List>
    implements Uint16List {
  factory _Uint16List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedUint16(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedUint16(index, _toUint16(value));
  }

  @override
  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    if (iterable is CodeUnits) {
      end = RangeError.checkValidRange(start, end, this.length);
      int length = end - start;
      int byteStart = offsetInBytes + start * Uint16List.bytesPerElement;
      _setCodeUnits(iterable, byteStart, length, skipCount);
    } else {
      super.setRange(start, end, iterable, skipCount);
    }
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint16List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint16List _createList(int length) {
    return Uint16List(length);
  }

  int _getIndexedUint16(int index) {
    return _getUint16(index * Uint16List.bytesPerElement);
  }

  void _setIndexedUint16(int index, int value) {
    _setUint16(index * Uint16List.bytesPerElement, value);
  }
}

@patch
class Int32List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Int32Array_new")
  external factory Int32List(int length);

  @patch
  factory Int32List.fromList(List<int> elements) {
    return Int32List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int32List extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Int32List>
    implements Int32List {
  factory _Int32List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedInt32(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedInt32(index, _toInt32(value));
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int32List _createList(int length) {
    return Int32List(length);
  }

  int _getIndexedInt32(int index) {
    return _getInt32(index * Int32List.bytesPerElement);
  }

  void _setIndexedInt32(int index, int value) {
    _setInt32(index * Int32List.bytesPerElement, value);
  }
}

@patch
class Uint32List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint32List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Uint32Array_new")
  external factory Uint32List(int length);

  @patch
  factory Uint32List.fromList(List<int> elements) {
    return Uint32List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint32List extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint32List>
    implements Uint32List {
  factory _Uint32List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedUint32(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedUint32(index, _toUint32(value));
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint32List _createList(int length) {
    return Uint32List(length);
  }

  int _getIndexedUint32(int index) {
    return _getUint32(index * Uint32List.bytesPerElement);
  }

  void _setIndexedUint32(int index, int value) {
    _setUint32(index * Uint32List.bytesPerElement, value);
  }
}

@patch
class Int64List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int64List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Int64Array_new")
  external factory Int64List(int length);

  @patch
  factory Int64List.fromList(List<int> elements) {
    return Int64List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int64List extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Int64List>
    implements Int64List {
  factory _Int64List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedInt64(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedInt64(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int64List _createList(int length) {
    return Int64List(length);
  }

  int _getIndexedInt64(int index) {
    return _getInt64(index * Int64List.bytesPerElement);
  }

  void _setIndexedInt64(int index, int value) {
    _setInt64(index * Int64List.bytesPerElement, value);
  }
}

@patch
class Uint64List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint64List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Uint64Array_new")
  external factory Uint64List(int length);

  @patch
  factory Uint64List.fromList(List<int> elements) {
    return Uint64List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint64List extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint64List>
    implements Uint64List {
  factory _Uint64List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedUint64(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedUint64(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint64List _createList(int length) {
    return Uint64List(length);
  }

  int _getIndexedUint64(int index) {
    return _getUint64(index * Uint64List.bytesPerElement);
  }

  void _setIndexedUint64(int index, int value) {
    _setUint64(index * Uint64List.bytesPerElement, value);
  }
}

@patch
class Float32List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Float32Array_new")
  external factory Float32List(int length);

  @patch
  factory Float32List.fromList(List<double> elements) {
    return Float32List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Float32List extends _TypedList
    with _DoubleListMixin, _TypedDoubleListMixin<Float32List>
    implements Float32List {
  factory _Float32List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  double operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedFloat32(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, double value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedFloat32(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float32List _createList(int length) {
    return Float32List(length);
  }

  double _getIndexedFloat32(int index) {
    return _getFloat32(index * Float32List.bytesPerElement);
  }

  void _setIndexedFloat32(int index, double value) {
    _setFloat32(index * Float32List.bytesPerElement, value);
  }
}

@patch
class Float64List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Float64Array_new")
  external factory Float64List(int length);

  @patch
  factory Float64List.fromList(List<double> elements) {
    return Float64List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Float64List extends _TypedList
    with _DoubleListMixin, _TypedDoubleListMixin<Float64List>
    implements Float64List {
  factory _Float64List._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  double operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedFloat64(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, double value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedFloat64(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float64List _createList(int length) {
    return Float64List(length);
  }

  double _getIndexedFloat64(int index) {
    return _getFloat64(index * Float64List.bytesPerElement);
  }

  void _setIndexedFloat64(int index, double value) {
    _setFloat64(index * Float64List.bytesPerElement, value);
  }
}

@patch
class Float32x4List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Float32x4Array_new")
  external factory Float32x4List(int length);

  @patch
  factory Float32x4List.fromList(List<Float32x4> elements) {
    return Float32x4List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
final class _Float32x4List extends _TypedList
    with _Float32x4ListMixin
    implements Float32x4List {
  factory _Float32x4List._uninstantiable() {
    throw "Unreachable";
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", _Float32x4)
  Float32x4 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedFloat32x4(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, Float32x4 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedFloat32x4(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float32x4List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float32x4List _createList(int length) {
    return Float32x4List(length);
  }

  Float32x4 _getIndexedFloat32x4(int index) {
    return _getFloat32x4(index * Float32x4List.bytesPerElement);
  }

  void _setIndexedFloat32x4(int index, Float32x4 value) {
    _setFloat32x4(index * Float32x4List.bytesPerElement, value);
  }
}

@patch
class Int32x4List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Int32x4Array_new")
  external factory Int32x4List(int length);

  @patch
  factory Int32x4List.fromList(List<Int32x4> elements) {
    return Int32x4List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
final class _Int32x4List extends _TypedList
    with _Int32x4ListMixin
    implements Int32x4List {
  factory _Int32x4List._uninstantiable() {
    throw "Unreachable";
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", _Int32x4)
  Int32x4 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedInt32x4(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, Int32x4 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedInt32x4(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int32x4List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int32x4List _createList(int length) {
    return Int32x4List(length);
  }

  Int32x4 _getIndexedInt32x4(int index) {
    return _getInt32x4(index * Int32x4List.bytesPerElement);
  }

  void _setIndexedInt32x4(int index, Int32x4 value) {
    _setInt32x4(index * Int32x4List.bytesPerElement, value);
  }
}

@patch
class Float64x2List {
  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2List)
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedData_Float64x2Array_new")
  external factory Float64x2List(int length);

  @patch
  factory Float64x2List.fromList(List<Float64x2> elements) {
    return Float64x2List(elements.length)
      ..setRange(0, elements.length, elements);
  }
}

@pragma("vm:entry-point")
final class _Float64x2List extends _TypedList
    with _Float64x2ListMixin
    implements Float64x2List {
  factory _Float64x2List._uninstantiable() {
    throw "Unreachable";
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", _Float64x2)
  Float64x2 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedFloat64x2(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, Float64x2 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedFloat64x2(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float64x2List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float64x2List _createList(int length) {
    return Float64x2List(length);
  }

  Float64x2 _getIndexedFloat64x2(int index) {
    return _getFloat64x2(index * Float64x2List.bytesPerElement);
  }

  void _setIndexedFloat64x2(int index, Float64x2 value) {
    _setFloat64x2(index * Float64x2List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalInt8Array extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Int8List>
    implements Int8List {
  factory _ExternalInt8Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getInt8(index);
  }

  @override
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setInt8(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int8List _createList(int length) {
    return Int8List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _ExternalUint8Array extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint8List>
    implements Uint8List {
  factory _ExternalUint8Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getUint8(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setUint8(index, _toUint8(value));
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint8List _createList(int length) {
    return Uint8List(length);
  }
}

@pragma("vm:entry-point")
final class _ExternalUint8ClampedArray extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint8ClampedList>
    implements Uint8ClampedList {
  factory _ExternalUint8ClampedArray._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getUint8(index);
  }

  @override
  @pragma("vm:recognized", "graph-intrinsic")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setUint8(index, _toClampedUint8(value));
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint8ClampedList _createList(int length) {
    return Uint8ClampedList(length);
  }
}

@pragma("vm:entry-point")
final class _ExternalInt16Array extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Int16List>
    implements Int16List {
  factory _ExternalInt16Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedInt16(index);
  }

  @override
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedInt16(index, _toInt16(value));
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int16List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int16List _createList(int length) {
    return Int16List(length);
  }

  int _getIndexedInt16(int index) {
    return _getInt16(index * Int16List.bytesPerElement);
  }

  void _setIndexedInt16(int index, int value) {
    _setInt16(index * Int16List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalUint16Array extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint16List>
    implements Uint16List {
  factory _ExternalUint16Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedUint16(index);
  }

  @override
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedUint16(index, _toUint16(value));
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint16List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint16List _createList(int length) {
    return Uint16List(length);
  }

  int _getIndexedUint16(int index) {
    return _getUint16(index * Uint16List.bytesPerElement);
  }

  void _setIndexedUint16(int index, int value) {
    _setUint16(index * Uint16List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalInt32Array extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Int32List>
    implements Int32List {
  factory _ExternalInt32Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedInt32(index);
  }

  @override
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedInt32(index, _toInt32(value));
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int32List _createList(int length) {
    return Int32List(length);
  }

  int _getIndexedInt32(int index) {
    return _getInt32(index * Int32List.bytesPerElement);
  }

  void _setIndexedInt32(int index, int value) {
    _setInt32(index * Int32List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalUint32Array extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint32List>
    implements Uint32List {
  factory _ExternalUint32Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedUint32(index);
  }

  @override
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedUint32(index, _toUint32(value));
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint32List _createList(int length) {
    return Uint32List(length);
  }

  int _getIndexedUint32(int index) {
    return _getUint32(index * Uint32List.bytesPerElement);
  }

  void _setIndexedUint32(int index, int value) {
    _setUint32(index * Uint32List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalInt64Array extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Int64List>
    implements Int64List {
  factory _ExternalInt64Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedInt64(index);
  }

  @override
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedInt64(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int64List _createList(int length) {
    return Int64List(length);
  }

  int _getIndexedInt64(int index) {
    return _getInt64(index * Int64List.bytesPerElement);
  }

  void _setIndexedInt64(int index, int value) {
    _setInt64(index * Int64List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalUint64Array extends _TypedList
    with _IntListMixin, _TypedIntListMixin<Uint64List>
    implements Uint64List {
  factory _ExternalUint64Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedUint64(index);
  }

  @override
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedUint64(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint64List _createList(int length) {
    return Uint64List(length);
  }

  int _getIndexedUint64(int index) {
    return _getUint64(index * Uint64List.bytesPerElement);
  }

  void _setIndexedUint64(int index, int value) {
    _setUint64(index * Uint64List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalFloat32Array extends _TypedList
    with _DoubleListMixin, _TypedDoubleListMixin<Float32List>
    implements Float32List {
  factory _ExternalFloat32Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  double operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedFloat32(index);
  }

  @override
  void operator []=(int index, double value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedFloat32(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float32List _createList(int length) {
    return Float32List(length);
  }

  double _getIndexedFloat32(int index) {
    return _getFloat32(index * Float32List.bytesPerElement);
  }

  void _setIndexedFloat32(int index, double value) {
    _setFloat32(index * Float32List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalFloat64Array extends _TypedList
    with _DoubleListMixin, _TypedDoubleListMixin<Float64List>
    implements Float64List {
  factory _ExternalFloat64Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  double operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedFloat64(index);
  }

  @override
  void operator []=(int index, double value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedFloat64(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float64List _createList(int length) {
    return Float64List(length);
  }

  double _getIndexedFloat64(int index) {
    return _getFloat64(index * Float64List.bytesPerElement);
  }

  void _setIndexedFloat64(int index, double value) {
    _setFloat64(index * Float64List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalFloat32x4Array extends _TypedList
    with _Float32x4ListMixin
    implements Float32x4List {
  factory _ExternalFloat32x4Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  Float32x4 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedFloat32x4(index);
  }

  @override
  void operator []=(int index, Float32x4 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedFloat32x4(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float32x4List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float32x4List _createList(int length) {
    return Float32x4List(length);
  }

  Float32x4 _getIndexedFloat32x4(int index) {
    return _getFloat32x4(index * Float32x4List.bytesPerElement);
  }

  void _setIndexedFloat32x4(int index, Float32x4 value) {
    _setFloat32x4(index * Float32x4List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalInt32x4Array extends _TypedList
    with _Int32x4ListMixin
    implements Int32x4List {
  factory _ExternalInt32x4Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  Int32x4 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedInt32x4(index);
  }

  @override
  void operator []=(int index, Int32x4 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedInt32x4(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int32x4List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int32x4List _createList(int length) {
    return Int32x4List(length);
  }

  Int32x4 _getIndexedInt32x4(int index) {
    return _getInt32x4(index * Int32x4List.bytesPerElement);
  }

  void _setIndexedInt32x4(int index, Int32x4 value) {
    _setInt32x4(index * Int32x4List.bytesPerElement, value);
  }
}

@pragma("vm:entry-point")
final class _ExternalFloat64x2Array extends _TypedList
    with _Float64x2ListMixin
    implements Float64x2List {
  factory _ExternalFloat64x2Array._uninstantiable() {
    throw "Unreachable";
  }

  // Method(s) implementing the List interface.
  @override
  Float64x2 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _getIndexedFloat64x2(index);
  }

  @override
  void operator []=(int index, Float64x2 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _setIndexedFloat64x2(index, value);
  }

  // Method(s) implementing the TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float64x2List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float64x2List _createList(int length) {
    return Float64x2List(length);
  }

  Float64x2 _getIndexedFloat64x2(int index) {
    return _getFloat64x2(index * Float64x2List.bytesPerElement);
  }

  void _setIndexedFloat64x2(int index, Float64x2 value) {
    _setFloat64x2(index * Float64x2List.bytesPerElement, value);
  }
}

@patch
class Float32x4 {
  @patch
  @pragma("vm:prefer-inline")
  factory Float32x4(double x, double y, double z, double w) {
    _throwIfNull(x, 'x');
    _throwIfNull(y, 'y');
    _throwIfNull(z, 'z');
    _throwIfNull(w, 'w');
    return _Float32x4FromDoubles(x, y, z, w);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_fromDoubles")
  external static _Float32x4 _Float32x4FromDoubles(
      double x, double y, double z, double w);

  @patch
  @pragma("vm:prefer-inline")
  factory Float32x4.splat(double v) {
    _throwIfNull(v, 'v');
    return _Float32x4Splat(v);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_splat")
  external static _Float32x4 _Float32x4Splat(double v);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_zero")
  external factory Float32x4.zero();

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_fromInt32x4Bits")
  external factory Float32x4.fromInt32x4Bits(Int32x4 x);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_fromFloat64x2")
  external factory Float32x4.fromFloat64x2(Float64x2 v);
}

@pragma("vm:entry-point")
final class _Float32x4 implements Float32x4 {
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_add")
  external Float32x4 operator +(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_negate")
  external Float32x4 operator -();
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_sub")
  external Float32x4 operator -(Float32x4 other);
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_mul")
  external Float32x4 operator *(Float32x4 other);
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:external-name", "Float32x4_div")
  external Float32x4 operator /(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Float32x4_cmplt")
  external Int32x4 lessThan(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Float32x4_cmplte")
  external Int32x4 lessThanOrEqual(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Float32x4_cmpgt")
  external Int32x4 greaterThan(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Float32x4_cmpgte")
  external Int32x4 greaterThanOrEqual(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Float32x4_cmpequal")
  external Int32x4 equal(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Float32x4_cmpnequal")
  external Int32x4 notEqual(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_scale")
  external Float32x4 scale(double s);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_abs")
  external Float32x4 abs();
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_clamp")
  external Float32x4 clamp(Float32x4 lowerLimit, Float32x4 upperLimit);
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  @pragma("vm:external-name", "Float32x4_getX")
  external double get x;
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  @pragma("vm:external-name", "Float32x4_getY")
  external double get y;
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  @pragma("vm:external-name", "Float32x4_getZ")
  external double get z;
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  @pragma("vm:external-name", "Float32x4_getW")
  external double get w;
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "Float32x4_getSignMask")
  external int get signMask;

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_shuffle")
  external Float32x4 shuffle(int mask);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_shuffleMix")
  external Float32x4 shuffleMix(Float32x4 zw, int mask);

  @pragma("vm:prefer-inline")
  Float32x4 withX(double x) {
    _throwIfNull(x, 'x');
    return _withX(x);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_setX")
  external Float32x4 _withX(double x);

  @pragma("vm:prefer-inline")
  Float32x4 withY(double y) {
    _throwIfNull(y, 'y');
    return _withY(y);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_setY")
  external Float32x4 _withY(double y);

  @pragma("vm:prefer-inline")
  Float32x4 withZ(double z) {
    _throwIfNull(z, 'z');
    return _withZ(z);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_setZ")
  external Float32x4 _withZ(double z);

  @pragma("vm:prefer-inline")
  Float32x4 withW(double w) {
    _throwIfNull(w, 'w');
    return _withW(w);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_setW")
  external Float32x4 _withW(double w);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_min")
  external Float32x4 min(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_max")
  external Float32x4 max(Float32x4 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_sqrt")
  external Float32x4 sqrt();
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_reciprocal")
  external Float32x4 reciprocal();
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Float32x4_reciprocalSqrt")
  external Float32x4 reciprocalSqrt();
}

@patch
class Int32x4 {
  @patch
  @pragma("vm:prefer-inline")
  factory Int32x4(int x, int y, int z, int w) {
    _throwIfNull(x, 'x');
    _throwIfNull(y, 'y');
    _throwIfNull(z, 'z');
    _throwIfNull(w, 'w');
    return _Int32x4FromInts(x, y, z, w);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_fromInts")
  external static _Int32x4 _Int32x4FromInts(int x, int y, int z, int w);

  @patch
  @pragma("vm:prefer-inline")
  factory Int32x4.bool(bool x, bool y, bool z, bool w) {
    _throwIfNull(x, 'x');
    _throwIfNull(y, 'y');
    _throwIfNull(z, 'z');
    _throwIfNull(w, 'w');
    return _Int32x4FromBools(x, y, z, w);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_fromBools")
  external static _Int32x4 _Int32x4FromBools(bool x, bool y, bool z, bool w);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_fromFloat32x4Bits")
  external factory Int32x4.fromFloat32x4Bits(Float32x4 x);
}

@pragma("vm:entry-point")
final class _Int32x4 implements Int32x4 {
  @pragma("vm:external-name", "Int32x4_or")
  external Int32x4 operator |(Int32x4 other);
  @pragma("vm:external-name", "Int32x4_and")
  external Int32x4 operator &(Int32x4 other);
  @pragma("vm:external-name", "Int32x4_xor")
  external Int32x4 operator ^(Int32x4 other);
  @pragma("vm:external-name", "Int32x4_add")
  external Int32x4 operator +(Int32x4 other);
  @pragma("vm:external-name", "Int32x4_sub")
  external Int32x4 operator -(Int32x4 other);
  @pragma("vm:external-name", "Int32x4_getX")
  external int get x;
  @pragma("vm:external-name", "Int32x4_getY")
  external int get y;
  @pragma("vm:external-name", "Int32x4_getZ")
  external int get z;
  @pragma("vm:external-name", "Int32x4_getW")
  external int get w;
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "Int32x4_getSignMask")
  external int get signMask;
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_shuffle")
  external Int32x4 shuffle(int mask);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_shuffleMix")
  external Int32x4 shuffleMix(Int32x4 zw, int mask);

  @pragma("vm:prefer-inline")
  Int32x4 withX(int x) {
    _throwIfNull(x, 'x');
    return _withX(x);
  }

  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_setX")
  external Int32x4 _withX(int x);

  @pragma("vm:prefer-inline")
  Int32x4 withY(int y) {
    _throwIfNull(y, 'y');
    return _withY(y);
  }

  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_setY")
  external Int32x4 _withY(int y);

  @pragma("vm:prefer-inline")
  Int32x4 withZ(int z) {
    _throwIfNull(z, 'z');
    return _withZ(z);
  }

  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_setZ")
  external Int32x4 _withZ(int z);

  @pragma("vm:prefer-inline")
  Int32x4 withW(int w) {
    _throwIfNull(w, 'w');
    return _withW(w);
  }

  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_setW")
  external Int32x4 _withW(int w);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", bool)
  @pragma("vm:external-name", "Int32x4_getFlagX")
  external bool get flagX;
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", bool)
  @pragma("vm:external-name", "Int32x4_getFlagY")
  external bool get flagY;
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", bool)
  @pragma("vm:external-name", "Int32x4_getFlagZ")
  external bool get flagZ;
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", bool)
  @pragma("vm:external-name", "Int32x4_getFlagW")
  external bool get flagW;

  @pragma("vm:prefer-inline", _Int32x4)
  Int32x4 withFlagX(bool x) {
    _throwIfNull(x, 'x');
    return _withFlagX(x);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_setFlagX")
  external Int32x4 _withFlagX(bool x);

  @pragma("vm:prefer-inline", _Int32x4)
  Int32x4 withFlagY(bool y) {
    _throwIfNull(y, 'y');
    return _withFlagY(y);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_setFlagY")
  external Int32x4 _withFlagY(bool y);

  @pragma("vm:prefer-inline", _Int32x4)
  Int32x4 withFlagZ(bool z) {
    _throwIfNull(z, 'z');
    return _withFlagZ(z);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_setFlagZ")
  external Int32x4 _withFlagZ(bool z);

  @pragma("vm:prefer-inline", _Int32x4)
  Int32x4 withFlagW(bool w) {
    _throwIfNull(w, 'w');
    return _withFlagW(w);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4)
  @pragma("vm:external-name", "Int32x4_setFlagW")
  external Int32x4 _withFlagW(bool w);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4)
  @pragma("vm:external-name", "Int32x4_select")
  external Float32x4 select(Float32x4 trueValue, Float32x4 falseValue);
}

@patch
class Float64x2 {
  @patch
  @pragma("vm:prefer-inline")
  factory Float64x2(double x, double y) {
    _throwIfNull(x, 'x');
    _throwIfNull(y, 'y');
    return _Float64x2FromDoubles(x, y);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_fromDoubles")
  external static _Float64x2 _Float64x2FromDoubles(double x, double y);

  @patch
  @pragma("vm:prefer-inline")
  factory Float64x2.splat(double v) {
    _throwIfNull(v, 'v');
    return _Float64x2Splat(v);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_splat")
  external static _Float64x2 _Float64x2Splat(double v);

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_zero")
  external factory Float64x2.zero();

  @patch
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_fromFloat32x4")
  external factory Float64x2.fromFloat32x4(Float32x4 v);
}

@pragma("vm:entry-point")
final class _Float64x2 implements Float64x2 {
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:external-name", "Float64x2_add")
  external Float64x2 operator +(Float64x2 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_negate")
  external Float64x2 operator -();
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:external-name", "Float64x2_sub")
  external Float64x2 operator -(Float64x2 other);
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:external-name", "Float64x2_mul")
  external Float64x2 operator *(Float64x2 other);
  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:external-name", "Float64x2_div")
  external Float64x2 operator /(Float64x2 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_scale")
  external Float64x2 scale(double s);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_abs")
  external Float64x2 abs();
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_clamp")
  external Float64x2 clamp(Float64x2 lowerLimit, Float64x2 upperLimit);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  @pragma("vm:external-name", "Float64x2_getX")
  external double get x;
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Double")
  @pragma("vm:external-name", "Float64x2_getY")
  external double get y;
  @pragma("vm:recognized", "other")
  @pragma("vm:external-name", "Float64x2_getSignMask")
  external int get signMask;

  @pragma("vm:prefer-inline")
  Float64x2 withX(double x) {
    _throwIfNull(x, 'x');
    return _withX(x);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_setX")
  external Float64x2 _withX(double x);

  @pragma("vm:prefer-inline")
  Float64x2 withY(double y) {
    _throwIfNull(y, 'y');
    return _withY(y);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_setY")
  external Float64x2 _withY(double y);

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_min")
  external Float64x2 min(Float64x2 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_max")
  external Float64x2 max(Float64x2 other);
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2)
  @pragma("vm:external-name", "Float64x2_sqrt")
  external Float64x2 sqrt();
}

final class _TypedListIterator<E> implements Iterator<E> {
  final List<E> _array;
  final int _length;
  int _position;
  E? _current;

  _TypedListIterator(List<E> array)
      : _array = array,
        _length = array.length,
        _position = -1 {
    assert(array is _TypedList || array is _TypedListView);
  }

  @override
  bool moveNext() {
    int nextPosition = _position + 1;
    if (nextPosition < _length) {
      _current = _array[nextPosition];
      _position = nextPosition;
      return true;
    }
    _position = _length;
    _current = null;
    return false;
  }

  @override
  E get current => _current as E;
}

abstract final class _TypedListView extends _TypedListBase
    implements TypedData {
  // Method(s) implementing the TypedData interface.

  int get lengthInBytes {
    return length * elementSizeInBytes;
  }

  @override
  _ByteBuffer get buffer {
    return _typedData.buffer;
  }

  @override
  @pragma("vm:recognized", "other")
  @pragma("vm:non-nullable-result-type")
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedDataView_typedData")
  external _TypedList get _typedData;

  @override
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedDataView_offsetInBytes")
  external int get offsetInBytes;
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int8ArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Int8List>
    implements Int8List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int8ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int8ArrayView_new")
  external factory _Int8ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getInt8(offsetInBytes + (index * Int8List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setInt8(
        offsetInBytes + (index * Int8List.bytesPerElement), _toInt8(value));
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int8List _createList(int length) {
    return Int8List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint8ArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Uint8List>
    implements Uint8List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint8ArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint8ArrayView_new")
  external factory _Uint8ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getUint8(offsetInBytes + (index * Uint8List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setUint8(
        offsetInBytes + (index * Uint8List.bytesPerElement), _toUint8(value));
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint8List _createList(int length) {
    return Uint8List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint8ClampedArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Uint8ClampedList>
    implements Uint8ClampedList {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint8ClampedArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint8ClampedArrayView_new")
  external factory _Uint8ClampedArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getUint8(offsetInBytes + (index * Uint8List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setUint8(offsetInBytes + (index * Uint8List.bytesPerElement),
        _toClampedUint8(value));
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint8List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint8ClampedList _createList(int length) {
    return Uint8ClampedList(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int16ArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Int16List>
    implements Int16List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int16ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int16ArrayView_new")
  external factory _Int16ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getInt16(offsetInBytes + (index * Int16List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setInt16(
        offsetInBytes + (index * Int16List.bytesPerElement), _toInt16(value));
  }

  @override
  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    if (iterable is CodeUnits) {
      end = RangeError.checkValidRange(start, end, this.length);
      int length = end - start;
      int byteStart = offsetInBytes + start * Int16List.bytesPerElement;
      _typedData._setCodeUnits(iterable, byteStart, length, skipCount);
    } else {
      super.setRange(start, end, iterable, skipCount);
    }
  }

  // Method(s) implementing TypedData interface.

  @override
  int get elementSizeInBytes {
    return Int16List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int16List _createList(int length) {
    return Int16List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint16ArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Uint16List>
    implements Uint16List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint16ArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint16ArrayView_new")
  external factory _Uint16ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getUint16(offsetInBytes + (index * Uint16List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setUint16(
        offsetInBytes + (index * Uint16List.bytesPerElement), _toUint16(value));
  }

  @override
  void setRange(int start, int end, Iterable<int> iterable,
      [int skipCount = 0]) {
    if (iterable is CodeUnits) {
      end = RangeError.checkValidRange(start, end, this.length);
      int length = end - start;
      int byteStart = offsetInBytes + start * Uint16List.bytesPerElement;
      _typedData._setCodeUnits(iterable, byteStart, length, skipCount);
    } else {
      super.setRange(start, end, iterable, skipCount);
    }
  }

  // Method(s) implementing TypedData interface.

  @override
  int get elementSizeInBytes {
    return Uint16List.bytesPerElement;
  }

  // Internal utility methods.

  @override
  Uint16List _createList(int length) {
    return Uint16List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int32ArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Int32List>
    implements Int32List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int32ArrayView_new")
  external factory _Int32ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getInt32(offsetInBytes + (index * Int32List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setInt32(
        offsetInBytes + (index * Int32List.bytesPerElement), _toInt32(value));
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int32List _createList(int length) {
    return Int32List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint32ArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Uint32List>
    implements Uint32List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint32ArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint32ArrayView_new")
  external factory _Uint32ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getUint32(offsetInBytes + (index * Uint32List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setUint32(
        offsetInBytes + (index * Uint32List.bytesPerElement), _toUint32(value));
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint32List _createList(int length) {
    return Uint32List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int64ArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Int64List>
    implements Int64List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int64ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int64ArrayView_new")
  external factory _Int64ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getInt64(offsetInBytes + (index * Int64List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setInt64(
        offsetInBytes + (index * Int64List.bytesPerElement), value);
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int64List _createList(int length) {
    return Int64List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Uint64ArrayView extends _TypedListView
    with _IntListMixin, _TypedIntListMixin<Uint64List>
    implements Uint64List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Uint64ArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint64ArrayView_new")
  external factory _Uint64ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  int operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getUint64(offsetInBytes + (index * Uint64List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, int value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setUint64(
        offsetInBytes + (index * Uint64List.bytesPerElement), value);
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Uint64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Uint64List _createList(int length) {
    return Uint64List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Float32ArrayView extends _TypedListView
    with _DoubleListMixin, _TypedDoubleListMixin<Float32List>
    implements Float32List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32ArrayView)
  @pragma("vm:external-name", "TypedDataView_Float32ArrayView_new")
  external factory _Float32ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  double operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getFloat32(offsetInBytes + (index * Float32List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, double value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setFloat32(
        offsetInBytes + (index * Float32List.bytesPerElement), value);
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float32List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float32List _createList(int length) {
    return Float32List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Float64ArrayView extends _TypedListView
    with _DoubleListMixin, _TypedDoubleListMixin<Float64List>
    implements Float64List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64ArrayView)
  @pragma("vm:external-name", "TypedDataView_Float64ArrayView_new")
  external factory _Float64ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  @pragma("vm:prefer-inline")
  double operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getFloat64(offsetInBytes + (index * Float64List.bytesPerElement));
  }

  @override
  @pragma("vm:prefer-inline")
  void operator []=(int index, double value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setFloat64(
        offsetInBytes + (index * Float64List.bytesPerElement), value);
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float64List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float64List _createList(int length) {
    return Float64List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Float32x4ArrayView extends _TypedListView
    with _Float32x4ListMixin
    implements Float32x4List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float32x4ArrayView)
  @pragma("vm:external-name", "TypedDataView_Float32x4ArrayView_new")
  external factory _Float32x4ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  Float32x4 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getFloat32x4(offsetInBytes + (index * Float32x4List.bytesPerElement));
  }

  @override
  void operator []=(int index, Float32x4 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setFloat32x4(
        offsetInBytes + (index * Float32x4List.bytesPerElement), value);
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float32x4List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float32x4List _createList(int length) {
    return Float32x4List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Int32x4ArrayView extends _TypedListView
    with _Int32x4ListMixin
    implements Int32x4List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Int32x4ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int32x4ArrayView_new")
  external factory _Int32x4ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  Int32x4 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getInt32x4(offsetInBytes + (index * Int32x4List.bytesPerElement));
  }

  @override
  void operator []=(int index, Int32x4 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setInt32x4(
        offsetInBytes + (index * Int32x4List.bytesPerElement), value);
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Int32x4List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Int32x4List _createList(int length) {
    return Int32x4List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _Float64x2ArrayView extends _TypedListView
    with _Float64x2ListMixin
    implements Float64x2List {
  // Constructor.
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _Float64x2ArrayView)
  @pragma("vm:external-name", "TypedDataView_Float64x2ArrayView_new")
  external factory _Float64x2ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing List interface.
  @override
  Float64x2 operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    return _typedData
        ._getFloat64x2(offsetInBytes + (index * Float64x2List.bytesPerElement));
  }

  @override
  void operator []=(int index, Float64x2 value) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length,
          indexable: this, name: "index");
    }
    _typedData._setFloat64x2(
        offsetInBytes + (index * Float64x2List.bytesPerElement), value);
  }

  // Method(s) implementing TypedData interface.
  @override
  int get elementSizeInBytes {
    return Float64x2List.bytesPerElement;
  }

  // Internal utility methods.
  @override
  Float64x2List _createList(int length) {
    return Float64x2List(length);
  }
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _ByteDataView implements ByteData {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _ByteDataView)
  @pragma("vm:external-name", "TypedDataView_ByteDataView_new")
  external factory _ByteDataView._(
      _TypedList buffer, int offsetInBytes, int length);

  // Method(s) implementing TypedData interface.
  _ByteBuffer get buffer {
    return _typedData.buffer;
  }

  int get lengthInBytes {
    return length;
  }

  int get elementSizeInBytes {
    return 1;
  }

  // Method(s) implementing ByteData interface.

  @pragma("vm:prefer-inline")
  int getInt8(int byteOffset) {
    if (byteOffset < 0 || byteOffset >= length) {
      throw IndexError.withLength(byteOffset, length,
          indexable: this, name: "byteOffset");
    }
    return _typedData._getInt8(offsetInBytes + byteOffset);
  }

  @pragma("vm:prefer-inline")
  void setInt8(int byteOffset, int value) {
    if (byteOffset < 0 || byteOffset >= length) {
      throw IndexError.withLength(byteOffset, length,
          indexable: this, name: "byteOffset");
    }
    _typedData._setInt8(offsetInBytes + byteOffset, value);
  }

  @pragma("vm:prefer-inline")
  int getUint8(int byteOffset) {
    if (byteOffset < 0 || byteOffset >= length) {
      throw IndexError.withLength(byteOffset, length,
          indexable: this, name: "byteOffset");
    }
    return _typedData._getUint8(offsetInBytes + byteOffset);
  }

  @pragma("vm:prefer-inline")
  void setUint8(int byteOffset, int value) {
    if (byteOffset < 0 || byteOffset >= length) {
      throw IndexError.withLength(byteOffset, length,
          indexable: this, name: "byteOffset");
    }
    _typedData._setUint8(offsetInBytes + byteOffset, value);
  }

  @pragma("vm:prefer-inline")
  int getInt16(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 1 >= length) {
      throw RangeError.range(byteOffset, 0, length - 2, "byteOffset");
    }
    var result = _typedData._getInt16(offsetInBytes + byteOffset);
    if (identical(endian, Endian.host)) {
      return result;
    }
    return _byteSwap16(result).toSigned(16);
  }

  @pragma("vm:prefer-inline")
  void setInt16(int byteOffset, int value, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 1 >= length) {
      throw RangeError.range(byteOffset, 0, length - 2, "byteOffset");
    }
    _typedData._setInt16(offsetInBytes + byteOffset,
        identical(endian, Endian.host) ? value : _byteSwap16(value));
  }

  @pragma("vm:prefer-inline")
  int getUint16(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 1 >= length) {
      throw RangeError.range(byteOffset, 0, length - 2, "byteOffset");
    }
    var result = _typedData._getUint16(offsetInBytes + byteOffset);
    if (identical(endian, Endian.host)) {
      return result;
    }
    return _byteSwap16(result);
  }

  @pragma("vm:prefer-inline")
  void setUint16(int byteOffset, int value, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 1 >= length) {
      throw RangeError.range(byteOffset, 0, length - 2, "byteOffset");
    }
    _typedData._setUint16(offsetInBytes + byteOffset,
        identical(endian, Endian.host) ? value : _byteSwap16(value));
  }

  @pragma("vm:prefer-inline")
  int getInt32(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 3 >= length) {
      throw RangeError.range(byteOffset, 0, length - 4, "byteOffset");
    }
    var result = _typedData._getInt32(offsetInBytes + byteOffset);
    if (identical(endian, Endian.host)) {
      return result;
    }
    return _byteSwap32(result).toSigned(32);
  }

  @pragma("vm:prefer-inline")
  void setInt32(int byteOffset, int value, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 3 >= length) {
      throw RangeError.range(byteOffset, 0, length - 4, "byteOffset");
    }
    _typedData._setInt32(offsetInBytes + byteOffset,
        identical(endian, Endian.host) ? value : _byteSwap32(value));
  }

  @pragma("vm:prefer-inline")
  int getUint32(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 3 >= length) {
      throw RangeError.range(byteOffset, 0, length - 4, "byteOffset");
    }
    var result = _typedData._getUint32(offsetInBytes + byteOffset);
    if (identical(endian, Endian.host)) {
      return result;
    }
    return _byteSwap32(result);
  }

  @pragma("vm:prefer-inline")
  void setUint32(int byteOffset, int value, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 3 >= length) {
      throw RangeError.range(byteOffset, 0, length - 4, "byteOffset");
    }
    _typedData._setUint32(offsetInBytes + byteOffset,
        identical(endian, Endian.host) ? value : _byteSwap32(value));
  }

  @pragma("vm:prefer-inline")
  int getInt64(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 7 >= length) {
      throw RangeError.range(byteOffset, 0, length - 8, "byteOffset");
    }
    var result = _typedData._getInt64(offsetInBytes + byteOffset);
    if (identical(endian, Endian.host)) {
      return result;
    }
    return _byteSwap64(result).toSigned(64);
  }

  @pragma("vm:prefer-inline")
  void setInt64(int byteOffset, int value, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 7 >= length) {
      throw RangeError.range(byteOffset, 0, length - 8, "byteOffset");
    }
    _typedData._setInt64(offsetInBytes + byteOffset,
        identical(endian, Endian.host) ? value : _byteSwap64(value));
  }

  @pragma("vm:prefer-inline")
  int getUint64(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 7 >= length) {
      throw RangeError.range(byteOffset, 0, length - 8, "byteOffset");
    }
    var result = _typedData._getUint64(offsetInBytes + byteOffset);
    if (identical(endian, Endian.host)) {
      return result;
    }
    return _byteSwap64(result);
  }

  @pragma("vm:prefer-inline")
  void setUint64(int byteOffset, int value, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 7 >= length) {
      throw RangeError.range(byteOffset, 0, length - 8, "byteOffset");
    }
    _typedData._setUint64(offsetInBytes + byteOffset,
        identical(endian, Endian.host) ? value : _byteSwap64(value));
  }

  @pragma("vm:prefer-inline")
  double getFloat32(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 3 >= length) {
      throw RangeError.range(byteOffset, 0, length - 4, "byteOffset");
    }
    if (identical(endian, Endian.host)) {
      return _typedData._getFloat32(offsetInBytes + byteOffset);
    }
    _convU32[0] =
        _byteSwap32(_typedData._getUint32(offsetInBytes + byteOffset));
    return _convF32[0];
  }

  @pragma("vm:prefer-inline")
  void setFloat32(int byteOffset, double value, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 3 >= length) {
      throw RangeError.range(byteOffset, 0, length - 4, "byteOffset");
    }
    if (identical(endian, Endian.host)) {
      _typedData._setFloat32(offsetInBytes + byteOffset, value);
      return;
    }
    _convF32[0] = value;
    _typedData._setUint32(offsetInBytes + byteOffset, _byteSwap32(_convU32[0]));
  }

  @pragma("vm:prefer-inline")
  double getFloat64(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 7 >= length) {
      throw RangeError.range(byteOffset, 0, length - 8, "byteOffset");
    }
    if (identical(endian, Endian.host)) {
      return _typedData._getFloat64(offsetInBytes + byteOffset);
    }
    _convU64[0] =
        _byteSwap64(_typedData._getUint64(offsetInBytes + byteOffset));
    return _convF64[0];
  }

  @pragma("vm:prefer-inline")
  void setFloat64(int byteOffset, double value, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 7 >= length) {
      throw RangeError.range(byteOffset, 0, length - 8, "byteOffset");
    }
    if (identical(endian, Endian.host)) {
      _typedData._setFloat64(offsetInBytes + byteOffset, value);
      return;
    }
    _convF64[0] = value;
    _typedData._setUint64(offsetInBytes + byteOffset, _byteSwap64(_convU64[0]));
  }

  Float32x4 getFloat32x4(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 3 >= length) {
      throw RangeError.range(byteOffset, 0, length - 4, "byteOffset");
    }
    // TODO(johnmccutchan) : Need to resolve this for endianity.
    return _typedData._getFloat32x4(offsetInBytes + byteOffset);
  }

  void setFloat32x4(int byteOffset, Float32x4 value,
      [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 3 >= length) {
      throw RangeError.range(byteOffset, 0, length - 4, "byteOffset");
    }
    // TODO(johnmccutchan) : Need to resolve this for endianity.
    _typedData._setFloat32x4(offsetInBytes + byteOffset, value);
  }

  Float64x2 getFloat64x2(int byteOffset, [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 15 >= length) {
      throw RangeError.range(byteOffset, 0, length - 15, "byteOffset");
    }
    // TODO(johnmccutchan) : Need to resolve this for endianity.
    return _typedData._getFloat64x2(offsetInBytes + byteOffset);
  }

  void setFloat64x2(int byteOffset, Float64x2 value,
      [Endian endian = Endian.big]) {
    if (byteOffset < 0 || byteOffset + 15 >= length) {
      throw RangeError.range(byteOffset, 0, length - 15, "byteOffset");
    }
    // TODO(johnmccutchan) : Need to resolve this for endianity.
    _typedData._setFloat64x2(offsetInBytes + byteOffset, value);
  }

  @pragma("vm:recognized", "other")
  @pragma("vm:non-nullable-result-type")
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedDataView_typedData")
  external _TypedList get _typedData;

  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedDataView_offsetInBytes")
  external int get offsetInBytes;

  @pragma("vm:recognized", "graph-intrinsic")
  @pragma("vm:exact-result-type", "dart:core#_Smi")
  @pragma("vm:prefer-inline")
  @pragma("vm:external-name", "TypedDataBase_length")
  external int get length;
}

@pragma("vm:prefer-inline")
int _byteSwap16(int value) {
  return ((value & 0xFF00) >> 8) | ((value & 0x00FF) << 8);
}

@pragma("vm:prefer-inline")
int _byteSwap32(int value) {
  value = ((value & 0xFF00FF00) >> 8) | ((value & 0x00FF00FF) << 8);
  value = ((value & 0xFFFF0000) >> 16) | ((value & 0x0000FFFF) << 16);
  return value;
}

@pragma("vm:prefer-inline")
int _byteSwap64(int value) {
  return (_byteSwap32(value) << 32) | _byteSwap32(value >> 32);
}

final _convU32 = Uint32List(2);
final _convU64 = Uint64List.view(_convU32.buffer);
final _convF32 = Float32List.view(_convU32.buffer);
final _convF64 = Float64List.view(_convU32.buffer);

// Top level utility methods.
@pragma("vm:prefer-inline")
int _toInt(int value, int mask) {
  value &= mask;
  if (value > (mask >> 1)) value -= mask + 1;
  return value;
}

@pragma("vm:prefer-inline")
int _toInt8(int value) {
  return _toInt(value, 0xFF);
}

@pragma("vm:prefer-inline")
int _toUint8(int value) {
  return value & 0xFF;
}

@pragma("vm:recognized", "other")
@pragma("vm:exact-result-type", "dart:core#_Smi")
int _toClampedUint8(int value) {
  if (value < 0) return 0;
  if (value > 0xFF) return 0xFF;
  return value;
}

@pragma("vm:prefer-inline")
int _toInt16(int value) {
  return _toInt(value, 0xFFFF);
}

@pragma("vm:prefer-inline")
int _toUint16(int value) {
  return value & 0xFFFF;
}

@pragma("vm:prefer-inline")
int _toInt32(int value) {
  return _toInt(value, 0xFFFFFFFF);
}

@pragma("vm:prefer-inline")
int _toUint32(int value) {
  return value & 0xFFFFFFFF;
}

@pragma("vm:prefer-inline")
void _throwIfNull(val, String name) {
  if (val == null) {
    throw ArgumentError.notNull(name);
  }
}

// In addition to explicitly checking the range, this method implicitly ensures
// that all arguments are non-null (a no such method error gets thrown
// otherwise).
void _rangeCheck(int listLength, int start, int length) {
  if (length < 0) {
    throw RangeError.value(length);
  }
  if (start < 0) {
    throw RangeError.value(start);
  }
  if (start + length > listLength) {
    throw RangeError.value(start + length);
  }
}

void _offsetAlignmentCheck(int offset, int alignment) {
  if ((offset % alignment) != 0) {
    throw RangeError('Offset ($offset) must be a multiple of '
        'BYTES_PER_ELEMENT ($alignment)');
  }
}

@patch
abstract class UnmodifiableByteBufferView implements Uint8List {
  @patch
  factory UnmodifiableByteBufferView(ByteBuffer data) =
      _UnmodifiableByteBufferView;
}

@patch
abstract class UnmodifiableByteDataView implements ByteData {
  @patch
  factory UnmodifiableByteDataView(ByteData data) =>
      _UnmodifiableByteDataView._((data as _ByteDataView).buffer._data,
          data.offsetInBytes, data.lengthInBytes);
}

@patch
abstract class UnmodifiableUint8ListView implements Uint8List {
  @patch
  factory UnmodifiableUint8ListView(Uint8List list) =>
      _UnmodifiableUint8ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableInt8ListView implements Int8List {
  @patch
  factory UnmodifiableInt8ListView(Int8List list) =>
      _UnmodifiableInt8ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableUint8ClampedListView implements Uint8ClampedList {
  @patch
  factory UnmodifiableUint8ClampedListView(Uint8ClampedList list) =>
      _UnmodifiableUint8ClampedArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableUint16ListView implements Uint16List {
  @patch
  factory UnmodifiableUint16ListView(Uint16List list) =>
      _UnmodifiableUint16ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableInt16ListView implements Int16List {
  @patch
  factory UnmodifiableInt16ListView(Int16List list) =>
      _UnmodifiableInt16ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableUint32ListView implements Uint32List {
  @patch
  factory UnmodifiableUint32ListView(Uint32List list) =>
      _UnmodifiableUint32ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableInt32ListView implements Int32List {
  @patch
  factory UnmodifiableInt32ListView(Int32List list) =>
      _UnmodifiableInt32ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableUint64ListView implements Uint64List {
  @patch
  factory UnmodifiableUint64ListView(Uint64List list) =>
      _UnmodifiableUint64ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableInt64ListView implements Int64List {
  @patch
  factory UnmodifiableInt64ListView(Int64List list) =>
      _UnmodifiableInt64ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableInt32x4ListView implements Int32x4List {
  @patch
  factory UnmodifiableInt32x4ListView(Int32x4List list) =>
      _UnmodifiableInt32x4ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableFloat32x4ListView implements Float32x4List {
  @patch
  factory UnmodifiableFloat32x4ListView(Float32x4List list) =>
      _UnmodifiableFloat32x4ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableFloat64x2ListView implements Float64x2List {
  @patch
  factory UnmodifiableFloat64x2ListView(Float64x2List list) =>
      _UnmodifiableFloat64x2ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableFloat32ListView implements Float32List {
  @patch
  factory UnmodifiableFloat32ListView(Float32List list) =>
      _UnmodifiableFloat32ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@patch
abstract class UnmodifiableFloat64ListView implements Float64List {
  @patch
  factory UnmodifiableFloat64ListView(Float64List list) =>
      _UnmodifiableFloat64ArrayView._(
          unsafeCast<_TypedListBase>(list)._typedData,
          list.offsetInBytes,
          list.length);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableInt8ArrayView extends _Int8ArrayView
    implements UnmodifiableInt8ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableInt8ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int8ArrayView_new")
  external factory _UnmodifiableInt8ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableUint8ArrayView extends _Uint8ArrayView
    implements UnmodifiableUint8ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableUint8ArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint8ArrayView_new")
  external factory _UnmodifiableUint8ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableUint8ClampedArrayView extends _Uint8ClampedArrayView
    implements UnmodifiableUint8ClampedListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableUint8ClampedArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint8ClampedArrayView_new")
  external factory _UnmodifiableUint8ClampedArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableInt16ArrayView extends _Int16ArrayView
    implements UnmodifiableInt16ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableInt16ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int16ArrayView_new")
  external factory _UnmodifiableInt16ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableUint16ArrayView extends _Uint16ArrayView
    implements UnmodifiableUint16ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableUint16ArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint16ArrayView_new")
  external factory _UnmodifiableUint16ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableInt32ArrayView extends _Int32ArrayView
    implements UnmodifiableInt32ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableInt32ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int32ArrayView_new")
  external factory _UnmodifiableInt32ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableUint32ArrayView extends _Uint32ArrayView
    implements UnmodifiableUint32ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableUint32ArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint32ArrayView_new")
  external factory _UnmodifiableUint32ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableInt64ArrayView extends _Int64ArrayView
    implements UnmodifiableInt64ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableInt64ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int64ArrayView_new")
  external factory _UnmodifiableInt64ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableUint64ArrayView extends _Uint64ArrayView
    implements UnmodifiableUint64ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableUint64ArrayView)
  @pragma("vm:external-name", "TypedDataView_Uint64ArrayView_new")
  external factory _UnmodifiableUint64ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableFloat32ArrayView extends _Float32ArrayView
    implements UnmodifiableFloat32ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableFloat32ArrayView)
  @pragma("vm:external-name", "TypedDataView_Float32ArrayView_new")
  external factory _UnmodifiableFloat32ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, double value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableFloat64ArrayView extends _Float64ArrayView
    implements UnmodifiableFloat64ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableFloat64ArrayView)
  @pragma("vm:external-name", "TypedDataView_Float64ArrayView_new")
  external factory _UnmodifiableFloat64ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, double value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableFloat32x4ArrayView extends _Float32x4ArrayView
    implements UnmodifiableFloat32x4ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableFloat32x4ArrayView)
  @pragma("vm:external-name", "TypedDataView_Float32x4ArrayView_new")
  external factory _UnmodifiableFloat32x4ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, Float32x4 value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableInt32x4ArrayView extends _Int32x4ArrayView
    implements UnmodifiableInt32x4ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableInt32x4ArrayView)
  @pragma("vm:external-name", "TypedDataView_Int32x4ArrayView_new")
  external factory _UnmodifiableInt32x4ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, Int32x4 value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableFloat64x2ArrayView extends _Float64x2ArrayView
    implements UnmodifiableFloat64x2ListView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableFloat64x2ArrayView)
  @pragma("vm:external-name", "TypedDataView_Float64x2ArrayView_new")
  external factory _UnmodifiableFloat64x2ArrayView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void operator []=(int index, Float64x2 value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

@pragma("vm:entry-point")
@pragma("wasm:entry-point")
final class _UnmodifiableByteDataView extends _ByteDataView
    implements UnmodifiableByteDataView {
  @pragma("vm:recognized", "other")
  @pragma("vm:exact-result-type", _UnmodifiableByteDataView)
  @pragma("vm:external-name", "TypedDataView_ByteDataView_new")
  external factory _UnmodifiableByteDataView._(
      _TypedList buffer, int offsetInBytes, int length);

  @override
  void setInt8(int byteOffset, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setUint8(int byteOffset, int value) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setInt16(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setUint16(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setInt32(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setUint32(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setInt64(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setUint64(int byteOffset, int value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setFloat32(int byteOffset, double value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setFloat64(int byteOffset, double value, [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  void setFloat32x4(int byteOffset, Float32x4 value,
      [Endian endian = Endian.big]) {
    throw UnsupportedError("Cannot modify an unmodifiable list");
  }

  @override
  _ByteBuffer get buffer => _UnmodifiableByteBufferView(_typedData.buffer);
}

final class _UnmodifiableByteBufferView extends _ByteBuffer
    implements UnmodifiableByteBufferView {
  _UnmodifiableByteBufferView(ByteBuffer data)
      : super(unsafeCast<_ByteBuffer>(data)._data);

  @override
  Uint8List asUint8List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableUint8ListView(super.asUint8List(offsetInBytes, length));

  @override
  Int8List asInt8List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableInt8ListView(super.asInt8List(offsetInBytes, length));

  @override
  Uint8ClampedList asUint8ClampedList([int offsetInBytes = 0, int? length]) =>
      UnmodifiableUint8ClampedListView(
          super.asUint8ClampedList(offsetInBytes, length));

  @override
  Uint16List asUint16List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableUint16ListView(super.asUint16List(offsetInBytes, length));

  @override
  Int16List asInt16List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableInt16ListView(super.asInt16List(offsetInBytes, length));

  @override
  Uint32List asUint32List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableUint32ListView(super.asUint32List(offsetInBytes, length));

  @override
  Int32List asInt32List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableInt32ListView(super.asInt32List(offsetInBytes, length));

  @override
  Uint64List asUint64List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableUint64ListView(super.asUint64List(offsetInBytes, length));

  @override
  Int64List asInt64List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableInt64ListView(super.asInt64List(offsetInBytes, length));

  @override
  Int32x4List asInt32x4List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableInt32x4ListView(
          super.asInt32x4List(offsetInBytes, length));

  @override
  Float32List asFloat32List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableFloat32ListView(
          super.asFloat32List(offsetInBytes, length));

  @override
  Float64List asFloat64List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableFloat64ListView(
          super.asFloat64List(offsetInBytes, length));

  @override
  Float32x4List asFloat32x4List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableFloat32x4ListView(
          super.asFloat32x4List(offsetInBytes, length));

  @override
  Float64x2List asFloat64x2List([int offsetInBytes = 0, int? length]) =>
      UnmodifiableFloat64x2ListView(
          super.asFloat64x2List(offsetInBytes, length));

  @override
  ByteData asByteData([int offsetInBytes = 0, int? length]) =>
      UnmodifiableByteDataView(super.asByteData(offsetInBytes, length));
}

// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of _interceptors;

class _Growable {
  const _Growable();
}

const _ListConstructorSentinel = _Growable();

/// The interceptor class for [List]. The compiler recognizes this
/// class as an interceptor, and changes references to [:this:] to
/// actually use the receiver of the method, which is generated as an extra
/// argument added to each member.
class JSArray<E> extends JavaScriptObject implements List<E>, JSIndexable<E> {
  const JSArray();

  /// Returns a fresh JavaScript Array, marked as fixed-length. The holes in the
  /// array yield `undefined`, making the Dart List appear to be filled with
  /// `null` values.
  ///
  /// [length] must be a non-negative integer.
  factory JSArray.fixed(int length) {
    // Explicit type test is necessary to guard against JavaScript conversions
    // in unchecked mode, and against `new Array(null)` which creates a single
    // element Array containing `null`.
    if (length is! int) {
      throw ArgumentError.value(length, 'length', 'is not an integer');
    }
    // The JavaScript Array constructor with one argument throws if the value is
    // not a UInt32 but the error message does not contain the bad value. Give a
    // better error message.
    int maxJSArrayLength = 0xFFFFFFFF;
    if (length < 0 || length > maxJSArrayLength) {
      throw RangeError.range(length, 0, maxJSArrayLength, 'length');
    }
    return JSArray<E>.markFixed(JS('', 'new Array(#)', length));
  }

  /// Returns a fresh JavaScript Array, marked as fixed-length.  The Array is
  /// allocated but no elements are assigned.
  ///
  /// All elements of the array must be assigned before the array is valid. This
  /// is essentially the same as `JSArray.fixed` except that global type
  /// inference starts with bottom for the element type.
  ///
  /// [length] must be a non-negative integer.
  factory JSArray.allocateFixed(int length) {
    // Explicit type test is necessary to guard against JavaScript conversions
    // in unchecked mode, and against `new Array(null)` which creates a single
    // element Array containing `null`.
    if (length is! int) {
      throw ArgumentError.value(length, 'length', 'is not an integer');
    }
    // The JavaScript Array constructor with one argument throws if the value is
    // not a UInt32 but the error message does not contain the bad value. Give a
    // better error message.
    int maxJSArrayLength = 0xFFFFFFFF;
    if (length < 0 || length > maxJSArrayLength) {
      throw RangeError.range(length, 0, maxJSArrayLength, 'length');
    }
    return JSArray<E>.markFixed(JS('', 'new Array(#)', length));
  }

  /// Returns a fresh growable JavaScript Array of zero length length.
  factory JSArray.emptyGrowable() => JSArray<E>.markGrowable(JS('', '[]'));

  /// Returns a fresh growable JavaScript Array with initial length. The holes
  /// in the array yield `undefined`, making the Dart List appear to be filled
  /// with `null` values.
  ///
  /// [length] must be a non-negative integer.
  factory JSArray.growable(int length) {
    // Explicit type test is necessary to guard against JavaScript conversions
    // in unchecked mode.
    if ((length is! int) || (length < 0)) {
      throw ArgumentError('Length must be a non-negative integer: $length');
    }
    return JSArray<E>.markGrowable(JS('', 'new Array(#)', length));
  }

  /// Returns a fresh growable JavaScript Array with initial length. The Array
  /// is allocated but no elements are assigned.
  ///
  /// All elements of the array must be assigned before the array is valid. This
  /// is essentially the same as `JSArray.growable` except that global type
  /// inference starts with bottom for the element type.
  ///
  /// [length] must be a non-negative integer.
  factory JSArray.allocateGrowable(int length) {
    // Explicit type test is necessary to guard against JavaScript conversions
    // in unchecked mode.
    if ((length is! int) || (length < 0)) {
      throw ArgumentError('Length must be a non-negative integer: $length');
    }
    return JSArray<E>.markGrowable(JS('', 'new Array(#)', length));
  }

  /// Constructor for adding type parameters to an existing JavaScript Array.
  /// The compiler specially recognizes this constructor.
  ///
  ///     var a = new JSArray<int>.typed(JS('JSExtendableArray', '[]'));
  ///     a is List<int>    --> true
  ///     a is List<String> --> false
  ///
  /// Usually either the [JSArray.markFixed] or [JSArray.markGrowable]
  /// constructors is used instead.
  ///
  /// The input must be a JavaScript Array.  The JS form is just a re-assertion
  /// to help type analysis when the input type is sloppy.
  factory JSArray.typed(allocation) => JS('JSArray', '#', allocation);

  factory JSArray.markFixed(allocation) =>
      JS('JSFixedArray', '#', markFixedList(JSArray<E>.typed(allocation)));

  factory JSArray.markGrowable(allocation) =>
      JS('JSExtendableArray', '#', JSArray<E>.typed(allocation));

  static List<T> markFixedList<T>(List<T> list) {
    // Functions are stored in the hidden class and not as properties in
    // the object. We never actually look at the value, but only want
    // to know if the property exists.
    JS('void', r'#.fixed$length = Array', list);
    return JS('JSFixedArray', '#', list);
  }

  static List<T> markUnmodifiableList<T>(List list) {
    // Functions are stored in the hidden class and not as properties in
    // the object. We never actually look at the value, but only want
    // to know if the property exists.
    JS('void', r'#.fixed$length = Array', list);
    JS('void', r'#.immutable$list = Array', list);
    return JS('JSUnmodifiableArray', '#', list);
  }

  static bool isFixedLength(JSArray a) {
    return !JS('bool', r'!#.fixed$length', a);
  }

  static bool isUnmodifiable(JSArray a) {
    return !JS('bool', r'!#.immutable$list', a);
  }

  static bool isGrowable(JSArray a) {
    return !isFixedLength(a);
  }

  static bool isMutable(JSArray a) {
    return !isUnmodifiable(a);
  }

  checkMutable(String reason) {
    if (!isMutable(this)) {
      throw UnsupportedError(reason);
    }
  }

  checkGrowable(String reason) {
    if (!isGrowable(this)) {
      throw UnsupportedError(reason);
    }
  }

  @override
  List<R> cast<R>() => List.castFrom<E, R>(this);
  @override
  void add(E value) {
    checkGrowable('add');
    JS('void', r'#.push(#)', this, value);
  }

  @override
  E removeAt(int index) {
    checkGrowable('removeAt');
    if (index is! int) throw argumentErrorValue(index);
    if (index < 0 || index >= length) {
      throw RangeError.value(index);
    }
    return JS('', r'#.splice(#, 1)[0]', this, index);
  }

  @override
  void insert(int index, E value) {
    checkGrowable('insert');
    if (index is! int) throw argumentErrorValue(index);
    if (index < 0 || index > length) {
      throw RangeError.value(index);
    }
    JS('void', r'#.splice(#, 0, #)', this, index, value);
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    checkGrowable('insertAll');
    RangeError.checkValueInInterval(index, 0, this.length, 'index');
    if (iterable is! EfficientLengthIterable) {
      iterable = iterable.toList();
    }
    int insertionLength = iterable.length;
    this._setLengthUnsafe(this.length + insertionLength);
    int end = index + insertionLength;
    this.setRange(end, this.length, this, index);
    this.setRange(index, end, iterable);
  }

  @override
  void setAll(int index, Iterable<E> iterable) {
    checkMutable('setAll');
    RangeError.checkValueInInterval(index, 0, this.length, 'index');
    for (var element in iterable) {
      this[index++] = element;
    }
  }

  @override
  E removeLast() {
    checkGrowable('removeLast');
    if (length == 0) throw diagnoseIndexError(this, -1);
    return JS('', r'#.pop()', this);
  }

  @override
  bool remove(Object? element) {
    checkGrowable('remove');
    for (int i = 0; i < this.length; i++) {
      if (this[i] == element) {
        JS('', r'#.splice(#, 1)', this, i);
        return true;
      }
    }
    return false;
  }

  /// Removes elements matching [test] from [this] List.
  @override
  void removeWhere(bool Function(E element) test) {
    checkGrowable('removeWhere');
    _removeWhere(test, true);
  }

  @override
  void retainWhere(bool Function(E element) test) {
    checkGrowable('retainWhere');
    _removeWhere(test, false);
  }

  void _removeWhere(bool Function(E element) test, bool removeMatching) {
    // Performed in two steps, to avoid exposing an inconsistent state
    // to the [test] function. First the elements to retain are found, and then
    // the original list is updated to contain those elements.

    // TODO(sra): Replace this algorithm with one that retains a list of ranges
    // to be removed.  Most real uses remove 0, 1 or a few clustered elements.

    List retained = [];
    int end = this.length;
    for (int i = 0; i < end; i++) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      // !test() ensures bool conversion in checked mode.
      if (!test(element) == removeMatching) {
        retained.add(element);
      }
      if (this.length != end) throw ConcurrentModificationError(this);
    }
    if (retained.length == end) return;
    this.length = retained.length;
    for (int i = 0; i < retained.length; i++) {
      // We don't need a bounds check or an element type check.
      JS('', '#[#] = #', this, i, retained[i]);
    }
  }

  @override
  Iterable<E> where(bool Function(E element) f) {
    return WhereIterable<E>(this, f);
  }

  @override
  Iterable<T> expand<T>(Iterable<T> Function(E element) f) {
    return ExpandIterable<E, T>(this, f);
  }

  @override
  void addAll(Iterable<E> collection) {
    checkGrowable('addAll');
    if (collection is JSArray) {
      _addAllFromArray(JS('', '#', collection));
      return;
    }
    int i = this.length;
    for (E e in collection) {
      assert(i++ == this.length || (throw ConcurrentModificationError(this)));
      JS('void', r'#.push(#)', this, e);
    }
  }

  void _addAllFromArray(JSArray array) {
    int len = array.length;
    if (len == 0) return;
    if (identical(this, array)) throw ConcurrentModificationError(this);
    for (int i = 0; i < len; i++) {
      JS('', '#.push(#[#])', this, array, i);
    }
  }

  @override
  @pragma('dart2js:noInline')
  void clear() {
    checkGrowable('clear');
    _clear();
  }

  void _clear() {
    _setLengthUnsafe(0);
  }

  @override
  void forEach(void Function(E element) f) {
    int end = this.length;
    for (int i = 0; i < end; i++) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      f(element);
      if (this.length != end) throw ConcurrentModificationError(this);
    }
  }

  @override
  Iterable<T> map<T>(T Function(E element) f) {
    return MappedListIterable<E, T>(this, f);
  }

  @override
  String join([String separator = '']) {
    var list = List.filled(this.length, "");
    for (int i = 0; i < this.length; i++) {
      list[i] = '${this[i]}';
    }
    return JS('String', '#.join(#)', list, separator);
  }

  @override
  Iterable<E> take(int n) {
    return SubListIterable<E>(this, 0, checkNotNullable(n, "count"));
  }

  @override
  Iterable<E> takeWhile(bool Function(E value) test) {
    return TakeWhileIterable<E>(this, test);
  }

  @override
  Iterable<E> skip(int n) {
    return SubListIterable<E>(this, n, null);
  }

  @override
  Iterable<E> skipWhile(bool Function(E value) test) {
    return SkipWhileIterable<E>(this, test);
  }

  @override
  E reduce(E Function(E previousValue, E element) combine) {
    int length = this.length;
    if (length == 0) throw IterableElementError.noElement();
    E value = this[0];
    for (int i = 1; i < length; i++) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      value = combine(value, element);
      if (length != this.length) throw ConcurrentModificationError(this);
    }
    return value;
  }

  @override
  T fold<T>(T initialValue, T Function(T previousValue, E element) combine) {
    var value = initialValue;
    int length = this.length;
    for (int i = 0; i < length; i++) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      value = combine(value, element);
      if (this.length != length) throw ConcurrentModificationError(this);
    }
    return value;
  }

  @override
  E firstWhere(bool Function(E) test, {E Function()? orElse}) {
    var end = this.length;
    for (int i = 0; i < end; ++i) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      if (test(element)) return element;
      if (this.length != end) throw ConcurrentModificationError(this);
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  E lastWhere(bool Function(E) test, {E Function()? orElse}) {
    int length = this.length;
    for (int i = length - 1; i >= 0; i--) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      if (test(element)) return element;
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  E singleWhere(bool Function(E) test, {E Function()? orElse}) {
    int length = this.length;
    E? match;
    bool matchFound = false;
    for (int i = 0; i < length; i++) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      if (test(element)) {
        if (matchFound) {
          throw IterableElementError.tooMany();
        }
        matchFound = true;
        match = element;
      }
      if (length != this.length) {
        throw ConcurrentModificationError(this);
      }
    }
    if (matchFound) return match as E;
    if (orElse != null) return orElse();
    throw IterableElementError.noElement();
  }

  @override
  E elementAt(int index) {
    return this[index];
  }

  @override
  List<E> sublist(int start, [int? end]) {
    checkNull(start); // TODO(ahe): This is not specified but co19 tests it.
    if (start is! int) throw argumentErrorValue(start);
    if (start < 0 || start > length) {
      throw RangeError.range(start, 0, length, 'start');
    }
    if (end == null) {
      end = length;
    } else {
      if (end is! int) throw argumentErrorValue(end);
      if (end < start || end > length) {
        throw RangeError.range(end, start, length, 'end');
      }
    }
    if (start == end) return <E>[];
    return JSArray<E>.markGrowable(
        JS('', r'#.slice(#, #)', this, start, end));
  }

  @override
  Iterable<E> getRange(int start, int end) {
    RangeError.checkValidRange(start, end, this.length);
    return SubListIterable<E>(this, start, end);
  }

  @override
  E get first {
    if (length > 0) return this[0];
    throw IterableElementError.noElement();
  }

  @override
  E get last {
    if (length > 0) return this[length - 1];
    throw IterableElementError.noElement();
  }

  @override
  E get single {
    if (length == 1) return this[0];
    if (length == 0) throw IterableElementError.noElement();
    throw IterableElementError.tooMany();
  }

  @override
  void removeRange(int start, int end) {
    checkGrowable('removeRange');
    RangeError.checkValidRange(start, end, this.length);
    int deleteCount = end - start;
    JS('', '#.splice(#, #)', this, start, deleteCount);
  }

  @override
  void setRange(int start, int end, Iterable<E> iterable, [int skipCount = 0]) {
    checkMutable('setRange');

    RangeError.checkValidRange(start, end, this.length);
    int length = end - start;
    if (length == 0) return;
    RangeError.checkNotNegative(skipCount, 'skipCount');

    List<E> otherList;
    int otherStart;
    // TODO(floitsch): Make this accept more.
    if (iterable is List) {
      otherList = JS<List<E>>('', '#', iterable);
      otherStart = skipCount;
    } else {
      otherList = iterable.skip(skipCount).toList(growable: false);
      otherStart = 0;
    }
    if (otherStart + length > otherList.length) {
      throw IterableElementError.tooFew();
    }
    if (otherStart < start) {
      // Copy backwards to ensure correct copy if [from] is this.
      // TODO(sra): If [from] is the same Array as [this], we can copy without
      // type annotation checks on the stores.
      for (int i = length - 1; i >= 0; i--) {
        // Use JS to avoid bounds check (the bounds check elimination
        // optimization is too weak). The 'E' type annotation is a store type
        // check - we can't rely on iterable, it could be List<dynamic>.
        E element = otherList[otherStart + i];
        JS('', '#[#] = #', this, start + i, element);
      }
    } else {
      for (int i = 0; i < length; i++) {
        E element = otherList[otherStart + i];
        JS('', '#[#] = #', this, start + i, element);
      }
    }
  }

  @override
  void fillRange(int start, int end, [E? fillValue]) {
    checkMutable('fill range');
    RangeError.checkValidRange(start, end, this.length);
    E checkedFillValue = fillValue as E;
    for (int i = start; i < end; i++) {
      // Store is safe since [checkedFillValue] type has been checked as
      // parameter and for null.
      JS('', '#[#] = #', this, i, checkedFillValue);
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<E> replacement) {
    checkGrowable('replaceRange');
    RangeError.checkValidRange(start, end, this.length);
    if (replacement is! EfficientLengthIterable) {
      replacement = replacement.toList();
    }
    int removeLength = end - start;
    int insertLength = replacement.length;
    if (removeLength >= insertLength) {
      int delta = removeLength - insertLength;
      int insertEnd = start + insertLength;
      int newLength = this.length - delta;
      this.setRange(start, insertEnd, replacement);
      if (delta != 0) {
        this.setRange(insertEnd, newLength, this, end);
        this.length = newLength;
      }
    } else {
      int delta = insertLength - removeLength;
      int newLength = this.length + delta;
      int insertEnd = start + insertLength; // aka. end + delta.
      this._setLengthUnsafe(newLength);
      this.setRange(insertEnd, newLength, this, end);
      this.setRange(start, insertEnd, replacement);
    }
  }

  @override
  bool any(bool Function(E element) test) {
    int end = this.length;
    for (int i = 0; i < end; i++) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      if (test(element)) return true;
      if (this.length != end) throw ConcurrentModificationError(this);
    }
    return false;
  }

  @override
  bool every(bool Function(E element) test) {
    int end = this.length;
    for (int i = 0; i < end; i++) {
      // TODO(22407): Improve bounds check elimination to allow this JS code to
      // be replaced by indexing.
      var element = JS<E>('', '#[#]', this, i);
      if (!test(element)) return false;
      if (this.length != end) throw ConcurrentModificationError(this);
    }
    return true;
  }

  @override
  Iterable<E> get reversed => ReversedListIterable<E>(this);

  @override
  void sort([int Function(E, E)? compare]) {
    checkMutable('sort');
    Sort.sort(this, compare ?? _compareAny);
  }

  static int _compareAny(a, b) {
    return Comparable.compare(a, b);
  }

  @override
  void shuffle([Random? random]) {
    checkMutable('shuffle');
    random ??= Random();
    int length = this.length;
    while (length > 1) {
      int pos = random.nextInt(length);
      length -= 1;
      var tmp = this[length];
      this[length] = this[pos];
      this[pos] = tmp;
    }
  }

  @override
  int indexOf(Object? element, [int start = 0]) {
    int length = this.length;
    if (start >= length) {
      return -1;
    }
    if (start < 0) {
      start = 0;
    }
    for (int i = start; i < length; i++) {
      if (this[i] == element) {
        return i;
      }
    }
    return -1;
  }

  @override
  int lastIndexOf(Object? element, [int? startIndex]) {
    int start = startIndex ?? this.length - 1;
    if (start < 0) {
      return -1;
    }
    if (start >= this.length) {
      start = this.length - 1;
    }
    for (int i = start; i >= 0; i--) {
      if (this[i] == element) {
        return i;
      }
    }
    return -1;
  }

  @override
  bool contains(Object? other) {
    for (int i = 0; i < length; i++) {
      E element = JS('', '#[#]', this, i);
      if (element == other) return true;
    }
    return false;
  }

  @override
  bool get isEmpty => length == 0;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() => ListBase.listToString(this);

  @override
  List<E> toList({bool growable = true}) =>
      growable ? _toListGrowable() : _toListFixed();

  List<E> _toListGrowable() =>
      // slice(0) is slightly faster than slice()
      JSArray<E>.markGrowable(JS('', '#.slice(0)', this));

  List<E> _toListFixed() =>
      JSArray<E>.markFixed(JS('', '#.slice(0)', this));

  @override
  Set<E> toSet() => Set<E>.from(this);

  @override
  Iterator<E> get iterator => ArrayIterator<E>(this);

  @override
  int get hashCode => Primitives.objectHashCode(this);

  @override
  int get length => JS('JSUInt32', r'#.length', this);

  @override
  set length(int newLength) {
    checkGrowable('set length');
    if (newLength is! int) {
      throw ArgumentError.value(newLength, 'newLength');
    }
    // TODO(sra): Remove this test and let JavaScript throw an error.
    if (newLength < 0) {
      throw RangeError.range(newLength, 0, null, 'newLength');
    }

    // Verify that element type is nullable.
    if (newLength > length) null as E;

    // JavaScript with throw a RangeError for numbers that are too big. The
    // message does not contain the value.
    JS('void', r'#.length = #', this, newLength);
  }

  /// Unsafe alternative to the [length] setter that skips the check and will
  /// not fail when increasing the size of a list of non-nullable elements.
  ///
  /// To ensure null safe soundness this should only be called when every new
  /// index will be filled before returning.
  ///
  /// Should only be called when the list is already known to be growable.
  void _setLengthUnsafe(int newLength) {

    assert(newLength >= 0,
        throw RangeError.range(newLength, 0, null, 'newLength'));

    // JavaScript with throw a RangeError for numbers that are too big. The
    // message does not contain the value.
    JS('void', r'#.length = #', this, newLength);
  }

  @override
  E operator [](int index) {
    if (index is! int) throw diagnoseIndexError(this, index);
    // This form of the range test correctly rejects NaN.
    if (!(index >= 0 && index < length)) throw diagnoseIndexError(this, index);
    return JS('', '#[#]', this, index);
  }

  @override
  void operator []=(int index, E value) {
    checkMutable('indexed set');
    if (index is! int) throw diagnoseIndexError(this, index);
    // This form of the range test correctly rejects NaN.
    if (!(index >= 0 && index < length)) throw diagnoseIndexError(this, index);
    JS('void', r'#[#] = #', this, index, value);
  }

  @override
  Map<int, E> asMap() {
    return ListMapView<E>(this);
  }

  @override
  Iterable<E> followedBy(Iterable<E> other) =>
      FollowedByIterable<E>.firstEfficient(this, other);

  @override
  Iterable<T> whereType<T>() => WhereTypeIterable<T>(this);

  @override
  List<E> operator +(List<E> other) => [...this, ...other];

  @override
  int indexWhere(bool Function(E element) test, [int start = 0]) {
    if (start >= this.length) return -1;
    if (start < 0) start = 0;
    for (int i = start; i < this.length; i++) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  int lastIndexWhere(bool Function(E element) test, [int? start]) {
    start ??= this.length - 1;
    if (start < 0) return -1;
    for (int i = start; i >= 0; i--) {
      if (test(this[i])) return i;
    }
    return -1;
  }

  @override
  set first(E element) {
    if (this.isEmpty) throw IterableElementError.noElement();
    this[0] = element;
  }

  @override
  set last(E element) {
    if (this.isEmpty) throw IterableElementError.noElement();
    this[this.length - 1] = element;
  }

  // Specialized version of `get runtimeType` is needed here so that
  // `Interceptor.runtimeType` can avoid testing for `JSArray`.
  @override
  Type get runtimeType => getRuntimeTypeOfArray(this);
}

/// Dummy subclasses that allow the backend to track more precise
/// information about arrays through their type. The CPA type inference
/// relies on the fact that these classes do not override [] nor []=.
///
/// These classes are really a fiction, and can have no methods, since
/// getInterceptor always returns JSArray.  We should consider pushing the
/// 'isGrowable' and 'isMutable' checks into the getInterceptor implementation
/// so these classes can have specialized implementations. Doing so will
/// challenge many assumptions in the JS backend.
class JSMutableArray<E> extends JSArray<E> implements JSMutableIndexable<E> {}

class JSFixedArray<E> extends JSMutableArray<E> {}

class JSExtendableArray<E> extends JSMutableArray<E> {}

class JSUnmodifiableArray<E> extends JSArray<E> {} // Already is JSIndexable.

/// An [Iterator] that iterates a JSArray.
///
class ArrayIterator<E> implements Iterator<E> {
  final JSArray<E> _iterable;
  final int _length;
  int _index;
  E? _current;

  ArrayIterator(JSArray<E> iterable)
      : _iterable = iterable,
        _length = iterable.length,
        _index = 0;

  @override
  E get current => _current as E;

  @override
  bool moveNext() {
    int length = _iterable.length;

    // We have to do the length check even on fixed length Arrays.  If we can
    // inline moveNext() we might be able to GVN the length and eliminate this
    // check on known fixed length JSArray.
    if (_length != length) {
      throw throwConcurrentModificationError(_iterable);
    }

    if (_index >= length) {
      _current = null;
      return false;
    }
    _current = _iterable[_index];
    _index++;
    return true;
  }
}

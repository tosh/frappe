part of frappe;

/// A property is an observable with the concept of a current value.
///
/// Calling [listen] on a property will deliver its current value, if one exists.
/// This means that if the property has previously emitted the value of *x* to
/// its subscribers, it will deliver this value to any new subscribers. Depending
/// on how the property was created, some properties might not have an initial
/// value to start with.
// Extend dynamic to suppress warnings with operator overrides
abstract class Property<T extends dynamic> extends Reactable<T> {
  /// An [EventStream] that contains the changes of the property.
  ///
  /// The stream will *not* contain an event for the current value of the `Property`.
  EventStream<T> get changes;

  Property._();

  /// Returns a new property where its current value is always [value].
  factory Property.constant(T value) => new _ConstantProperty(value);

  /// Returns a new property where its current value is the latest value emitted
  /// from [stream].
  factory Property.fromStream(Stream<T> stream) => new _StreamProperty(stream);

  /// Returns a new property where its starting value is [initialValue], and its
  /// value after that is the latest value emitted from [stream].
  factory Property.fromStreamWithInitialValue(T initialValue, Stream<T> stream) =>
      new _StreamProperty.initialValue(stream, initialValue);

  /// Returns a new property where its current value is the completed value of
  /// the [future].
  factory Property.fromFuture(Future<T> future) =>
      new Property.fromStream(new Stream.fromFuture(future));

  /// Returns a new property where the starting value is [initialValue], and its
  /// value after that is the value from [future].
  factory Property.fromFutureWithInitialValue(T initialValue, Future<T> future) =>
      new Property.fromStreamWithInitialValue(initialValue, new Stream.fromFuture(future));

  @override
  Property<T> asProperty() {
    return this;
  }

  @override
  Property<T> asPropertyWithInitialValue(T initialValue) {
    return new Property.fromStreamWithInitialValue(initialValue, changes);
  }

  @override
  /// Returns a stream that contains events for the current value of this `Property`,
  /// as well as any of its changes.
  EventStream<T> asStream() {
    return new EventStream(new _ReactableAsStream(this));
  }

  Property combine(Property other, compute(T a, b)) => new _CombinedProperty(this, other, compute);

  /// Combines this property and [other] with the `&&` operator.
  Property<bool> and(Property<bool> other) => combine(other, (a, b) => a && b);

  /// Combines this property and [other] with the `||` operator.
  Property<bool> or(Property<bool> other) => combine(other, (a, b) => a || b);

  /// Combines this property and [other] with the `==` operator.
  Property<bool> equals(Property other) => combine(other, (a, b) => a == b);

  Property<bool> not() => map((value) => !value).asProperty();

  /// Combines this property and [other] with the `>` operator.
  Property<bool> operator >(Property other) => combine(other, (a, b) => a > b);

  /// Combines this property and [other] with the `>=` operator.
  Property<bool> operator >=(Property other) => combine(other, (a, b) => a >= b);

  /// Combines this property and [other] with the `<` operator.
  Property<bool> operator <(Property other) => combine(other, (a, b) => a < b);

  /// Combines this property and [other] with the `<=` operator.
  Property<bool> operator <=(Property other) => combine(other, (a, b) => a <= b);

  /// Combines this property and [other] with the `+` operator.
  Property operator +(Property other) => combine(other, (a, b) => a + b);

  /// Combines this property and [other] with the `-` operator.
  Property operator -(Property other) => combine(other, (a, b) => a - b);

  /// Combines this property and [other] with the `*` operator.
  Property operator *(Property other) => combine(other, (a, b) => a * b);

  /// Combines this property and [other] with the `/` operator.
  Property operator /(Property other) => combine(other, (a, b) => a / b);
}

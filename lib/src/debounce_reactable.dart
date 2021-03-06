part of frappe;

class _DebounceReactable<T> extends _ForwardingReactable<T> {
  Duration _duration;
  Timer _throttler;

  _DebounceReactable(Reactable<T> reactable, this._duration) : super(reactable);

  @override
  void onData(EventSink<T> sink, T event) {
    if (_throttler == null) {
      super.onData(sink, event);
      _throttle();
    } else {
      _throttle(() => super.onData(sink, event));
    }
  }

  void _throttle([void block()]) {
    if (_throttler != null) {
      _throttler.cancel();
      _throttler = null;
    }

    _throttler = new Timer(_duration, () {
      if (block != null) {
        block();
      }
    });
  }
}
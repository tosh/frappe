library reactive.test_runner;

import 'event_stream_test.dart' as ReactiveStreamTest;
import 'stream_signal_test.dart' as StreamSignalTest;

void main() {
  ReactiveStreamTest.main();
  StreamSignalTest.main();
}
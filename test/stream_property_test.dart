library stream_property_test;

import 'dart:async';
import 'package:guinness/guinness.dart';
import 'package:unittest/unittest.dart' show expectAsync;
import 'package:frappe/frappe.dart';
import 'callback_helpers.dart';

void main() => describe("StreamProperty", () {
  StreamController controller;
  Property property;

  beforeEach(() {
    controller = new StreamController();
  });

  describe("listen()", () {
    beforeEach(() => property = new Property.fromStream(controller.stream));

    describe("with initial value", () {
      beforeEach(() => property = new Property.fromStreamWithInitialValue(1, controller.stream));

      describe("without any subscriptions", () {
        beforeEach(() => controller.add(2));

        it("first value is the initial value", () {
          listenToFirstEvent(property, expectAsync((value) => expect(value).toBe(1)));
        });
      });

      describe("with subscriptions", () {
        StreamSubscription previousSubscription;

        beforeEach(() {
          controller.add(2);
          previousSubscription = property.listen(doNothing);
        });

        afterEach(() => previousSubscription.cancel());

        it("first value is 2", () {
          listenToFirstEvent(property, expectAsync((value) => expect(value).toBe(2)));
        });
      });
    });

    describe("without initial value", () {
      beforeEach(() => property = new Property.fromStream(controller.stream));

      it("first value is the next value in the stream", () {
        listenToFirstEvent(property, expectAsync((value) => expect(value).toBe(2)));
        controller.add(2);
      });
    });

    it("onError is called when stream receives errors", () {
      property.listen(doNothing,
          onError: expectAsync((error, stackTrace) => expect(error).toBeNotNull()),
          cancelOnError: true);

      controller.addError("Error");
    });
  });
});

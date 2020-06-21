import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

import 'isolates_workaround.dart';

extension WaitForText on FlutterDriver {
  Future<void> waitForText(SerializableFinder finder, String text, {int retries = 10}) async {
    try {
      expect(await getText(finder), equals(text));
    } catch (_) {
      if (retries == 0) {
        rethrow;
      }
      await Future.delayed(Duration(milliseconds: 17), () {});
      await waitForText(finder, text, retries: retries - 1);
    }
  }
}

// Note: current flutter_driver pauses all isolates on startup. This breaks the use of compute
// for asynchronous processing. We use [1] as a workaround.
//
// Also note that we need to wait for the application to display the expected text, so we use
// [2] as a workaround for that too.
//
// [1] https://github.com/flutter/flutter/issues/24703#issuecomment-531277291
// [2] https://github.com/flutter/flutter/issues/52940
void main() {
  group('Libsodium', () {
    FlutterDriver driver;
    IsolatesWorkaround workaround;

    // Connect to the Flutter driver before running any tests.
    setUpAll(() async {
      driver = await FlutterDriver.connect();
      await driver.checkHealth();
      workaround = IsolatesWorkaround(driver);
      await workaround.resumeIsolates();
    });

    // Close the connection to the driver after the tests have completed.
    tearDownAll(() async {
      if (driver != null) {
        await driver.close();
        await workaround.tearDown();
      }
    });

    test('version is present', () async {
      final versionFinder = find.byValueKey('version');
      await driver.waitForText(versionFinder, "Using libsodium: 1.0.18");
    });
  });
}

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_libsodium/libsodium_wrapper.dart';

class FlutterLibsodium {
  final wrapper = LibsodiumWrapper();

  String getSodiumVersion() {
    return wrapper.sodiumVersionString();
  }
}

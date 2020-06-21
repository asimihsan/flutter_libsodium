import 'package:ffi/ffi.dart';
import 'package:flutter_libsodium/libsodium_bindings.dart' as bindings;

class LibsodiumError extends Error {}

class LibsodiumCouldNotInitError extends LibsodiumError {}

class LibsodiumWrapper {
  LibsodiumWrapper() {
    if (sodiumInit() < 0) {
      throw LibsodiumCouldNotInitError();
    }
  }

  int sodiumInit() {
    return bindings.sodiumInit();
  }

  String sodiumVersionString() {
    return Utf8.fromUtf8(bindings.sodiumVersionString());
  }
}

String getSodiumVersionString(final LibsodiumWrapper wrapper) => wrapper.sodiumVersionString();

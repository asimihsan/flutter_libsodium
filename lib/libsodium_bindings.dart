library bindings;

import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';

final libsodium = _load();

DynamicLibrary _load() {
  if (Platform.isAndroid) {
    return DynamicLibrary.open("libsodium.so");
  } else {
    return DynamicLibrary.process();
  }
}

// https://doc.libsodium.org/quickstart#boilerplate
// https://github.com/jedisct1/libsodium/blob/2d5b954/src/libsodium/sodium/core.c#L27-L53
typedef NativeInit = Int32 Function();
typedef Init = int Function();
final Init sodiumInit = libsodium.lookupFunction<NativeInit, Init>('sodium_init');

// https://github.com/jedisct1/libsodium/blob/927dfe8/src/libsodium/sodium/version.c#L4-L8
typedef NativeVersionString = Pointer<Utf8> Function();
typedef VersionString = Pointer<Utf8> Function();
final VersionString sodiumVersionString =
    libsodium.lookupFunction<NativeVersionString, VersionString>('sodium_version_string');

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

// IntPtr is sign-extended, but we know size_t is unsigned so that's OK
// see: https://github.com/dart-lang/sdk/issues/39372
// see: https://github.com/dart-lang/sdk/issues/36140
// see: https://github.com/jedisct1/libsodium/blob/927dfe8/src/libsodium/crypto_secretbox/crypto_secretbox.c#L6
// see: https://github.com/dart-lang/sdk/blob/48f7636798260bcf84bab46fd3c92102c508e959/runtime/tools/dartfuzz/dartfuzz_ffi_api.dart
typedef NativeReturnSizeT = IntPtr Function();

final int Function() crypto_box_SEALBYTES =
    libsodium.lookup<NativeFunction<NativeReturnSizeT>>('crypto_box_sealbytes').asFunction();

// libsodium uses canary pages, guard pages, memory locking, and fills malloc'd memory with a
// specific byte pattern [1]. Whenever allocating memory in order to interact with libsodium
// we prefer to use libsodium's sodium_malloc and sodium_free.
//
// [1] https://doc.libsodium.org/memory_management
typedef Malloc = Pointer<Uint8> Function(int size);
typedef NativeMalloc = Pointer<Uint8> Function(IntPtr size);
final Malloc sodiumMalloc = libsodium.lookupFunction<NativeMalloc, Malloc>('sodium_malloc');

// https://doc.libsodium.org/memory_management
typedef Free = void Function(Pointer<Uint8> ptr);
typedef NativeFree = Void Function(Pointer<Uint8> ptr);
final Free sodiumFree = libsodium.lookupFunction<NativeFree, Free>('sodium_free');

// https://doc.libsodium.org/public-key_cryptography/sealed_boxes
//  int crypto_box_seal(unsigned char *c, const unsigned char *m,
//                      unsigned long long mlen, const unsigned char *pk);
typedef CryptoBoxSeal = int Function(
    Pointer<Uint8> c, Pointer<Uint8> m, int mlen, Pointer<Uint8> pk);
typedef NativeCryptoBoxSeal = Int32 Function(
    Pointer<Uint8> c, Pointer<Uint8> m, Uint64 mlen, Pointer<Uint8> pk);
final CryptoBoxSeal cryptoBoxSeal =
    libsodium.lookupFunction<NativeCryptoBoxSeal, CryptoBoxSeal>('crypto_box_seal');

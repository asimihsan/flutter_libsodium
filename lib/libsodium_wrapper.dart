import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

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

  // https://doc.libsodium.org/public-key_cryptography/sealed_boxes
  String cryptoBoxSeal(final String recipientPublicKeyBase64Encoded, final String plaintext) {
    final int cryptoBoxSealBytes = bindings.crypto_box_SEALBYTES();
    final cLength = plaintext.length + cryptoBoxSealBytes;
    final c = bindings.sodiumMalloc(cLength);
    final m = plaintext.toUint8Pointer();
    final Uint8List recipientPublicKey = base64.decode(recipientPublicKeyBase64Encoded);
    final pk = recipientPublicKey.toPointer();
    try {
      bindings.cryptoBoxSeal(c, m, plaintext.length, pk);
      final Uint8List result = c.toList(cLength);
      return base64.encode(result);
    } finally {
      bindings.sodiumFree(c);
      bindings.sodiumFree(m);
      bindings.sodiumFree(pk);
    }
  }
}

String getSodiumVersionString(final LibsodiumWrapper wrapper) => wrapper.sodiumVersionString();

// Can't pass more than one argument via compute, so use a custom object instead.
//
// See: https://github.com/flutter/flutter/issues/34540
// See: https://stackoverflow.com/questions/54074857/send-multiple-arguments-to-the-compute-function-in-flutter
class CryptoBoxSealCall {
  final LibsodiumWrapper wrapper;
  final String recipientPublicKeyBase64Encoded;
  final String plaintext;

  CryptoBoxSealCall(this.wrapper, this.recipientPublicKeyBase64Encoded, this.plaintext);
}

String cryptoBoxSeal(final CryptoBoxSealCall call) =>
    call.wrapper.cryptoBoxSeal(call.recipientPublicKeyBase64Encoded, call.plaintext);

extension Uint8PointerExtensions on Pointer<Uint8> {
  Uint8List toList(int length) {
    final builder = BytesBuilder();
    for (int i = 0; i < length; i++) {
      builder.addByte(this[i]);
    }
    return builder.takeBytes();
  }
}

extension Uint8ListExtensions on Uint8List {
  Pointer<Uint8> toPointer() {
    if (this == null) {
      return Pointer<Uint8>.fromAddress(0);
    }
    final p = bindings.sodiumMalloc(this.length);
    final pList = p.asTypedList(this.length);
    pList.setAll(0, this);
    return p;
  }
}

extension StringExtensions on String {
  Pointer<Uint8> toUint8Pointer() {
    if (this == null) {
      return Pointer<Uint8>.fromAddress(0);
    }
    final units = utf8.encode(this);
    final Pointer<Uint8> result = bindings.sodiumMalloc(units.length);
    final Uint8List nativeString = result.asTypedList(units.length);
    nativeString.setAll(0, units);
    return result;
  }
}

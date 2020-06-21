import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libsodium/libsodium_wrapper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final wrapper = LibsodiumWrapper();
  final String serverPublicKeyBase64Encoded = "lKSTP8K5YQoHMZOn2+mTLunP3yMgqN1O8GyaqRvHbQE=";
  final plaintextController = TextEditingController();

  String _sodiumVersion = 'Unknown Sodium Version';
  String _encryptedData = '';

  @override
  void initState() {
    super.initState();
    getSodiumVersion();
  }

  @override
  void dispose() {
    plaintextController.dispose();
    super.dispose();
  }

  Future<void> getSodiumVersion() async {
    final sodiumVersion = await compute(getSodiumVersionString, wrapper);
    setState(() {
      _sodiumVersion = sodiumVersion;
    });
  }

  Future<void> encryptData(final String plaintext) async {
    final encryptedData = await compute(
        cryptoBoxSeal, CryptoBoxSealCall(wrapper, serverPublicKeyBase64Encoded, plaintext));
    setState(() {
      _encryptedData = encryptedData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Using libsodium: $_sodiumVersion', key: Key('version')),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Text to encrypt',
                ),
                key: Key('plaintextTextField'),
                controller: plaintextController,
              ),
              SelectableText('Encrypted data: $_encryptedData', key: Key('encryptedData')),
              FlatButton(
                color: Colors.blue,
                textColor: Colors.white,
                disabledColor: Colors.grey,
                disabledTextColor: Colors.black,
                padding: EdgeInsets.all(8.0),
                splashColor: Colors.blueAccent,
                onPressed: () async {
                  encryptData(plaintextController.text);
                },
                child: Text(
                  "Encrypt",
                  style: TextStyle(fontSize: 20.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

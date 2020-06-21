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

  String _sodiumVersion = 'Unknown Sodium Version';

  @override
  void initState() {
    super.initState();
    getSodiumVersion();
  }

  Future<void> getSodiumVersion() async {
    final sodiumVersion = await compute(getSodiumVersionString, wrapper);
    setState(() {
      _sodiumVersion = sodiumVersion;
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
          child: Text('Using libsodium: $_sodiumVersion', key: Key('version')),
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSy-dummy-web-api-key',
    appId: '1:938059660740:web:dummy-id',
    messagingSenderId: '938059660740',
    projectId: 'finbos-2b19f',
    authDomain: 'finbos-2b19f.firebaseapp.com',
    storageBucket: 'finbos-2b19f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBSLFIiGXWFXZUE8L99UKEhvYHYM4Tzw9I',
    appId: '1:938059660740:ios:de096d52c696e2c2dd7891',
    messagingSenderId: '938059660740',
    projectId: 'finbos-2b19f',
    storageBucket: 'finbos-2b19f.firebasestorage.app',
    iosBundleId: 'com.finbos.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDC5QQ5LgOWjZMEtnb_iM2yvgah2tCLXJU',
    appId: '1:938059660740:android:e171b2cf9cfa4befdd7891',
    messagingSenderId: '938059660740',
    projectId: 'finbos-2b19f',
    storageBucket: 'finbos-2b19f.firebasestorage.app',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (Platform.isIOS) return ios;
    if (Platform.isAndroid) return android;
    // Fallback to iOS options for other platforms that don't use native files
    return ios;
  }
}

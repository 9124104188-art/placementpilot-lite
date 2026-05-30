import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      case TargetPlatform.fuchsia:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCdlnpBHhOQnCYtrMEfO820GKmo29Kk5qI',
    appId: '1:627035367072:web:69ff60dabd7e6281088bc5',
    messagingSenderId: '627035367072',
    projectId: 'placementpilot-lite',
    authDomain: 'placementpilot-lite.firebaseapp.com',
    storageBucket: 'placementpilot-lite.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdlnpBHhOQnCYtrMEfO820GKmo29Kk5qI',
    appId: '1:627035367072:android:69ff60dabd7e6281088bc5',
    messagingSenderId: '627035367072',
    projectId: 'placementpilot-lite',
    authDomain: 'placementpilot-lite.firebaseapp.com',
    storageBucket: 'placementpilot-lite.firebasestorage.app',
  );

  static const FirebaseOptions ios = web;
  static const FirebaseOptions macos = web;
  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}

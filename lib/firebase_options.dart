/// File konfigurasi Firebase.
/// Mendukung multiplatform: Android, iOS, Web, dan Windows.
library;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

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
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAURHAI9pRMMs7sA1yVVPATuc_Q8Kze1EE',
    appId: '1:841416327468:android:2386c216b692e5a8a3ec89',
    messagingSenderId: '841416327468',
    projectId: 'lactadel',
    databaseURL: 'https://lactadel-default-rtdb.firebaseio.com',
    storageBucket: 'lactadel.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVMxVWrAO3COazbgNPeL1MirTHxwbk4e4',
    appId: '1:841416327468:ios:fd5575df0b7ac23ea3ec89',
    messagingSenderId: '841416327468',
    projectId: 'lactadel',
    databaseURL: 'https://lactadel-default-rtdb.firebaseio.com',
    storageBucket: 'lactadel.firebasestorage.app',
    iosClientId: '841416327468-1t333cnpj5j154dj1auemtl2g9kvpr40.apps.googleusercontent.com',
    iosBundleId: 'com.lactadel.lactadel',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3ynyQG_jlpFYxIAiPTuy4N1lmoFrb91c',
    appId: '1:841416327468:web:ee121379aa03089ca3ec89',
    messagingSenderId: '841416327468',
    projectId: 'lactadel',
    authDomain: 'lactadel.firebaseapp.com',
    databaseURL: 'https://lactadel-default-rtdb.firebaseio.com',
    storageBucket: 'lactadel.firebasestorage.app',
    measurementId: 'G-2CZJRN9894',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC3ynyQG_jlpFYxIAiPTuy4N1lmoFrb91c',
    appId: '1:841416327468:web:6d50f62d0fe8c907a3ec89',
    messagingSenderId: '841416327468',
    projectId: 'lactadel',
    authDomain: 'lactadel.firebaseapp.com',
    databaseURL: 'https://lactadel-default-rtdb.firebaseio.com',
    storageBucket: 'lactadel.firebasestorage.app',
    measurementId: 'G-JBPSLKJE5X',
  );
}

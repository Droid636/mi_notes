import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      default:
        throw UnsupportedError(
          'Plataforma no soportada por la configuración de Firebase',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCyqJvFx6MuLshUnd9yxhHlhR76-bvYHj0",
    authDomain: "minotesfreppi.firebaseapp.com",
    projectId: "minotesfreppi",
    storageBucket: "minotesfreppi.appspot.com",
    messagingSenderId: "848777551907",
    appId: "1:848777551907:web:9fe3664c983c7a5ef61196",
    measurementId: "G-JRJL7KJLS2",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCyqJvFx6MuLshUnd9yxhHlhR76-bvYHj0",
    appId: "1:848777551907:android:9fe3664c983c7a5ef61196",
    messagingSenderId: "848777551907",
    projectId: "minotesfreppi",
    storageBucket: "minotesfreppi.appspot.com",
    measurementId: "G-JRJL7KJLS2",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyCyqJvFx6MuLshUnd9yxhHlhR76-bvYHj0",
    appId: "1:848777551907:ios:9fe3664c983c7a5ef61196",
    messagingSenderId: "848777551907",
    projectId: "minotesfreppi",
    storageBucket: "minotesfreppi.appspot.com",
    iosBundleId: "com.example.miNotesApp",
    measurementId: "G-JRJL7KJLS2",
  );
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseService {
  static Future<void> initializeFirebase() async {
    if (kIsWeb) {
      // 🔥 Configuración para la versión Web
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyCyqJvFx6MuLshUnd9yxhHlhR76-bvYHj0",
          authDomain: "minotesfreppi.firebaseapp.com",
          projectId: "minotesfreppi",
          storageBucket: "minotesfreppi.firebasestorage.app",
          messagingSenderId: "848777551907",
          appId: "1:848777551907:web:9fe3664c983c7a5ef61196",
          measurementId: "G-JRJL7KJLS2",
        ),
      );
    } else {
      // 🔥 Para Android e iOS
      await Firebase.initializeApp();
    }
  }
}

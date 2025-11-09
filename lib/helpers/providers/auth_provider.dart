import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear usuario y guardar en Firestore
  Future<UserModel?> signUp(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      // Crear usuario en Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        // 🔹 Crear objeto UserModel
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: displayName,
        );

        // Guardar usuario en firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        return userModel;
      }
    } catch (e) {
      print('Error en registro: $e');
    }
    return null;
  }

  // Iniciar sesión
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        // Obtener datos adicionales de Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          return UserModel.fromMap(doc.data()!);
        } else {
          // Si no existe en Firestore, crear un UserModel básico
          final userModel = UserModel(uid: user.uid, email: user.email ?? '');
          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toMap());
          return userModel;
        }
      }
    } catch (e) {
      print('Error en login: $e');
    }
    return null;
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }
}

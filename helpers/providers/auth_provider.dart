import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Crear usuario
  Future<UserModel?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        return UserModel(uid: user.uid, email: user.email ?? '');
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
        return UserModel(uid: user.uid, email: user.email ?? '');
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

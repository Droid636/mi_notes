import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user_model.dart';

class AuthProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Getter para obtener el usuario autenticado actual
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signUp(
    String email,
    String password,
    String? displayName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: displayName,
        );

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

  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data()!);
        } else {
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

  Future<void> logout() async {
    await _auth.signOut();
  }
}

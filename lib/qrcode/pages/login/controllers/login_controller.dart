import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      final deviceId = await _getDeviceId();

      final docRef = _firestore.collection('usuarios').doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        final newUser = UserModel(
          id: user.uid,
          nome: user.displayName ?? '',
          email: user.email ?? '',
          role: 'aluno',
          deviceId: deviceId,
        );

        await docRef.set({
          ...newUser.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
          'ultimo_login': FieldValue.serverTimestamp(),
        });
      } else {
        final data = docSnap.data()!;
        final savedDeviceId = data['deviceId'];
        final role = data['role'] ?? 'aluno';

        if (role == 'aluno' && savedDeviceId != null && savedDeviceId != deviceId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Sua conta já está conectada em outro dispositivo.'),
              backgroundColor: Colors.red,
            ),
          );
          await _auth.signOut();
          return;
        }

        await docRef.update({
          'ultimo_login': FieldValue.serverTimestamp(),
          'deviceId': deviceId,
        });
      }

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao logar: $e')),
      );
    }
  }
}

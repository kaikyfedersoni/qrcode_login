import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id; // ID único do dispositivo Android
    } else if (Platform.isIOS) {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? 'unknown_ios_device';
    } else {
      return 'unsupported_device';
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Etapa 1: Login via Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // usuário cancelou login

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Etapa 2: Captura o ID do dispositivo
      final deviceId = await _getDeviceId();

      if (user != null) {
        final userRef = _db.collection('users').doc(user.uid);
        final userDoc = await userRef.get();

        if (!userDoc.exists) {
          // Primeiro login — cria documento com deviceId
          await userRef.set({
            'uid': user.uid,
            'displayName': user.displayName,
            'email': user.email,
            'role': 'student', // por padrão
            'deviceId': deviceId,
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else {
          final savedDeviceId = userDoc.data()?['deviceId'];

          if (savedDeviceId != null && savedDeviceId != deviceId) {
            // ⚠️ Dispositivo diferente detectado
            await _db.collection('alerts').add({
              'uid': user.uid,
              'email': user.email,
              'oldDevice': savedDeviceId,
              'newDevice': deviceId,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }

          // Atualiza último login
          await userRef.update({
            'lastLogin': FieldValue.serverTimestamp(),
            'deviceId': savedDeviceId ?? deviceId,
          });
        }
      }

      return user;
    } catch (e) {
      print("Erro ao fazer login com Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}

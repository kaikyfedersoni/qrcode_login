import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para gerar um ID único do dispositivo
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // cada aparelho Android tem um ID único
  }

  Future<void> signInWithGoogle() async {
    try {
      // Força logout anterior para escolher conta novamente
      await _googleSignIn.signOut();

      // Login Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Login no Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      // Obtém ID do dispositivo
      final deviceId = await _getDeviceId();

      final docRef = _firestore.collection('usuarios').doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // Novo usuário
        await docRef.set({
          'nome': user.displayName ?? '',
          'email': user.email ?? '',
          'role': 'aluno',
          'deviceId': deviceId, // 👈 salva o ID do dispositivo
          'createdAt': FieldValue.serverTimestamp(),
          'ultimo_login': FieldValue.serverTimestamp(),
        });
      } else {
        final data = docSnap.data()!;
        final savedDeviceId = data['deviceId'];

        final role = data['role'] ?? 'aluno';

// Trava apenas se o usuário for aluno
        if (role == 'aluno' && savedDeviceId != null && savedDeviceId != deviceId) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '❌ Sua conta já está conectada em outro dispositivo.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
          await _auth.signOut(); // força logout
          return;
        }

        // Atualiza último login e garante o mesmo deviceId
        await docRef.update({
          'ultimo_login': FieldValue.serverTimestamp(),
          'deviceId': deviceId,
        });
      }

      // Redireciona para a Home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao logar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login IFSP APP')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Entrar com Google'),
          onPressed: signInWithGoogle,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }
}

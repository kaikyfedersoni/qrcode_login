import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signInWithGoogle() async {
    try {
      // 🔹 Força o logout anterior para o usuário poder escolher outra conta
      await _googleSignIn.signOut();

      // 🔹 Tela de login Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 🔹 Login com Firebase Auth
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return;

      final docRef = _firestore.collection('usuarios').doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // 🆕 Novo usuário: cria documento com dados iniciais
        await docRef.set({
          'nome': user.displayName ?? '',
          'email': user.email ?? '',
          'role': 'aluno', // padrão inicial
          'createdAt': FieldValue.serverTimestamp(),
          'ultimo_login': FieldValue.serverTimestamp(), // 👈 último login
        });
      } else {
        // 👇 Usuário já existente: apenas atualiza o último login
        await docRef.update({
          'ultimo_login': FieldValue.serverTimestamp(),
        });
      }

      // 🔹 Após login e registro, vai para a Home
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

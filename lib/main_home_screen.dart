import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  /// 🔹 Detecta a role e redireciona corretamente
  Future<void> _openChamada(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snap = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    final role = snap.data()?['role'] ?? 'aluno';

    if (role == 'teacher') {
      Navigator.pushNamed(context, '/qrcode');
    } else {
      Navigator.pushNamed(context, '/scanner');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 🔹 Cor de fundo
          Container(
            color: const Color.fromRGBO(0, 40, 33, 1),
          ),

          // 🔹 Conteúdo principal
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Cabeçalho superior
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white70,
                        child: Icon(Icons.person, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              "Bem-vindo",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.lock, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 Atalhos superiores
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 25,
                    runSpacing: 20,
                    children: [
                      _buildSquareButton(
                        icon: Icons.settings,
                        label: "Configurações",
                        onTap: () => Navigator.pushNamed(context, '/configuracoes'),
                      ),
                      _buildSquareButton(
                        icon: Icons.person,
                        label: "Perfil",
                        onTap: () => Navigator.pushNamed(context, '/perfil'),
                      ),
                      _buildSquareButton(
                        icon: Icons.color_lens,
                        label: "Personalizar",
                        onTap: () => Navigator.pushNamed(context, '/personalizar'),
                      ),
                      _buildSquareButton(
                        icon: Icons.chat,
                        label: "Chats",
                        onTap: () => Navigator.pushNamed(context, '/chats'),
                      ),
                      _buildAppCard('AI', 'assets/images/app_icon.png'),
                      _buildAppCard('Carteirinha', 'assets/images/app_icon.png'),

                      /// 🔥 ESTE É O BOTÃO AJUSTADO DE CHAMADA
                      GestureDetector(
                        onTap: () => _openChamada(context),
                        child: _buildAppCard('Chamada', 'assets/images/app_icon.png'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Botões quadrados (Configurações, Perfil...)
  Widget _buildSquareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Cards dos apps (AI, Carteirinha, Chamada)
  Widget _buildAppCard(String title, String imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            width: 35,
            height: 35,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 85,
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

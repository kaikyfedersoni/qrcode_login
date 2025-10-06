import 'package:flutter/material.dart';
import '../widgets/GenerateQrForm.dart'; // Importa o widget visual

class TeacherScreen extends StatelessWidget {
  const TeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Cor de fundo da página
      appBar: AppBar(
        title: const Text("Professor - Gerar Chamada"),
        backgroundColor: Colors.green, // Cabeçalho verde
        foregroundColor: Colors.white, // Texto/ícones brancos
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: GenerateQRForm(), // Chama o widget que contém a interface
      ),
    );
  }
}

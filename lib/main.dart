import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';

import 'pages/LoginScreen.dart';
import 'pages/TeacherScreen.dart';
import 'pages/StudentScreen.dart';
import 'pages/ManageTeacherScreen.dart';
import 'pages/HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRCode Chamada',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/teacher': (context) => const TeacherScreen(),
          '/scanner': (context) => const StudentScreen(),
          '/home': (_) => const HomeScreen(),
          '/manage': (context) => const ManageTeachersScreen(),
        },
    );
  }
}

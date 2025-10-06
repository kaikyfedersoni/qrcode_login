import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';

import 'screens/LoginScreen.dart';
import 'screens/TeacherScreen.dart';
import 'screens/StudentScreen.dart';
import 'screens/ManageTeacherScreen.dart';

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
      title: 'QR Chamada',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/teacher': (context) => const TeacherScreen(),
          '/scanner': (context) => const StudentScreen(),
          '/manage': (context) => const ManageTeachersScreen(),
        },
    );
  }
}

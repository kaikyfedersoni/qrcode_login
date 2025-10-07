import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';

import 'qrcode/pages/login/views/login_screen.dart';
import 'qrcode/pages/teacher/view/teacher_screen.dart';
import 'qrcode/pages/student/view/student_screen.dart';
import 'qrcode/pages/teacher/view/manage_teacher_screen.dart';
import 'qrcode/pages/home_screen.dart';

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

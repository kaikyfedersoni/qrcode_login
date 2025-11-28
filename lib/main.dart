import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main_home_screen.dart';
import 'services/permission_request_screen.dart';
import 'qrcode/consts/app_theme.dart';
import 'services/firebase_options.dart';

import 'qrcode/pages/login/view/login_screen.dart';
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
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/qrcode': (context) => const HomeScreen(),
          '/permissions': (context) => const PermissionRequestScreen(),
          '/teacher': (context) => const TeacherScreen(),
          '/scanner': (context) => const StudentScreen(),
          '/home': (context) => const MainHomeScreen(),
          '/manage': (context) => const ManageTeachersScreen(),
        },
    );
  }
}

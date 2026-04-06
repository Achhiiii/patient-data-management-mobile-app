import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/theme/app_theme.dart';
import 'core/auth/auth_service.dart';
import 'core/database/database_helper.dart';
import 'screens/login/login_screen.dart';
import 'screens/shell/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite_common_ffi is required on Linux/Windows/macOS desktop
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  await DatabaseHelper.instance.database;
  final isLoggedIn = await AuthService.instance.isLoggedIn();
  runApp(PatientManagementApp(isLoggedIn: isLoggedIn));
}

class PatientManagementApp extends StatelessWidget {
  final bool isLoggedIn;
  const PatientManagementApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinical Precision',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: isLoggedIn ? const AppShell() : const LoginScreen(),
    );
  }
}

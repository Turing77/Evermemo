import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/theme.dart';
import 'screens/welcome_screen.dart';

class MindVaultApp extends StatelessWidget {
  const MindVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return MaterialApp(
      title: '常记',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}

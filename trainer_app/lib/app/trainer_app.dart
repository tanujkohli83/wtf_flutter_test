import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/features/auth/presentation/pages/login_page.dart';

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Trainer Dashboard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const LoginPage(),
      ),
    );
  }
}

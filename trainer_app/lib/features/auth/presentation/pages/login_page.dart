import 'package:flutter/material.dart';
import 'package:trainer_app/core/theme/app_theme.dart';
import 'package:trainer_app/features/dashboard/presentation/pages/trainer_dashboard_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _BrandMark(),
                  const SizedBox(height: 28),
                  Text('Trainer Portal', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Manage sessions, track clients, and keep the day moving.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  const _LoginCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppTheme.primaryRed,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.fitness_center_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Welcome back', style: theme.textTheme.titleLarge),
            const SizedBox(height: 18),
            TextField(
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Trainer',
                prefixIcon: Icon(Icons.person_outline_rounded),
                hintText: 'Aarav',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
                hintText: '********',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const TrainerDashboardPage(),
                ),
              ),
              icon: const Icon(Icons.login_rounded),
              label: const Text('Login as Aarav'),
            ),
          ],
        ),
      ),
    );
  }
}

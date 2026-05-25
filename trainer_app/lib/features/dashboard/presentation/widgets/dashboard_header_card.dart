import 'package:flutter/material.dart';

class DashboardHeaderCard extends StatelessWidget {
  const DashboardHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, Coach', style: textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(
              'You have 6 client check-ins today',
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Session'),
            ),
          ],
        ),
      ),
    );
  }
}

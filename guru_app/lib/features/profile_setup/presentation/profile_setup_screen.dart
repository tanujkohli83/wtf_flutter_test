import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dashboard/presentation/dashboard_screen.dart';
import '../application/profile_setup_controller.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/trainer_dropdown.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileSetupControllerProvider);
    _nameController = TextEditingController(text: profile.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    final profile = ref.read(profileSetupControllerProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile ready for ${profile.name} with ${profile.selectedTrainer}',
        ),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileSetupControllerProvider);
    final controller = ref.read(profileSetupControllerProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set up profile', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Confirm your details and choose a trainer to begin.',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 36),
                const Center(child: ProfileAvatar(initials: 'DK')),
                const SizedBox(height: 36),
                TextField(
                  controller: _nameController,
                  onChanged: controller.updateName,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'Enter your name',
                  ),
                ),
                const SizedBox(height: 20),
                TrainerDropdown(
                  trainers: ProfileSetupController.trainers,
                  selectedTrainer: profile.selectedTrainer,
                  onChanged: (trainer) {
                    if (trainer != null) {
                      controller.selectTrainer(trainer);
                    }
                  },
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: profile.canContinue ? _continue : null,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

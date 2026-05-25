import 'package:flutter/material.dart';

import '../../appointment/presentation/appointment_screen.dart';
import '../../call/presentation/guru_call_prejoin_screen.dart';
import '../../chat/presentation/chat_list_screen.dart';
import '../../profile_setup/presentation/profile_setup_screen.dart';
import '../../session_history/presentation/session_history_screen.dart';
import 'widgets/dashboard_action_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openProfileSetup(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfileSetupScreen()));
  }

  void _openChat(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChatListScreen()));
  }

  void _openScheduleCall(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AppointmentScreen()));
  }

  void _openSessionHistory(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SessionHistoryScreen()));
  }

  void _openVideoCall(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GuruCallPrejoinScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Welcome back, DK',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _openProfileSetup(context),
                  tooltip: 'Set up profile',
                  icon: const Icon(Icons.person_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Stay connected with your trainer and keep your plan moving.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            DashboardActionCard(
              title: 'Chat with Trainer',
              subtitle: 'Send a message and get quick guidance.',
              icon: Icons.chat_bubble_rounded,
              onTap: () => _openChat(context),
            ),
            const SizedBox(height: 16),
            DashboardActionCard(
              title: 'Schedule Call',
              subtitle: 'Book a check-in call at a time that works.',
              icon: Icons.video_call_rounded,
              onTap: () => _openScheduleCall(context),
            ),
            const SizedBox(height: 16),
            DashboardActionCard(
              title: 'Join Video Call',
              subtitle: 'Open the shared trainer meeting room.',
              icon: Icons.videocam_rounded,
              onTap: () => _openVideoCall(context),
            ),
            const SizedBox(height: 16),
            DashboardActionCard(
              title: 'My Sessions',
              subtitle: 'Review upcoming and completed workouts.',
              icon: Icons.event_available_rounded,
              onTap: () => _openSessionHistory(context),
            ),
          ],
        ),
      ),
    );
  }
}

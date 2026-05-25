import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trainer_app/features/chat/application/trainer_chat_controller.dart';
import 'package:trainer_app/features/chat/presentation/trainer_chat_screen.dart';
import 'package:trainer_app/features/dashboard/presentation/pages/request_management_page.dart';
import 'package:trainer_app/features/dashboard/presentation/pages/session_history_page.dart';
import 'package:trainer_app/features/dashboard/presentation/widgets/dashboard_action_tile.dart';

class TrainerDashboardPage extends ConsumerWidget {
  const TrainerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            const _DashboardHero(),
            const SizedBox(height: 18),
            _DashboardTileGrid(
              unreadCount: ref.watch(trainerUnreadCountProvider),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back, Aarav', style: textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your training day',
                        style: textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFE50914),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.08, end: 0, duration: 350.ms);
  }
}

class _DashboardTileGrid extends StatelessWidget {
  const _DashboardTileGrid({required this.unreadCount});

  final AsyncValue<int> unreadCount;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      const DashboardActionTile(
        title: 'Members',
        subtitle: '34 active clients',
        icon: Icons.groups_rounded,
      ),
      DashboardActionTile(
        title: 'Chats',
        subtitle: unreadCount.when(
          data: (count) =>
              count == 1 ? '1 unread message' : '$count unread messages',
          loading: () => 'Loading chats',
          error: (_, _) => 'Chat unavailable',
        ),
        icon: Icons.chat_bubble_rounded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TrainerChatScreen()),
        ),
      ),
      DashboardActionTile(
        title: 'Requests',
        subtitle: '5 waiting approvals',
        icon: Icons.assignment_turned_in_rounded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const RequestManagementPage(),
          ),
        ),
      ),
      DashboardActionTile(
        title: 'Sessions',
        subtitle: '12 booked today',
        icon: Icons.calendar_month_rounded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const SessionHistoryPage()),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 620 ? 4 : 2;

        return GridView.builder(
          itemCount: tiles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: columns == 4 ? 1 : 0.92,
          ),
          itemBuilder: (context, index) {
            return tiles[index]
                .animate(delay: (80 * index).ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.14, end: 0, duration: 320.ms);
          },
        );
      },
    );
  }
}

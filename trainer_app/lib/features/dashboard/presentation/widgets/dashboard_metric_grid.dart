import 'package:flutter/material.dart';
import 'package:trainer_app/features/dashboard/presentation/widgets/metric_card.dart';

class DashboardMetricGrid extends StatelessWidget {
  const DashboardMetricGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 640 ? 4 : 2;

        return GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: columns == 4 ? 1.45 : 1.12,
          children: const [
            MetricCard(
              icon: Icons.calendar_today_rounded,
              label: 'Sessions',
              value: '12',
            ),
            MetricCard(
              icon: Icons.trending_up_rounded,
              label: 'Progress',
              value: '86%',
            ),
            MetricCard(
              icon: Icons.people_alt_rounded,
              label: 'Clients',
              value: '34',
            ),
            MetricCard(
              icon: Icons.payments_rounded,
              label: 'Revenue',
              value: 'Rs 42k',
            ),
          ],
        );
      },
    );
  }
}

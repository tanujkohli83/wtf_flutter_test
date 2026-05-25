import 'package:flutter/material.dart';

class AppointmentSlotPicker extends StatelessWidget {
  const AppointmentSlotPicker({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSelected,
  });

  final List<String> slots;
  final String selectedSlot;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: slots.map((slot) {
        final isSelected = selectedSlot == slot;

        return ChoiceChip(
          label: Text(slot),
          selected: isSelected,
          onSelected: (_) => onSelected(slot),
          showCheckmark: false,
          avatar: Icon(
            Icons.schedule_rounded,
            size: 18,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }
}

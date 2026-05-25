import 'package:flutter/material.dart';

class TrainerDropdown extends StatelessWidget {
  const TrainerDropdown({
    super.key,
    required this.trainers,
    required this.selectedTrainer,
    required this.onChanged,
  });

  final List<String> trainers;
  final String selectedTrainer;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedTrainer,
      items: trainers.map((trainer) {
        return DropdownMenuItem(value: trainer, child: Text(trainer));
      }).toList(),
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      decoration: const InputDecoration(
        labelText: 'Trainer',
        hintText: 'Select a trainer',
        prefixIcon: Icon(Icons.sports_gymnastics_rounded),
      ),
    );
  }
}

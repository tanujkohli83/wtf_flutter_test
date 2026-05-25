import 'package:flutter/material.dart';

import '../../domain/training_session.dart';

class SessionSortControl extends StatelessWidget {
  const SessionSortControl({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SessionSort value;
  final ValueChanged<SessionSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<SessionSort>(
      initialValue: value,
      onChanged: (sort) {
        if (sort != null) {
          onChanged(sort);
        }
      },
      decoration: const InputDecoration(
        labelText: 'Sort sessions',
        prefixIcon: Icon(Icons.sort_rounded),
      ),
      items: const [
        DropdownMenuItem(
          value: SessionSort.newest,
          child: Text('Newest first'),
        ),
        DropdownMenuItem(
          value: SessionSort.duration,
          child: Text('Longest duration'),
        ),
        DropdownMenuItem(
          value: SessionSort.rating,
          child: Text('Highest rating'),
        ),
      ],
    );
  }
}

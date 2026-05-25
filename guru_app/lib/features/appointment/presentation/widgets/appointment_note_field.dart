import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppointmentNoteField extends StatefulWidget {
  const AppointmentNoteField({super.key, required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  State<AppointmentNoteField> createState() => _AppointmentNoteFieldState();
}

class _AppointmentNoteFieldState extends State<AppointmentNoteField> {
  static const int _maxLength = 140;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = _maxLength - _controller.text.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note for trainer', style: theme.textTheme.titleMedium),
        const SizedBox(height: 10),
        TextField(
          controller: _controller,
          maxLines: 4,
          inputFormatters: [LengthLimitingTextInputFormatter(_maxLength)],
          onChanged: (value) {
            setState(() {});
            widget.onChanged(value);
          },
          decoration: const InputDecoration(
            hintText: 'Add goals, injuries, or preferred focus areas',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$remaining characters left',
            style: theme.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}

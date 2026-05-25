import 'package:flutter/material.dart';

class SessionFeedbackResult {
  const SessionFeedbackResult({
    this.memberRating,
    this.trainerNotes = '',
    this.memberNotes = '',
  });

  final double? memberRating;
  final String trainerNotes;
  final String memberNotes;
}

class SessionFeedbackSheet extends StatefulWidget {
  const SessionFeedbackSheet({
    super.key,
    required this.isTrainerView,
    required this.otherPartyName,
  });

  final bool isTrainerView;
  final String otherPartyName;

  @override
  State<SessionFeedbackSheet> createState() => _SessionFeedbackSheetState();
}

class _SessionFeedbackSheetState extends State<SessionFeedbackSheet> {
  late final TextEditingController _trainerNotesController;
  late final TextEditingController _memberNotesController;
  double _memberRating = 5;

  @override
  void initState() {
    super.initState();
    _trainerNotesController = TextEditingController();
    _memberNotesController = TextEditingController();
  }

  @override
  void dispose() {
    _trainerNotesController.dispose();
    _memberNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session saved', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              widget.isTrainerView
                  ? 'Add notes for ${widget.otherPartyName} before closing.'
                  : 'Rate your session with ${widget.otherPartyName} and add feedback.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            if (!widget.isTrainerView) ...[
              Text('Session rating', style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (index) {
                  final selected = index < _memberRating.round();
                  return IconButton(
                    onPressed: () => setState(() => _memberRating = index + 1.0),
                    icon: Icon(
                      selected ? Icons.star_rounded : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _memberNotesController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Member notes',
                  hintText: 'How did the session feel?',
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.isTrainerView)
              TextField(
                controller: _trainerNotesController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Trainer notes',
                  hintText: 'Key takeaways and next steps.',
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const SessionFeedbackResult()),
                    child: const Text('Skip'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      SessionFeedbackResult(
                        memberRating: widget.isTrainerView ? null : _memberRating,
                        trainerNotes: _trainerNotesController.text.trim(),
                        memberNotes: _memberNotesController.text.trim(),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

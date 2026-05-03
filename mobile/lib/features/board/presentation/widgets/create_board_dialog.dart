import 'package:flutter/material.dart';

/// Simple dialog to collect a name for a new board or column.
class CreateNameDialog extends StatefulWidget {
  const CreateNameDialog({
    super.key,
    required this.title,
    required this.hint,
    required this.onConfirm,
  });

  final String title;
  final String hint;
  final void Function(String name) onConfirm;

  @override
  State<CreateNameDialog> createState() => _CreateNameDialogState();
}

class _CreateNameDialogState extends State<CreateNameDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop();
    widget.onConfirm(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(hintText: widget.hint),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }
}

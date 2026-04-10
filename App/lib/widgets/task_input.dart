/// Multi-line task text input with submit button.

import 'package:flutter/material.dart';

class TaskInput extends StatefulWidget {
  final void Function(String task) onSubmit;
  final bool enabled;

  const TaskInput({super.key, required this.onSubmit, this.enabled = true});

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Submit a Task',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: 'Describe what you want the agent to do…',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              maxLines: 4,
              minLines: 2,
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: widget.enabled && _hasText ? _submit : null,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Submit Task'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern multi-line task text input mimicking an AI chat bar.

import 'package:flutter/material.dart';
import '../theme/cli_theme.dart';

class TaskInput extends StatefulWidget {
  final void Function(String task) onSubmit;
  final bool enabled;

  const TaskInput({super.key, required this.onSubmit, this.enabled = true});

  @override
  State<TaskInput> createState() => _TaskInputState();
}

class _TaskInputState extends State<TaskInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _focusNode.addListener(() {
      setState(() {}); // Trigger rebuild for focus styling
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    final primaryColor = cli.accent;
    final isFocused = _focusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF000000), // Pure black background
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isFocused
              ? primaryColor.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.12),
          width: 1.0,
        ),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.15),
              blurRadius: 16,
              spreadRadius: 2,
            ),
        ],
      ),
      // The ClipRRect totally intercepts any child from bleeding over the outer grey border outline
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask CodeTwin..',
                  filled: true,
                  fillColor: Colors.black,
                  hintStyle: TextStyle(
                    color: const Color(0xFF8A8A8A),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  // Balance the internal text explicitly so it rests equally spaced
                  contentPadding: const EdgeInsets.fromLTRB(24, 16, 8, 16),
                  isDense: true,
                ),
                cursorColor: primaryColor,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.newline,
              ),
            ),
            // The button area
            Padding(
              // Centered visually
              padding: const EdgeInsets.only(right: 8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: _hasText ? 1.0 : 0.0),
                duration: const Duration(milliseconds: 200),
                builder: (context, val, child) {
                  return Opacity(
                    opacity: val,
                    child: Transform.scale(
                      scale: 0.8 + (0.2 * val),
                      child: IconButton(
                        onPressed: widget.enabled && _hasText ? _submit : null,
                        style: IconButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(
                            8,
                          ), // Make inner icon slightly tighter
                        ),
                        icon: const Icon(Icons.arrow_upward, size: 20),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

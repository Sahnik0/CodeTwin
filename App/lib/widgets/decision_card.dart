/// Decision card for AWAITING_APPROVAL messages.
///
/// Shows the question, optional buttons, optional free-text input,
/// and a countdown timer if timeoutMs is set.

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/log_entry.dart';

class DecisionCard extends StatefulWidget {
  final DecisionItem item;
  final void Function(String awaitingResponseId, String answer) onAnswer;
  final void Function(String awaitingResponseId) onReject;

  const DecisionCard({
    super.key,
    required this.item,
    required this.onAnswer,
    required this.onReject,
  });

  @override
  State<DecisionCard> createState() => _DecisionCardState();
}

class _DecisionCardState extends State<DecisionCard> {
  final _textController = TextEditingController();
  Timer? _countdownTimer;
  int _remainingMs = 0;

  @override
  void initState() {
    super.initState();
    if (widget.item.timeoutMs != null && widget.item.timeoutMs! > 0) {
      _remainingMs = widget.item.timeoutMs!;
      _countdownTimer = Timer.periodic(
        const Duration(seconds: 1),
        (_) {
          setState(() {
            _remainingMs -= 1000;
            if (_remainingMs <= 0) {
              _countdownTimer?.cancel();
              widget.onReject(widget.item.awaitingResponseId);
            }
          });
        },
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasOptions =
        widget.item.options != null && widget.item.options!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.help_outline,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('DECISION NEEDED',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    )),
                const Spacer(),
                if (_remainingMs > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${(_remainingMs / 1000).ceil()}s',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Question
            Text(widget.item.question, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),

            // Options or free-text
            if (hasOptions)
              ...widget.item.options!.asMap().entries.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton(
                      onPressed: () => widget.onAnswer(
                        widget.item.awaitingResponseId,
                        e.value,
                      ),
                      child: Text('${e.key + 1}. ${e.value}'),
                    ),
                  ))
            else ...[
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Type your answer…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    widget.onAnswer(widget.item.awaitingResponseId, text);
                  }
                },
                child: const Text('Send Answer'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

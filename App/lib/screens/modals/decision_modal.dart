/// Full-screen decision prompt modal (opened from notification tap).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/session_provider.dart';
import '../../providers/daemon_actions_provider.dart';
import '../../widgets/decision_card.dart';

class DecisionModal extends ConsumerWidget {
  final String awaitingResponseId;

  const DecisionModal({super.key, required this.awaitingResponseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session =
        ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;
    final actions = ref.read(daemonActionsProvider);

    final item = session.decisionQueue
        .where((d) => d.awaitingResponseId == awaitingResponseId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decision Needed'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: item == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      size: 48, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 12),
                  Text(
                    'Already resolved',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: DecisionCard(
                item: item,
                onAnswer: (id, answer) {
                  actions.answer(id, answer);
                  ref.read(sessionProvider.notifier).resolveDecision(id);
                  context.pop();
                },
                onReject: (id) {
                  actions.reject(id);
                  ref.read(sessionProvider.notifier).resolveDecision(id);
                  context.pop();
                },
              ),
            ),
    );
  }
}

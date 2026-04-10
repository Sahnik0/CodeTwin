/// Full-screen pre-flight map modal (opened from notification tap).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/session_provider.dart';
import '../../providers/daemon_actions_provider.dart';
import '../../widgets/preflight_card.dart';

class PreflightModal extends ConsumerWidget {
  final String awaitingResponseId;

  const PreflightModal({super.key, required this.awaitingResponseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session =
        ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;
    final actions = ref.read(daemonActionsProvider);

    final item = session.preflightQueue
        .where((p) => p.awaitingResponseId == awaitingResponseId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Flight Approval'),
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
              child: PreflightCard(
                item: item,
                onApprove: (id) {
                  actions.approve(id);
                  ref.read(sessionProvider.notifier).resolvePreflight(id);
                  context.pop();
                },
                onReject: (id) {
                  actions.reject(id);
                  ref.read(sessionProvider.notifier).resolvePreflight(id);
                  context.pop();
                },
                onModify: (id, text) {
                  actions.answer(id, text);
                  ref.read(sessionProvider.notifier).resolvePreflight(id);
                  context.pop();
                },
              ),
            ),
    );
  }
}

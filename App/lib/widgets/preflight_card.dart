/// Compact card displaying a PreflightMap with approve/reject/modify actions.

import 'package:flutter/material.dart';
import '../models/log_entry.dart';
import 'blast_radius_badge.dart';

class PreflightCard extends StatefulWidget {
  final PreflightItem item;
  final void Function(String awaitingResponseId) onApprove;
  final void Function(String awaitingResponseId) onReject;
  final void Function(String awaitingResponseId, String modification) onModify;

  const PreflightCard({
    super.key,
    required this.item,
    required this.onApprove,
    required this.onReject,
    required this.onModify,
  });

  @override
  State<PreflightCard> createState() => _PreflightCardState();
}

class _PreflightCardState extends State<PreflightCard> {
  bool _showModify = false;
  final _modifyController = TextEditingController();

  @override
  void dispose() {
    _modifyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final map = widget.item.map;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flight_takeoff, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PRE-FLIGHT MAP',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                BlastRadiusBadge(radius: map.estimatedBlastRadius),
              ],
            ),
          ),

          // Task description
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              map.taskDescription,
              style: theme.textTheme.titleSmall,
            ),
          ),

          // Sections
          if (map.filesToWrite.isNotEmpty)
            _buildSection(context, 'FILES TO WRITE', map.filesToWrite, Icons.edit_note),
          if (map.filesToDelete.isNotEmpty)
            _buildSection(context, 'FILES TO DELETE', map.filesToDelete, Icons.delete_outline),
          if (map.shellCommandsToRun.isNotEmpty)
            _buildSection(
                context, 'SHELL COMMANDS', map.shellCommandsToRun, Icons.terminal),
          if (map.affectedFunctions.isNotEmpty)
            _buildSection(
                context, 'AFFECTED FUNCTIONS', map.affectedFunctions, Icons.functions),

          // Reasoning
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('AGENT REASONING',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(map.reasoning, style: theme.textTheme.bodySmall),
          ),

          // Modify input (conditionally shown)
          if (_showModify) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _modifyController,
                decoration: const InputDecoration(
                  hintText: 'How would you like to change the approach?',
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: ElevatedButton(
                onPressed: () {
                  if (_modifyController.text.trim().isNotEmpty) {
                    widget.onModify(
                      widget.item.awaitingResponseId,
                      _modifyController.text.trim(),
                    );
                  }
                },
                child: const Text('Send Modification'),
              ),
            ),
          ],

          const Divider(height: 1),

          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        widget.onApprove(widget.item.awaitingResponseId),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        widget.onReject(widget.item.awaitingResponseId),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => setState(() => _showModify = !_showModify),
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Modify',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<String> items, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: theme.colorScheme.outline),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(left: 18, bottom: 2),
                child: Text(
                  item,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontFamily: 'monospace'),
                ),
              )),
        ],
      ),
    );
  }
}

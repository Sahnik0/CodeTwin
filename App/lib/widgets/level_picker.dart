/// 1–5 dependence level picker with descriptions.

import 'package:flutter/material.dart';
import '../constants/levels.dart';

class LevelPicker extends StatelessWidget {
  final int currentLevel;
  final ValueChanged<int> onChanged;

  const LevelPicker({
    super.key,
    required this.currentLevel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = getDependenceLevel(currentLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<int>(
          segments: List.generate(5, (i) {
            final level = i + 1;
            return ButtonSegment<int>(
              value: level,
              label: Text('$level'),
            );
          }),
          selected: {currentLevel},
          onSelectionChanged: (s) => onChanged(s.first),
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: theme.colorScheme.primary,
            selectedForegroundColor: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          info.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          info.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

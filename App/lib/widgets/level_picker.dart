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
    
    const double tabHeight = 44.0;
    const int totalLevels = 5;

    // Remove glow colors entirely. Use clean tasteful flat colors.
    final Color bgColor = switch(currentLevel) {
      1 => Colors.green.shade700,
      2 => Colors.teal.shade600,
      3 => Colors.blue.shade600,
      4 => Colors.orange.shade700,
      _ => Colors.red.shade700,
    };

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // Ensure it doesn't overflow!
              final maxAvailableWidth = constraints.maxWidth - 32; // 16 padding on each side
              double calcWidth = maxAvailableWidth / totalLevels;
              if (calcWidth > 56.0) calcWidth = 56.0; // limit max
              final double tabWidth = calcWidth;

              return Container(
                height: tabHeight,
                width: tabWidth * totalLevels,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C21),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      left: (currentLevel - 1) * tabWidth,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: tabWidth,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(totalLevels, (i) {
                        final level = i + 1;
                        final isSelected = currentLevel == level;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(level),
                          child: SizedBox(
                            width: tabWidth,
                            height: tabHeight,
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: isSelected ? 16 : 15,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                ),
                                child: Text('$level'),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }
          ),
          const SizedBox(height: 16),
          // Fix text overlap using custom layoutbuilder and fast transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            reverseDuration: const Duration(milliseconds: 100),
            layoutBuilder: (currentChild, previousChildren) {
              // This guarantees only one renders in stack or centers properly
              return Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Column(
              key: ValueKey<int>(currentLevel),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  info.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: bgColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

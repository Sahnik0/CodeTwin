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
    
    const double tabWidth = 56.0;
    const double tabHeight = 44.0;
    const int totalLevels = 5;

    final (Color glowColor, Color bgColor) = switch(currentLevel) {
      1 => (Colors.greenAccent, Colors.green.withValues(alpha: 0.15)),
      2 => (Colors.tealAccent, Colors.teal.withValues(alpha: 0.15)),
      3 => (Colors.blueAccent, Colors.blue.withValues(alpha: 0.15)),
      4 => (Colors.orangeAccent, Colors.orange.withValues(alpha: 0.15)),
      5 => (Colors.redAccent, Colors.red.withValues(alpha: 0.15)),
      _ => (theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.15)),
    };

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: tabHeight,
            width: tabWidth * totalLevels,
            decoration: BoxDecoration(
              color: const Color(0xFF16161A),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.fastOutSlowIn,
                  left: (currentLevel - 1) * tabWidth,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: tabWidth,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: glowColor.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: glowColor.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
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
                              fontSize: isSelected ? 18 : 15,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? glowColor : Colors.white.withValues(alpha: 0.4),
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
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.2),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Column(
              key: ValueKey<int>(currentLevel),
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  info.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: glowColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  info.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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


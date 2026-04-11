import 'package:flutter/material.dart';

/// CLI colour theme (dynamic by level)
class CliTheme extends InheritedWidget {
  final int level;

  const CliTheme({
    super.key,
    required this.level,
    required super.child,
  });

  static CliTheme of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CliTheme>()!;

  @override
  bool updateShouldNotify(CliTheme old) => level != old.level;

  Color get bg => switch (level) {
        1 => const Color(0xFF070D07),
        2 => const Color(0xFF070D0D),
        3 => const Color(0xFF070A0D),
        4 => const Color(0xFF0D0A07),
        _ => const Color(0xFF0D0707),
      };
  Color get surface => switch (level) {
        1 => const Color(0xFF0D1A0D),
        2 => const Color(0xFF0D1A1A),
        3 => const Color(0xFF0D131A),
        4 => const Color(0xFF1A130D),
        _ => const Color(0xFF1A0D0D),
      };
  Color get accent => switch (level) {
        1 => Colors.green.shade500,
        2 => Colors.teal.shade400,
        3 => Colors.blue.shade400,
        4 => Colors.orange.shade500,
        _ => Colors.red.shade500,
      };
  Color get accentDim => switch (level) {
        1 => Colors.green.shade700,
        2 => Colors.teal.shade600,
        3 => Colors.blue.shade600,
        4 => Colors.orange.shade700,
        _ => Colors.red.shade700,
      };
  Color get accentMuted => switch (level) {
        1 => const Color(0xFF1A3D1A),
        2 => const Color(0xFF133D3D), // Teal hue
        3 => const Color(0xFF1A2B3D),
        4 => const Color(0xFF3D2B1A),
        _ => const Color(0xFF3D1A1A),
      };

  Color get cyan => Colors.teal.shade400;
  Color get amber => Colors.orange.shade500;
  Color get red => Colors.red.shade500;
  final Color redMuted = const Color(0xFF3D0A0A);
  Color get text => switch (level) {
        1 => const Color(0xFFCCFFCC), // Green tint
        2 => const Color(0xFFCCFFFF), // Cyan tint
        3 => const Color(0xFFCCCCFF), // Blue tint
        4 => const Color(0xFFFFE5CC), // Orange tint
        _ => const Color(0xFFFFCCCC), // Red tint (Level 5)
      };

  Color get textDim => switch (level) {
        1 => const Color(0xFF557755),
        2 => const Color(0xFF557777),
        3 => const Color(0xFF555577),
        4 => const Color(0xFF776655),
        _ => const Color(0xFF775555),
      };

  Color get border => switch (level) {
        1 => const Color(0xFF1F3D1F),
        2 => const Color(0xFF1F3D3D),
        3 => const Color(0xFF1F1F3D),
        4 => const Color(0xFF3D2E1F),
        _ => const Color(0xFF3D1F1F),
      };

  Color get borderBright => switch (level) {
        1 => Colors.green.shade500,
        2 => Colors.teal.shade400,
        3 => Colors.blue.shade400,
        4 => Colors.orange.shade500,
        _ => Colors.red.shade500,
      };

  final TextStyle mono = const TextStyle(fontFamily: 'monospace');

  BoxDecoration box({Color? borderColor, Color? bgColor, double radius = 4}) =>
      BoxDecoration(
        color: bgColor ?? surface,
        border: Border.all(color: borderColor ?? border, width: 1),
        borderRadius: BorderRadius.circular(radius),
      );
}

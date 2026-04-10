/// Blast radius severity badge: low (green), medium (amber), high (red).

import 'package:flutter/material.dart';
import '../models/preflight_map.dart';

class BlastRadiusBadge extends StatelessWidget {
  final BlastRadius radius;

  const BlastRadiusBadge({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (radius) {
      BlastRadius.low => (Colors.green, 'LOW'),
      BlastRadius.medium => (Colors.amber, 'MEDIUM'),
      BlastRadius.high => (Colors.red, 'HIGH'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

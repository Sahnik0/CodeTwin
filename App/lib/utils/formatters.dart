/// Formatting helpers for durations, timestamps, and file paths.

import 'package:intl/intl.dart';

/// Format milliseconds into a human-readable duration, e.g. "2m 13s".
String formatDurationMs(int ms) {
  final duration = Duration(milliseconds: ms);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
  if (minutes > 0) return '${minutes}m ${seconds}s';
  return '${seconds}s';
}

/// Parse an ISO 8601 timestamp and return a short local time string.
String formatTimestamp(String iso8601) {
  try {
    final dt = DateTime.parse(iso8601).toLocal();
    return DateFormat.Hms().format(dt);
  } catch (_) {
    return iso8601;
  }
}

/// Parse an ISO 8601 timestamp and return a full local date-time string.
String formatTimestampFull(String iso8601) {
  try {
    final dt = DateTime.parse(iso8601).toLocal();
    return DateFormat.yMMMd().add_Hms().format(dt);
  } catch (_) {
    return iso8601;
  }
}

/// Extract just the file name from a full path.
String fileBasename(String path) {
  final sep = path.contains('\\') ? '\\' : '/';
  final parts = path.split(sep);
  return parts.isNotEmpty ? parts.last : path;
}

/// Truncate a string to [maxLen] characters, appending '…' if truncated.
String truncate(String text, int maxLen) {
  if (text.length <= maxLen) return text;
  return '${text.substring(0, maxLen)}…';
}

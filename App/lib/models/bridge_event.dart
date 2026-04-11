/// Standard models for traversing the WebSocket bridge to CodeTwin's server.ts.
/// 
/// This mimics the `BridgeEvent` payload from the server.

enum BridgeEventType {
  ready,
  start,
  stdout,
  stderr,
  cliEvent,
  input,
  terminate,
  exit,
  error,
  subscribed,
  accepted,
  pong,
  unknown,
}

BridgeEventType _parseBridgeType(String type) {
  switch (type) {
    case 'cli_event':
      return BridgeEventType.cliEvent;
    case 'pong':
      return BridgeEventType.pong;
    default:
      break;
  }

  for (final value in BridgeEventType.values) {
    if (value.name == type) return value;
  }
  return BridgeEventType.unknown;
}

class BridgeEvent {
  final BridgeEventType type;
  final String? jobId;
  final int ts;
  final Map<String, dynamic> raw;

  BridgeEvent({
    required this.type,
    this.jobId,
    required this.ts,
    required this.raw,
  });

  factory BridgeEvent.fromJson(Map<String, dynamic> json) {
    return BridgeEvent(
      type: _parseBridgeType(json['type'] as String? ?? ''),
      jobId: json['jobId'] as String?,
      ts: json['ts'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      raw: json,
    );
  }

  /// Extracts textual payload for stdout/stderr events
  String? get text => raw['text'] as String?;

  /// Extracts exit code for exit events
  int? get exitCode => raw['code'] as int?;

  /// Extracts error message for error events
  String? get message => raw['message'] as String?;

  /// Extracts structured CLI event payload for cli_event events.
  Map<String, dynamic>? get cliEvent {
    final value = raw['event'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return null;
  }
}

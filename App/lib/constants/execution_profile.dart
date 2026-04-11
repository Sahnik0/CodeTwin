/// Runtime execution profile selected from dependence level.
///
/// These flags are sent with cliExecute so mobile and broker stay in sync
/// with structured TUI-parity event streaming.
class ExecutionProfile {
  final String streamFormat;
  final bool thinking;
  final bool interactive;

  const ExecutionProfile({
    required this.streamFormat,
    required this.thinking,
    required this.interactive,
  });
}

const _levelExecutionProfiles = <int, ExecutionProfile>{
  1: ExecutionProfile(streamFormat: 'json', thinking: true, interactive: false),
  2: ExecutionProfile(streamFormat: 'json', thinking: true, interactive: false),
  3: ExecutionProfile(streamFormat: 'json', thinking: true, interactive: false),
  4: ExecutionProfile(streamFormat: 'json', thinking: false, interactive: false),
  5: ExecutionProfile(streamFormat: 'json', thinking: false, interactive: false),
};

ExecutionProfile executionProfileForLevel(int level) {
  final normalized = level.clamp(1, 5);
  return _levelExecutionProfiles[normalized] ?? _levelExecutionProfiles[3]!;
}

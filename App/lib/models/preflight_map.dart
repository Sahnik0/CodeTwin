/// Pre-flight impact map — must match CLI `PreflightMap` shape exactly.

enum BlastRadius { low, medium, high }

class PreflightMap {
  final String taskDescription;
  final List<String> filesToRead;
  final List<String> filesToWrite;
  final List<String> filesToDelete;
  final List<String> shellCommandsToRun;
  final BlastRadius estimatedBlastRadius;
  final List<String> affectedFunctions;
  final List<String> affectedModules;
  final String reasoning;

  const PreflightMap({
    required this.taskDescription,
    required this.filesToRead,
    required this.filesToWrite,
    required this.filesToDelete,
    required this.shellCommandsToRun,
    required this.estimatedBlastRadius,
    required this.affectedFunctions,
    required this.affectedModules,
    required this.reasoning,
  });
}

class PreflightMapPayload {
  final PreflightMap map;
  final String awaitingResponseId;

  const PreflightMapPayload({
    required this.map,
    required this.awaitingResponseId,
  });
}

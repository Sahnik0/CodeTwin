/// Dependence level names and descriptions (1–5).

class DependenceLevel {
  final int level;
  final String name;
  final String description;

  const DependenceLevel({
    required this.level,
    required this.name,
    required this.description,
  });
}

const dependenceLevels = <DependenceLevel>[
  DependenceLevel(
    level: 1,
    name: 'Ask everything',
    description: 'Agent asks for your approval on every single action.',
  ),
  DependenceLevel(
    level: 2,
    name: 'Ask on writes',
    description: 'Agent acts independently on reads, asks before any write.',
  ),
  DependenceLevel(
    level: 3,
    name: 'Ask on ambiguity',
    description: 'Agent proceeds on clear tasks, asks when uncertain.',
  ),
  DependenceLevel(
    level: 4,
    name: 'Ask on destructive',
    description: 'Agent works freely, only asks before destructive operations.',
  ),
  DependenceLevel(
    level: 5,
    name: 'Full delegate',
    description: 'Agent has full autonomy — no interruptions.',
  ),
];

/// Get level info by number (1–5). Returns level 3 as fallback.
DependenceLevel getDependenceLevel(int level) {
  if (level < 1 || level > 5) return dependenceLevels[2];
  return dependenceLevels[level - 1];
}

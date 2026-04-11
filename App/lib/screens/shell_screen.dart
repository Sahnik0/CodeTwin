import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import '../models/session_status.dart';
import '../providers/daemon_actions_provider.dart';
import '../widgets/session_status_badge.dart';
import '../widgets/daemon_status_bar.dart';
import '../theme/cli_theme.dart';
import '../services/bridge_listener_service.dart';

class SwipeableShellContainer extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  const SwipeableShellContainer({
    super.key,
    required this.navigationShell,
    required this.children,
  });

  @override
  State<SwipeableShellContainer> createState() => _SwipeableShellContainerState();
}

class _SwipeableShellContainerState extends State<SwipeableShellContainer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.navigationShell.currentIndex);
  }

  @override
  void didUpdateWidget(covariant SwipeableShellContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell.currentIndex != _pageController.page?.round()) {
      _pageController.animateToPage(
        widget.navigationShell.currentIndex,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      onPageChanged: (index) {
        widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        );
      },
      children: widget.children,
    );
  }
}

class ShellScreen extends ConsumerWidget {
  final StatefulNavigationShell shell;

  const ShellScreen({super.key, required this.shell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionProvider);
    final session = sessionAsync.valueOrNull;
    final int badgeCount = session == null
        ? 0
        : session.preflightQueue.length + session.decisionQueue.length;

    // Activate bridge event → provider wiring (pure provider, no widget wrap)
    ref.watch(bridgeListenerProvider);

    return CliTheme(
        level: session?.dependenceLevel ?? 1,
        child: Builder(builder: (context) {
          final cli = CliTheme.of(context);
          return Scaffold(
            backgroundColor: cli.bg,
            body: Stack(
              children: [
                // 1. Main Content: Ignore the top safe area (bleed into status bar)
                Positioned.fill(child: shell),

                // 2. Floating Overlays: Respect the safe area (top status hub)
                SafeArea(
                  child: Stack(
                    children: [
                      // Floating Status Bar (Dashboard only)
                      if (shell.currentIndex == 0 && session != null)
                        Positioned(
                          top: 4,
                          left: 16,
                          right: 16,
                          child: _FloatingStatusBar(session: session),
                        ),

                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: const DaemonStatusBar(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: RepaintBoundary(
              child: Container(
                decoration: BoxDecoration(
                  color: cli.bg,
                  border: Border(top: BorderSide(color: cli.border, width: 1)),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _CliNavItem(
                          label: 'DASHBOARD',
                          icon: Icons.terminal,
                          isSelected: shell.currentIndex == 0,
                          onTap: () => _onTap(context, 0),
                        ),
                        _CliNavItem(
                          label: 'LOGS',
                          icon: Icons.list_alt_outlined,
                          isSelected: shell.currentIndex == 1,
                          badgeCount: badgeCount,
                          onTap: () => _onTap(context, 1),
                        ),
                        _CliNavItem(
                          label: 'HISTORY',
                          icon: Icons.history_outlined,
                          isSelected: shell.currentIndex == 2,
                          onTap: () => _onTap(context, 2),
                        ),
                        _CliNavItem(
                          label: 'SETTINGS',
                          icon: Icons.settings_outlined,
                          isSelected: shell.currentIndex == 3,
                          onTap: () => _onTap(context, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
    );
  }

  void _onTap(BuildContext context, int index) {
    shell.goBranch(index, initialLocation: index == shell.currentIndex);
  }
}

// ── Floating Status Bar ──────────────────────────────────────────────────────
class _FloatingStatusBar extends ConsumerWidget {
  final SessionState session;
  const _FloatingStatusBar({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cli = CliTheme.of(context);
    final isRunning = session.status == SessionStatus.running;
    final actions = ref.read(daemonActionsProvider);

    return Row(
      children: [
        // Status Badge
        SessionStatusBadge(status: session.status, currentTask: session.currentTask),
        const Spacer(),
        if (isRunning) ...[
          _BlinkingCursor(color: cli.accent),
        ],
      ],
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color? color;
  const _BlinkingCursor({super.key, this.color});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor> {
  bool _visible = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 530), (_) {
      if (mounted) setState(() => _visible = !_visible);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 80),
      child: Text('█',
          style: cli.mono.copyWith(
              color: widget.color ?? cli.accent, fontSize: 14)),
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────────────────
class _CliNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int badgeCount;

  const _CliNavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  State<_CliNavItem> createState() => _CliNavItemState();
}

class _CliNavItemState extends State<_CliNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _underlineWidth;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: widget.isSelected ? 1.0 : 0.0,
    );

    _scale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    _underlineWidth = Tween<double>(begin: 0, end: 20).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(covariant _CliNavItem old) {
    super.didUpdateWidget(old);
    if (widget.isSelected != old.isSelected) {
      widget.isSelected ? _ctrl.forward() : _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String get _activeLabel => '[ ${widget.label} ]';
  String get _inactiveLabel => widget.label;

  @override
  Widget build(BuildContext context) {
    final cli = CliTheme.of(context);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: _scale,
                    child: _AnimatedIconColor(
                      animation: _ctrl,
                      icon: widget.icon,
                      fromColor: cli.textDim,
                      toColor: cli.accent,
                    ),
                  ),
                  if (widget.badgeCount > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: _Badge(count: widget.badgeCount, color: cli.accent, bg: cli.bg),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              _AnimatedLabel(
                animation: _ctrl,
                activeLabel: _activeLabel,
                inactiveLabel: _inactiveLabel,
                fromColor: cli.textDim,
                toColor: cli.accent,
                mono: cli.mono,
              ),
              const SizedBox(height: 3),
              AnimatedBuilder(
                animation: _underlineWidth,
                builder: (_, __) => SizedBox(
                  width: _underlineWidth.value,
                  height: 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: cli.accent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedIconColor extends AnimatedWidget {
  final IconData icon;
  final Color fromColor;
  final Color toColor;

  const _AnimatedIconColor({
    required Animation<double> animation,
    required this.icon,
    required this.fromColor,
    required this.toColor,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    return Icon(
      icon,
      color: Color.lerp(fromColor, toColor, t),
      size: 24,
    );
  }
}

class _AnimatedLabel extends AnimatedWidget {
  final String activeLabel;
  final String inactiveLabel;
  final Color fromColor;
  final Color toColor;
  final TextStyle mono;

  const _AnimatedLabel({
    required Animation<double> animation,
    required this.activeLabel,
    required this.inactiveLabel,
    required this.fromColor,
    required this.toColor,
    required this.mono,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final color = Color.lerp(fromColor, toColor, t)!;
    final isActive = t > 0.5;

    return Text(
      isActive ? activeLabel : inactiveLabel,
      style: mono.copyWith(
        color: color,
        fontSize: 9,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  final Color color;
  final Color bg;

  const _Badge({required this.count, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
      child: Text(
        '$count',
        style: TextStyle(
          color: bg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
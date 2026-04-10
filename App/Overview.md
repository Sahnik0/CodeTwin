# BUILD PROMPT — CodeTwin Mobile App
> Feed this entire document as context at the start of every session.
> The CLI daemon (CodeTwin CLI) is a separate codebase built from its own prompt.
> This app is a REMOTE CONTROL for the CLI — it does NOT run the agent itself.
> All AI execution happens on the developer's machine via the daemon.

---

## WHAT YOU ARE BUILDING

The CodeTwin mobile app is a Flutter application that lets developers
monitor and control their CodeTwin CLI agent from a phone.

### Core responsibility (never violate this)
- The app ONLY communicates with the daemon — it never calls LLMs directly
- The app is an operator interface, not an agent itself
- All state of truth lives on the daemon — the app is a thin client

### What the app does
- Pair with a running CodeTwin daemon via QR code
- Submit tasks to the daemon remotely
- Receive live agent logs as they stream
- View and respond to pre-flight impact maps (approve / reject / modify)
- Answer decision questions the agent poses
- Change the dependence level mid-task
- Browse session history and decision records
- Receive push notifications when agent needs approval

### What it does NOT do
- Run any agent logic locally
- Access the filesystem
- Call any LLM API
- Store twin memory — it reads it from the daemon

---

## TECH STACK

| Layer | Technology |
|---|---|
| Framework | Flutter SDK (Dart) — stable channel |
| Navigation | `go_router` (declarative, URL-based routing) |
| State | `flutter_riverpod` |
| Real-time | `socket_io_client` |
| Push Notifications | `firebase_messaging` + `flutter_local_notifications` |
| QR Code | `mobile_scanner` for scan; `qr_flutter` for display |
| Storage | `flutter_secure_storage` (API key / pairing info), `path_provider` + `dart:io` (logs cache) |
| Styling | Flutter Material 3 with custom `ThemeData` |
| Forms | `reactive_forms` + manual Dart validation (typed model classes) |

---

## SHARED CONTRACT — READ THIS FIRST

The mobile app and CLI daemon share an exact message protocol.
Never invent new message types — use only what is defined here.
This contract is the source of truth for all WebSocket communication.

### Message types

```dart
enum MessageType {
  taskSubmit,         // app → daemon: submit a new task
  taskCancel,         // app → daemon: cancel running task
  preflightMap,       // daemon → app: show impact map for approval
  awaitingApproval,   // daemon → app: paused, user action needed
  userApprove,        // app → daemon: user approved preflight
  userReject,         // app → daemon: user rejected preflight
  userAnswer,         // app → daemon: answer to a decision question
  agentLog,           // daemon → app: streaming log line
  taskComplete,       // daemon → app: task finished
  taskFailed,         // daemon → app: task failed
  sessionStatus,      // daemon → app: session state snapshot
  decisionQueued,     // daemon → app: queued decision (delegation mode)
  twinUpdate,         // daemon → app: twin profile updated
  daemonOnline,       // daemon → app: daemon connected to relay
  daemonOffline,      // relay → app: daemon disconnected
  levelChange,        // app → daemon: change dependence level
  ping,               // either direction: keepalive
  pong,               // either direction: keepalive reply
}

// Wire-format string mapping (matches CLI exactly)
const messageTypeWireNames = {
  MessageType.taskSubmit:       'TASK_SUBMIT',
  MessageType.taskCancel:       'TASK_CANCEL',
  MessageType.preflightMap:     'PREFLIGHT_MAP',
  MessageType.awaitingApproval: 'AWAITING_APPROVAL',
  MessageType.userApprove:      'USER_APPROVE',
  MessageType.userReject:       'USER_REJECT',
  MessageType.userAnswer:       'USER_ANSWER',
  MessageType.agentLog:         'AGENT_LOG',
  MessageType.taskComplete:     'TASK_COMPLETE',
  MessageType.taskFailed:       'TASK_FAILED',
  MessageType.sessionStatus:    'SESSION_STATUS',
  MessageType.decisionQueued:   'DECISION_QUEUED',
  MessageType.twinUpdate:       'TWIN_UPDATE',
  MessageType.daemonOnline:     'DAEMON_ONLINE',
  MessageType.daemonOffline:    'DAEMON_OFFLINE',
  MessageType.levelChange:      'LEVEL_CHANGE',
  MessageType.ping:             'PING',
  MessageType.pong:             'PONG',
};
```

### AgentMessage envelope

Every WebSocket message, in both directions, is wrapped in this envelope:

```dart
class AgentMessage {
  final MessageType type;
  final String sessionId;
  final String projectId;
  final String deviceId;       // shared pairing ID — same on daemon and app
  final String timestamp;      // ISO 8601
  final Map<String, dynamic> payload; // typed payload per MessageType, validated per-type

  const AgentMessage({
    required this.type,
    required this.sessionId,
    required this.projectId,
    required this.deviceId,
    required this.timestamp,
    required this.payload,
  });

  factory AgentMessage.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

### Typed payload models the app must handle

```dart
// Received from daemon
class PreflightMapPayload {
  final PreflightMap map;
  final String awaitingResponseId; // echo this back in USER_APPROVE / USER_REJECT

  factory PreflightMapPayload.fromJson(Map<String, dynamic> json) { ... }
}

class AwaitingApprovalPayload {
  final String question;
  final List<String>? options;
  final String awaitingResponseId;
  final int? timeoutMs;

  factory AwaitingApprovalPayload.fromJson(Map<String, dynamic> json) { ... }
}

class AgentLogPayload {
  final AgentLogLevel level; // info | warn | error | tool
  final String message;
  final String? toolName;

  factory AgentLogPayload.fromJson(Map<String, dynamic> json) { ... }
}

class TaskCompletePayload {
  final String summary;
  final int decisionsRecorded;
  final List<String> filesChanged;
  final int durationMs;

  factory TaskCompletePayload.fromJson(Map<String, dynamic> json) { ... }
}

class TaskFailedPayload {
  final String error;
  final String partialCompletionSummary;
  final List<String> filesChanged;

  factory TaskFailedPayload.fromJson(Map<String, dynamic> json) { ... }
}

class SessionStatusPayload {
  final SessionStatus status; // idle | running | awaiting_approval | paused | failed
  final String? currentTask;
  final int dependenceLevel;   // 1–5
  final bool remoteConnected;

  factory SessionStatusPayload.fromJson(Map<String, dynamic> json) { ... }
}

// Sent from app
class TaskSubmitPayload {
  final String task;
  final int? dependenceLevel;

  Map<String, dynamic> toJson() { ... }
}

class UserAnswerPayload {
  final String awaitingResponseId;
  final String answer;

  Map<String, dynamic> toJson() { ... }
}

class LevelChangePayload {
  final int newLevel;

  Map<String, dynamic> toJson() { ... }
}

// PreflightMap shape (must match CLI exactly)
class PreflightMap {
  final String taskDescription;
  final List<String> filesToRead;
  final List<String> filesToWrite;
  final List<String> filesToDelete;
  final List<String> shellCommandsToRun;
  final BlastRadius estimatedBlastRadius; // low | medium | high
  final List<String> affectedFunctions;
  final List<String> affectedModules;
  final String reasoning;

  factory PreflightMap.fromJson(Map<String, dynamic> json) { ... }
}
```

### Socket.io events (signaling server protocol)

The app communicates with the daemon via a shared signaling relay server.

```dart
// App emits on connect:
socket.emit('register', { 'deviceId': deviceId, 'type': 'client' });

// App emits to send message to daemon:
socket.emit('message', agentMessage.toJson());

// App listens for message from daemon:
socket.on('message', (data) { /* parse as AgentMessage */ });

// App listens for daemon presence:
socket.on('paired',              (_) { /* daemon is connected with same deviceId */ });
socket.on('no_pair',             (_) { /* daemon not connected */ });
socket.on('client_disconnected', (_) { /* not used by client side */ });

// Keepalive:
Timer.periodic(const Duration(seconds: 25), (_) => socket.emit('ping'));
socket.on('pong', (_) { /* reset reconnect timer */ });
```

The `deviceId` is shown in the CLI via `CodeTwin connect` as a QR code.
The user scans it with the app to pair. Store the deviceId in `flutter_secure_storage`.

---

## PROJECT STRUCTURE

```
CodeTwin-app/
├── lib/
│   ├── main.dart                        # App entry point, ProviderScope
│   ├── app.dart                         # MaterialApp.router + theme setup
│   ├── router.dart                      # go_router configuration
│   ├── screens/
│   │   ├── pair_screen.dart             # Pairing screen (QR scan + manual entry)
│   │   ├── shell_screen.dart            # Root scaffold with bottom nav bar
│   │   ├── dashboard_screen.dart        # Active session + quick task input
│   │   ├── logs_screen.dart             # Streaming agent log viewer
│   │   ├── history_screen.dart          # Session history + decision log
│   │   ├── settings_screen.dart         # Pairing info, level, notifications
│   │   └── modals/
│   │       ├── preflight_modal.dart     # Full-screen pre-flight map
│   │       └── decision_modal.dart      # Full-screen decision prompt
│   ├── widgets/
│   │   ├── preflight_card.dart          # Pre-flight map display
│   │   ├── decision_card.dart           # Awaiting approval card
│   │   ├── agent_log_list.dart          # Scrollable log stream
│   │   ├── session_status_badge.dart    # idle / running / awaiting / failed
│   │   ├── blast_radius_badge.dart      # low (green) / medium (amber) / high (red)
│   │   ├── task_input.dart              # Multi-line task text input + submit
│   │   ├── daemon_status_bar.dart       # Connection state banner
│   │   └── level_picker.dart            # 1–5 stepper with descriptions
│   ├── providers/
│   │   ├── session_provider.dart        # Riverpod: session state, logs, preflight queue
│   │   ├── connection_provider.dart     # Riverpod: daemon connection state, deviceId
│   │   └── notifications_provider.dart # Riverpod: push notification permissions + queue
│   ├── services/
│   │   ├── socket_service.dart          # socket_io_client — single instance
│   │   ├── message_service.dart         # Parses/dispatches inbound AgentMessages
│   │   └── notifications_service.dart  # Push notification registration + sending
│   ├── hooks/
│   │   ├── use_daemon.dart              # Sends messages to daemon
│   │   ├── use_session_stream.dart      # Subscribes to log stream
│   │   └── use_preflight.dart           # Preflight queue management
│   ├── utils/
│   │   ├── validators.dart              # Dart model validators matching shared contract
│   │   ├── formatters.dart              # Duration, timestamp, file path helpers
│   │   └── device_id.dart               # Read/write deviceId from flutter_secure_storage
│   ├── models/
│   │   ├── agent_message.dart
│   │   ├── preflight_map.dart
│   │   ├── session_status.dart
│   │   └── log_entry.dart
│   └── constants/
│       └── levels.dart                  # Dependence level names and descriptions
├── android/
├── ios/
├── pubspec.yaml
└── analysis_options.yaml
```

---

## STEP 1 — Model Validators (utils/validators.dart)

These Dart model classes mirror the CLI's `src/shared/messages.ts` exactly.
Every `fromJson` must throw a `ValidationException` on invalid data — never silently accept malformed messages.

```dart
// utils/validators.dart
import '../models/agent_message.dart';

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);
}

/// Parse and validate an inbound raw JSON map into a typed AgentMessage.
/// Throws [ValidationException] if any required field is missing or has wrong type.
AgentMessage parseAgentMessage(Map<String, dynamic> json) {
  final typeStr = json['type'] as String?;
  if (typeStr == null) throw const ValidationException('Missing field: type');

  final type = messageTypeFromWire(typeStr);
  if (type == null) throw ValidationException('Unknown MessageType: $typeStr');

  final sessionId  = _requireString(json, 'sessionId');
  final projectId  = _requireString(json, 'projectId');
  final deviceId   = _requireString(json, 'deviceId');
  final timestamp  = _requireString(json, 'timestamp');
  final payload    = json['payload'] as Map<String, dynamic>? ?? {};

  return AgentMessage(
    type: type,
    sessionId: sessionId,
    projectId: projectId,
    deviceId: deviceId,
    timestamp: timestamp,
    payload: payload,
  );
}

PreflightMapPayload parsePreflightMapPayload(Map<String, dynamic> json) {
  final map = json['map'] as Map<String, dynamic>?;
  if (map == null) throw const ValidationException('Missing field: map');
  return PreflightMapPayload(
    map: parsePreflightMap(map),
    awaitingResponseId: _requireString(json, 'awaitingResponseId'),
  );
}

PreflightMap parsePreflightMap(Map<String, dynamic> json) {
  return PreflightMap(
    taskDescription:      _requireString(json, 'taskDescription'),
    filesToRead:          _requireStringList(json, 'filesToRead'),
    filesToWrite:         _requireStringList(json, 'filesToWrite'),
    filesToDelete:        _requireStringList(json, 'filesToDelete'),
    shellCommandsToRun:   _requireStringList(json, 'shellCommandsToRun'),
    estimatedBlastRadius: _requireEnum(json, 'estimatedBlastRadius', BlastRadius.values),
    affectedFunctions:    _requireStringList(json, 'affectedFunctions'),
    affectedModules:      _requireStringList(json, 'affectedModules'),
    reasoning:            _requireString(json, 'reasoning'),
  );
}

AwaitingApprovalPayload parseAwaitingApprovalPayload(Map<String, dynamic> json) {
  return AwaitingApprovalPayload(
    question:             _requireString(json, 'question'),
    options:              (json['options'] as List?)?.cast<String>(),
    awaitingResponseId:   _requireString(json, 'awaitingResponseId'),
    timeoutMs:            json['timeoutMs'] as int?,
  );
}

AgentLogPayload parseAgentLogPayload(Map<String, dynamic> json) {
  return AgentLogPayload(
    level:    _requireEnum(json, 'level', AgentLogLevel.values),
    message:  _requireString(json, 'message'),
    toolName: json['toolName'] as String?,
  );
}

SessionStatusPayload parseSessionStatusPayload(Map<String, dynamic> json) {
  final level = json['dependenceLevel'] as int?;
  if (level == null || level < 1 || level > 5) {
    throw const ValidationException('dependenceLevel must be int 1–5');
  }
  return SessionStatusPayload(
    status:           _requireEnum(json, 'status', SessionStatus.values),
    currentTask:      json['currentTask'] as String?,
    dependenceLevel:  level,
    remoteConnected:  json['remoteConnected'] as bool? ?? false,
  );
}

// ── helpers ──────────────────────────────────────────────────────────────────

String _requireString(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is! String) throw ValidationException('Missing or invalid field: $key');
  return v;
}

List<String> _requireStringList(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is! List) throw ValidationException('Missing or invalid list: $key');
  return v.cast<String>();
}

T _requireEnum<T extends Enum>(
  Map<String, dynamic> json,
  String key,
  List<T> values,
) {
  final str = _requireString(json, key);
  return values.firstWhere(
    (e) => e.name == _snakeToCamel(str),
    orElse: () => throw ValidationException('Invalid enum value "$str" for $key'),
  );
}
```

---

## STEP 2 — Socket Service (services/socket_service.dart)

Singleton `socket_io_client` instance. The rest of the app never creates sockets directly.

```dart
// services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/agent_message.dart';
import '../utils/validators.dart';

typedef MessageHandler = void Function(AgentMessage msg);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  String _deviceId = '';
  final Map<MessageType, List<MessageHandler>> _handlers = {};
  Timer? _pingTimer;

  void connect(String signalingUrl, String deviceId) { ... }
  void disconnect() { ... }
  void send(AgentMessage msg) { ... }

  /// Returns an unsubscribe function.
  VoidCallback on(MessageType type, MessageHandler handler) { ... }

  bool get isConnected => _socket?.connected ?? false;
  String get deviceId => _deviceId;
}
```

Connection lifecycle:
1. `connect()` calls `IO.io(signalingUrl, OptionBuilder().setTransports(['websocket']).build())`
2. On `connect`: emit `register` with `{ 'deviceId': deviceId, 'type': 'client' }`
3. On `message`: call `parseAgentMessage()` — on `ValidationException`, log in debug, silently discard in release
4. On `paired`: update `connectionProvider` with `daemonConnected: true`
5. On `no_pair`: update provider with `daemonConnected: false`, show "Daemon not online" banner
6. On `disconnect`: update provider, start reconnect with exponential backoff
   (1s → 2s → 4s → 8s → max 60s) using `Future.delayed`
7. Keepalive: emit `ping` every 25s via `Timer.periodic` — cancel on disconnect
8. On reconnect: re-emit `register` automatically

Validate every inbound message. If invalid: `debugPrint` in debug mode,
silently discard in release. Never throw unhandled exceptions on bad messages.

---

## STEP 3 — Message Service (services/message_service.dart)

Dispatches validated inbound messages to the correct provider notifier.

```dart
// services/message_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/agent_message.dart';
import '../providers/session_provider.dart';
import '../providers/connection_provider.dart';
import '../services/notifications_service.dart';
import '../utils/validators.dart';

class MessageService {
  final Ref ref;
  const MessageService(this.ref);

  void handleInboundMessage(AgentMessage msg) {
    switch (msg.type) {
      case MessageType.agentLog:
        // parse AgentLogPayload, append to session log
      case MessageType.preflightMap:
        // parse PreflightMapPayload, push to preflight queue + send push notification
      case MessageType.awaitingApproval:
        // parse AwaitingApprovalPayload, push to decision queue + send push notification
      case MessageType.taskComplete:
        // parse TaskCompletePayload, update session status, move logs to history
      case MessageType.taskFailed:
        // parse TaskFailedPayload, update session status with error
      case MessageType.sessionStatus:
        // parse SessionStatusPayload, sync full session state snapshot
      case MessageType.decisionQueued:
        // show queued decisions badge
      case MessageType.twinUpdate:
        // show "twin updated" SnackBar
      case MessageType.daemonOnline:
        // update connection provider
      case MessageType.daemonOffline:
        // update connection provider, show banner
      case MessageType.pong:
        // reset keepalive timer
      default:
        break;
    }
  }
}
```

Push notification triggers:
- `PREFLIGHT_MAP` → "CodeTwin needs your approval before proceeding"
- `AWAITING_APPROVAL` → "CodeTwin is asking: {question truncated to 60 chars}"
- `TASK_COMPLETE` → "Task complete: {summary truncated to 80 chars}"
- `TASK_FAILED` → "Task failed — tap to see details"

Only send push notifications when app is backgrounded.
When app is foregrounded, show in-app `SnackBar` banners instead.
Use `AppLifecycleListener` or `WidgetsBindingObserver` to detect foreground/background state.

---

## STEP 4 — Riverpod Providers

### session_provider.dart

```dart
// models/session_models.dart
class LogEntry {
  final String id;
  final AgentLogLevel level; // info | warn | error | tool
  final String message;
  final String? toolName;
  final String timestamp;
}

class PreflightItem {
  final String awaitingResponseId;
  final PreflightMap map;
  final String receivedAt;
}

class DecisionItem {
  final String awaitingResponseId;
  final String question;
  final List<String>? options;
  final int? timeoutMs;
  final String receivedAt;
}

// providers/session_provider.dart
class SessionState {
  final String? sessionId;
  final String? projectId;
  final SessionStatus status;
  final String? currentTask;
  final int dependenceLevel;           // 1–5
  final List<LogEntry> logs;           // capped at 1000 entries
  final List<PreflightItem> preflightQueue;
  final List<DecisionItem> decisionQueue;
  final TaskCompletePayload? lastComplete;
  final TaskFailedPayload? lastFailed;
}

class SessionNotifier extends AsyncNotifier<SessionState> {
  void appendLog(LogEntry entry);       // drop oldest when logs.length > 1000
  void pushPreflight(PreflightItem item);
  void resolvePreflight(String awaitingResponseId);
  void pushDecision(DecisionItem item);
  void resolveDecision(String awaitingResponseId);
  void setStatus(SessionStatus status);
  void setLevel(int level);
  void clearLogs();
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
```

Cap logs at 1000 entries — drop oldest when exceeded.
Persist `dependenceLevel` and `sessionId` to `SharedPreferences` across app restarts.

### connection_provider.dart

```dart
class ConnectionState {
  final String? deviceId;
  final String signalingUrl;
  final bool daemonConnected;
  final bool appConnected;             // socket is connected
  final String? lastPongAt;
  final PairingStatus pairingStatus;  // unpaired | connecting | paired | daemon_offline
}

class ConnectionNotifier extends AsyncNotifier<ConnectionState> {
  void setDeviceId(String id);
  void setSignalingUrl(String url);
  void setDaemonConnected(bool v);
  void setPairingStatus(PairingStatus s);
}

final connectionProvider = AsyncNotifierProvider<ConnectionNotifier, ConnectionState>(
  ConnectionNotifier.new,
);
```

Default `signalingUrl`: the URL of the deployed signaling server.
Allow override in settings for self-hosted relay.

---

## STEP 5 — Screens

### Pairing Screen (screens/pair_screen.dart)

First-run screen. User has two options:

**Option A — Scan QR code**
- Open device camera via `mobile_scanner`
- Scan QR code shown by `CodeTwin connect` in CLI
- QR payload is: `{ "deviceId": "...", "signalingUrl": "..." }`
- On successful scan: save to `flutter_secure_storage`, navigate to dashboard via `context.go('/dashboard')`

**Option B — Manual entry**
- `TextFormField` for deviceId (12-char hex string)
- `TextFormField` for signaling URL
- Validate deviceId matches `RegExp(r'^[0-9a-f]{12}$')`
- On submit: same save + navigate flow

After pairing, `SocketService` connects to the relay.
Show connection status with a `LinearProgressIndicator`:
"Connecting…" → "Paired — daemon online" or "Daemon offline".

### Dashboard Screen (screens/dashboard_screen.dart)

Primary screen. Shows:

**Top section — Session status**
- `SessionStatusBadge` showing current status
- Current task text (if running)
- Dependence level with `LevelPicker`

**Middle section — Active cards**
- If `preflightQueue` has items: show topmost `PreflightCard` with approve/reject/modify
- If `decisionQueue` has items: show topmost `DecisionCard` with answer input
- If idle: show `TaskInput` for submitting a new task
- If running (no pending approval): show last 5 log lines from `AgentLogList`

**Bottom section — Quick actions**
- [Submit new task] — shows `TaskInput`
- [Cancel task] — sends `TASK_CANCEL`
- [View full log] — navigates to logs tab via `context.go('/logs')`

### Logs Screen (screens/logs_screen.dart)

- `ListView.builder` of `LogEntry` items, newest at bottom
- Auto-scroll to bottom on new log using a `ScrollController` — with a floating "↓ new logs" `FloatingActionButton` if user has scrolled up
- Filter `SegmentedButton`: all / info / warn / error / tool
- Each row shows: timestamp, level badge, tool name (if present), message
- Color-code by level: info = default, warn = amber, error = red, tool = purple
- "Clear logs" `IconButton` in `AppBar`

### History Screen (screens/history_screen.dart)

Shows past sessions fetched from daemon `GET /sessions`:
- Each session shows: task description, status, timestamp, files changed, duration
- Tap to expand (using `ExpansionTile`) and see decision log for that session
- Decision entries show: description, choice made, rejected alternatives, reasoning

Fetch on mount and on `RefreshIndicator` pull-to-refresh. Show `Shimmer` skeleton loaders while loading.
If daemon is offline: show cached data from last successful fetch (store in `SharedPreferences`).

### Settings Screen (screens/settings_screen.dart)

- Current pairing: deviceId, signaling URL, connection status
- [Re-pair] — `context.go('/pair')`
- [Change signaling URL] — inline `TextFormField`
- Dependence level selector (persistent override)
- Push notifications: `SwitchListTile` enable / disable with explanation of when they fire
- App version (from `package_info_plus`)

---

## STEP 6 — Widgets

### preflight_card.dart

Displays a `PreflightMap` compactly in a `Card`.

Layout:
```
┌─ PRE-FLIGHT MAP ──────────────────────────────────┐
│ Refactor auth module                   BLAST: HIGH │
├─── FILES TO WRITE ────────────────────────────────┤
│ src/auth/index.ts                                  │
│ src/auth/jwt.ts                                    │
├─── FILES TO DELETE ───────────────────────────────┤
│ src/auth/legacy.ts                                 │
├─── SHELL COMMANDS ────────────────────────────────┤
│ npm install jsonwebtoken                           │
├─── AFFECTED FUNCTIONS ────────────────────────────┤
│ validateToken()  refreshSession()  loginUser()     │
├─── AGENT REASONING ───────────────────────────────┤
│ Replacing custom JWT logic — missing expiry check  │
└────────────────────────────────────────────────────┘
[✓ Approve]  [✗ Reject]  [✎ Modify]
```

Blast radius badge colors: low = green, medium = amber, high = red.

On "Modify": show a `TextField` "How would you like to change the approach?"
and send the answer as `USER_ANSWER` with the `awaitingResponseId`.

On approve: send `USER_APPROVE` envelope:
```dart
AgentMessage(
  type: MessageType.userApprove,
  sessionId: sessionId,
  projectId: projectId,
  deviceId: deviceId,
  timestamp: DateTime.now().toIso8601String(),
  payload: { 'awaitingResponseId': awaitingResponseId },
)
```

On reject: send `USER_REJECT` with same payload shape.

### decision_card.dart

Shown when daemon emits `AWAITING_APPROVAL`:
- Displays `question` text
- If `options` is present: show as numbered `OutlinedButton` widgets, tap to select
- If no options: show free-text `TextField` with submit `ElevatedButton`
- If `timeoutMs` is set: show countdown using a `StreamBuilder` over a `Stream.periodic` — when it reaches 0, send `USER_REJECT` automatically
- Send answer as `USER_ANSWER` with `awaitingResponseId` and chosen answer

### daemon_status_bar.dart

Always-visible banner at top of all tabs using a `Material` widget above the `Scaffold`:
- Green `Chip` + "Daemon online" when paired and connected
- Amber `Chip` + "Daemon offline — waiting for reconnect" when disconnected
- Red `Chip` + "Not paired" when no deviceId stored
- Tap opens settings via `context.go('/settings')`

### level_picker.dart

`SegmentedButton<int>` with 5 segments (1–5).
Selected segment is filled, others outlined.
On selection: send `LEVEL_CHANGE` to daemon and update local provider.
Show `Text` label below current selection:
- 1: "Ask everything"
- 2: "Ask on writes"
- 3: "Ask on ambiguity"
- 4: "Ask on destructive"
- 5: "Full delegate"

---

## STEP 7 — Push Notifications (services/notifications_service.dart)

Use `firebase_messaging` + `flutter_local_notifications`:
1. Request permission on first launch via `FirebaseMessaging.instance.requestPermission()`
2. Get FCM token, store in `flutter_secure_storage`
3. Register `FirebaseMessaging.onMessage` listener — only show local notification if app is backgrounded
4. Register `FirebaseMessaging.onMessageOpenedApp` — on tap, navigate to relevant screen

```dart
class NotificationsService {
  Future<bool> requestPermission();
  Future<void> scheduleApprovalNotification(String question, String awaitingResponseId);
  Future<void> schedulePreflightNotification(String taskDescription, String blastRadius);
  Future<void> scheduleCompleteNotification(String summary);
  Future<void> scheduleFailedNotification(String error);
  Future<void> cancelAll();
}
```

When the user taps a notification, navigate to dashboard and open the relevant modal.
Use `go_router`'s `context.push('/modals/preflight')` or `'/modals/decision'`.
Pass `awaitingResponseId` as a query parameter.

---

## STEP 8 — Helper Classes (hooks/)

Flutter does not have React hooks, but the equivalent pattern is Riverpod providers + extension methods.

### use_daemon.dart (DaemonActions extension / provider)

The primary helper for sending messages to the daemon:

```dart
// providers/daemon_actions_provider.dart

class DaemonActions {
  final ConnectionState connection;
  final SessionState session;
  final SocketService socketService;

  bool get isDaemonConnected => connection.daemonConnected;

  void _send(MessageType type, Map<String, dynamic> payload) {
    if (!isDaemonConnected) {
      // Show "Daemon offline" SnackBar — do NOT queue the task locally
      return;
    }
    final msg = AgentMessage(
      type: type,
      sessionId: session.sessionId ?? '',
      projectId: session.projectId ?? '',
      deviceId: connection.deviceId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      payload: payload,
    );
    socketService.send(msg);
  }

  void submitTask(String task) =>
    _send(MessageType.taskSubmit, { 'task': task, 'dependenceLevel': session.dependenceLevel });

  void cancelTask() =>
    _send(MessageType.taskCancel, {});

  void approve(String awaitingResponseId) =>
    _send(MessageType.userApprove, { 'awaitingResponseId': awaitingResponseId });

  void reject(String awaitingResponseId) =>
    _send(MessageType.userReject, { 'awaitingResponseId': awaitingResponseId });

  void answer(String awaitingResponseId, String answer) =>
    _send(MessageType.userAnswer, { 'awaitingResponseId': awaitingResponseId, 'answer': answer });

  void changeLevel(int newLevel) =>
    _send(MessageType.levelChange, { 'newLevel': newLevel });

  void ping() =>
    _send(MessageType.ping, {});
}

final daemonActionsProvider = Provider<DaemonActions>((ref) {
  final connection = ref.watch(connectionProvider).valueOrNull ?? ConnectionState.empty;
  final session = ref.watch(sessionProvider).valueOrNull ?? SessionState.empty;
  return DaemonActions(connection, session, SocketService());
});
```

### use_session_stream.dart

Riverpod provider that watches `AGENT_LOG` messages from the socket and feeds `AgentLogList`.
Exposes `logs` and `isStreaming` computed from `sessionProvider`.

---

## STEP 9 — Pairing Flow (utils/device_id.dart)

```dart
// utils/device_id.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const _deviceIdKey = 'CodeTwin_device_id';
const _signalingUrlKey = 'CodeTwin_signaling_url';

Future<void> savePairing(String deviceId, String signalingUrl) async { ... }

Future<({String deviceId, String signalingUrl})?> loadPairing() async { ... }

Future<void> clearPairing() async { ... }
```

On app startup (`main.dart` / `app.dart`):
1. Call `loadPairing()`
2. If no pairing: `go_router` redirects to `/pair`
3. If pairing exists: connect `SocketService`, redirect to `/dashboard`

---

## STEP 10 — Navigation (router.dart + app.dart)

```dart
// router.dart
final routerProvider = Provider<GoRouter>((ref) {
  final connection = ref.watch(connectionProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isPaired = connection.valueOrNull?.deviceId != null;
      if (!isPaired && state.matchedLocation != '/pair') return '/pair';
      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/dashboard'),
      GoRoute(path: '/pair', builder: (_, __) => const PairScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => ShellScreen(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/dashboard', builder: ...)]),
          StatefulShellBranch(routes: [GoRoute(path: '/logs', builder: ...)]),
          StatefulShellBranch(routes: [GoRoute(path: '/history', builder: ...)]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: ...)]),
        ],
      ),
      GoRoute(path: '/modals/preflight', builder: (_, state) =>
        PreflightModal(awaitingResponseId: state.uri.queryParameters['id']!)),
      GoRoute(path: '/modals/decision', builder: (_, state) =>
        DecisionModal(awaitingResponseId: state.uri.queryParameters['id']!)),
    ],
  );
});
```

`ShellScreen` provides the `BottomNavigationBar`:
- Tabs: Dashboard, Logs, History, Settings
- Dashboard tab shows a `Badge` with count equal to `preflightQueue.length + decisionQueue.length`
- `DaemonStatusBar` renders above the tab body on every tab

---

## pubspec.yaml (key dependencies)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Navigation
  go_router: ^14.0.0
  # State
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  # Sockets
  socket_io_client: ^2.0.3+1
  # Notifications
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^17.0.0
  # QR
  mobile_scanner: ^5.0.0
  qr_flutter: ^4.1.0
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.0
  path_provider: ^2.1.0
  # Utilities
  package_info_plus: ^8.0.0
  intl: ^0.19.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  flutter_lints: ^4.0.0
```

---

## CRITICAL EDGE CASES — handle every one

| Scenario | Handling |
|---|---|
| Daemon offline when task submitted | Show "Daemon offline" `SnackBar` — do NOT queue the task locally |
| Preflight arrives when app is backgrounded | FCM push notification — tap opens `PreflightModal` |
| Both app and CLI approve simultaneously | Daemon decides (first wins) — app shows "Approved from another client" `SnackBar` |
| Socket disconnects mid-preflight | Show "Connection lost — daemon will timeout this approval" banner |
| Invalid message received from relay | `ValidationException` caught — `debugPrint` in debug, silently discard in release, never crash |
| No sessions found in history | Show empty state widget: "No sessions yet — submit a task from here or your terminal" |
| Pairing QR scan fails | Show `SnackBar` error + offer manual entry fallback |
| Notification permission denied | Show inline prompt in settings explaining value, do not block core functionality |
| Dependence level changed by CLI simultaneously | `SESSION_STATUS` message resyncs the level — `LevelPicker` updates immediately via provider watch |
| `awaitingResponseId` not found in queue | Log warning — the daemon may have timed out, do nothing |
| App restarts while task running | On reconnect, daemon sends `SESSION_STATUS` — restore UI state from payload |
| Decision timeout reaches 0 | Auto-send `USER_REJECT` — show "Timed out — sent rejection" `SnackBar` |

---

## BUILD ORDER — follow exactly

```
lib/models/                                   ← data classes, enums first
lib/utils/validators.dart                     ← shared contract, nothing works without this
lib/utils/device_id.dart + formatters.dart
lib/constants/levels.dart
lib/providers/connection_provider.dart
lib/providers/session_provider.dart
lib/providers/notifications_provider.dart
lib/services/socket_service.dart
lib/services/message_service.dart
lib/services/notifications_service.dart
lib/providers/daemon_actions_provider.dart
lib/widgets/daemon_status_bar.dart + session_status_badge.dart + blast_radius_badge.dart
lib/widgets/preflight_card.dart + decision_card.dart
lib/widgets/agent_log_list.dart + task_input.dart + level_picker.dart
lib/screens/pair_screen.dart
lib/router.dart + lib/screens/shell_screen.dart + dashboard_screen.dart
lib/screens/logs_screen.dart + history_screen.dart + settings_screen.dart
lib/screens/modals/preflight_modal.dart + decision_modal.dart
lib/app.dart + lib/main.dart
```

---

## VERIFICATION CHECKLIST

After each step:
- [ ] `dart analyze` reports zero errors or warnings
- [ ] No `dynamic` types except at JSON parse boundaries, immediately followed by manual validation in `validators.dart`
- [ ] Every inbound WebSocket message is validated before processing — `ValidationException` is always caught
- [ ] No LLM API calls anywhere in this codebase
- [ ] No filesystem access except `flutter_secure_storage`, `shared_preferences`, and `path_provider` for log cache
- [ ] Daemon offline state is handled gracefully on every screen — no crashes, no unhandled `null`s
- [ ] `awaitingResponseId` is always echoed back in approval/rejection messages
- [ ] Push notifications (FCM) only fire when app is backgrounded — foreground uses in-app `SnackBar`

## DO NOT BUILD IN THIS PHASE

- LLM integration of any kind
- Direct filesystem access
- Any backend logic — this is a thin client only
- Auth layer (v2)
- Multi-daemon support (one pairing at a time)
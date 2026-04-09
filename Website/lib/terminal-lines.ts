export interface TerminalLine {
  text: string
  color?: string
  delay?: number
  indent?: number
}

// Color constants matching the design spec
const C = {
  secondary: '#888888',
  success: '#22c55e',
  box: '#cccccc',
  accent: '#7c3aed',
  primary: '#f5f5f5',
  warning: '#f59e0b',
  muted: '#555555',
} as const

export const terminalDemoLines: TerminalLine[] = [
  { text: '$ devtwin task "refactor auth module to use JWT"', color: C.primary, delay: 0 },
  { text: '', delay: 80 },
  { text: '● DevTwin  analyzing codebase...', color: C.secondary, delay: 60 },
  { text: '● DevTwin  building pre-flight map', color: C.secondary, delay: 60 },
  { text: '', delay: 80 },
  { text: '┌─ PRE-FLIGHT MAP ─────────────────────────┐', color: C.box, delay: 60 },
  { text: '│ Blast radius: HIGH                        │', color: C.box, delay: 40 },
  { text: '│                                           │', color: C.box, delay: 20 },
  { text: '│ Files to write                            │', color: C.box, delay: 40 },
  { text: '│   src/auth/index.ts                       │', color: C.warning, delay: 40 },
  { text: '│   src/auth/middleware.ts                  │', color: C.warning, delay: 40 },
  { text: '│                                           │', color: C.box, delay: 20 },
  { text: '│ Files to delete                           │', color: C.box, delay: 40 },
  { text: '│   src/auth/legacy-sessions.ts             │', color: C.warning, delay: 40 },
  { text: '│                                           │', color: C.box, delay: 20 },
  { text: '│ Shell commands                            │', color: C.box, delay: 40 },
  { text: '│   npm install jsonwebtoken                │', color: C.warning, delay: 40 },
  { text: '│                                           │', color: C.box, delay: 20 },
  { text: '│ Affected functions                        │', color: C.box, delay: 40 },
  { text: '│   validateToken(), refreshSession()       │', color: C.warning, delay: 40 },
  { text: '└───────────────────────────────────────────┘', color: C.box, delay: 40 },
  { text: '', delay: 80 },
  { text: '[A] Approve   [R] Reject   [M] Modify', color: C.accent, delay: 60 },
  { text: '', delay: 100 },
  { text: '> A', color: C.primary, delay: 800 },
  { text: '', delay: 60 },
  { text: '● DevTwin  installing dependencies...', color: C.secondary, delay: 80 },
  { text: '✓ npm install jsonwebtoken  (2.1s)', color: C.success, delay: 600 },
  { text: '● DevTwin  writing src/auth/index.ts', color: C.secondary, delay: 60 },
  { text: '● DevTwin  writing src/auth/middleware.ts', color: C.secondary, delay: 60 },
  { text: '● DevTwin  removing src/auth/legacy-sessions.ts', color: C.secondary, delay: 60 },
  { text: '✓ Task complete  3 files changed · 1 decision recorded', color: C.success, delay: 400 },
]

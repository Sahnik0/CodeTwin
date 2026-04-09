import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Changelog — DevTwin',
  description: 'Release history for DevTwin.',
}

const changelog = `
v0.4.0 — 2026-03-15
────────────────────
- Added remote control via encrypted relay
- Mobile app: approve pre-flight maps from phone
- New dependence level 4 (destructive-only)
- devtwin connect — QR pairing flow
- Twin memory: failure pattern tracking

v0.3.2 — 2026-02-28
────────────────────
- Fixed: Ollama provider timeout on slow models (was 10s, now 90s)
- Fixed: edit tool line offset bug when file has trailing newline
- Improved: pre-flight map rendering in narrow terminals
- Added: Azure OpenAI provider support

v0.3.0 — 2026-02-10
────────────────────
- Twin memory: per-project SQLite storage
- Constraints system: add/remove/list active rules
- Decision recording with reason tracking
- devtwin memory show / reset commands
- Breaking: config format updated — run devtwin config init to migrate

v0.2.0 — 2026-01-20
────────────────────
- Pre-flight maps: blast radius classification (LOW / MEDIUM / HIGH)
- Interactive TUI with Ink
- Five dependence levels (replacing binary ask/silent)
- Groq, Mistral, Cohere provider support
- Shell timeout: 30s default, configurable

v0.1.0 — 2026-01-05
────────────────────
- Initial release
- OpenAI, Anthropic, Gemini, Ollama providers
- read, write, edit, bash, git tools
- Basic pre-flight map
`.trim()

export default function ChangelogPage() {
  return (
    <div className="min-h-screen pt-24 pb-20 px-6">
      <div className="max-w-2xl mx-auto">
        <div className="mb-10">
          <h1 className="text-2xl font-medium text-text-primary mb-2">Changelog</h1>
          <p className="text-sm text-text-secondary">
            All notable changes to DevTwin. Dates are UTC.
          </p>
        </div>

        <pre className="font-mono text-sm text-text-secondary leading-relaxed whitespace-pre-wrap">
          {changelog}
        </pre>

        <div className="mt-12 pt-8 border-t border-border-default">
          <a
            href="https://github.com/devtwin/devtwin/releases"
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs text-text-muted hover:text-text-secondary transition-colors"
          >
            View full release history on GitHub →
          </a>
        </div>
      </div>
    </div>
  )
}

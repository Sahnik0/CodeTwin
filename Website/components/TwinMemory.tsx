export default function TwinMemory() {
  return (
    <div className="bg-surface-elevated border border-border-default rounded-lg p-5 font-mono text-[12px] leading-relaxed">
      {/* Header */}
      <div className="text-text-primary mb-3 text-sm">
        twin memory — myapp
      </div>
      <div className="border-t border-border-default mb-3" />

      {/* Stack */}
      <div className="flex gap-4 mb-3">
        <span className="text-text-muted w-20 flex-shrink-0">stack</span>
        <span className="text-text-secondary">Next.js · TypeScript · MongoDB</span>
      </div>
      <div className="border-t border-border-default mb-3" />

      {/* Decisions */}
      <div className="mb-1 text-text-muted">decisions (last 5)</div>
      <div className="ml-2 flex flex-col gap-2 mb-3">
        {[
          { date: 'Jan 12', action: 'chose JWT over sessions', reason: 'bundle size concern' },
          { date: 'Jan 10', action: 'switched to pnpm', reason: 'client requirement' },
          { date: 'Jan 08', action: 'rejected lodash', reason: 'tree-shaking issues' },
        ].map((d) => (
          <div key={d.date}>
            <div className="text-text-secondary">
              <span className="text-text-muted">[{d.date}]</span> {d.action}
            </div>
            <div className="text-text-muted ml-8">reason: {d.reason}</div>
          </div>
        ))}
      </div>
      <div className="border-t border-border-default mb-3" />

      {/* Constraints */}
      <div className="mb-1 text-text-muted">constraints (3 active)</div>
      <div className="ml-2 flex flex-col gap-1 mb-3">
        {['no lodash', 'no `any` types', 'use pnpm, not npm'].map((c) => (
          <div key={c} className="flex items-center gap-2">
            <span className="text-danger">✗</span>
            <span className="text-text-secondary">{c}</span>
          </div>
        ))}
      </div>
      <div className="border-t border-border-default mb-3" />

      {/* Failure patterns */}
      <div className="mb-1 text-text-muted">failure patterns (1)</div>
      <div className="ml-2">
        <div className="flex items-start gap-2">
          <span className="text-warning mt-0.5">⚠</span>
          <div>
            <div className="text-text-secondary">babel transform — src/auth</div>
            <div className="text-text-muted">missing peer dep: @babel/core</div>
          </div>
        </div>
      </div>
    </div>
  )
}

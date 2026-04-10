import type { ReactNode } from 'react'

interface ProviderCardProps {
  name: string
  model: string
  badge?: string
  icon?: ReactNode
  abbr?: string
  color?: string
}

export default function ProviderCard({
  name,
  model,
  badge,
  icon,
  abbr,
  color = '#7c3aed',
}: ProviderCardProps) {
  return (
    <div className="group flex flex-col gap-3 p-4 bg-surface border border-border-default rounded-lg hover:border-border-hover transition-colors duration-200">
      {/* Icon or abbreviation circle */}
      <div
        className="w-9 h-9 rounded flex items-center justify-center text-xs font-mono font-medium text-white flex-shrink-0"
        style={{ backgroundColor: color + '22', border: `1px solid ${color}33` }}
        aria-hidden="true"
      >
        {icon ?? (
          <span style={{ color }}>{abbr ?? name.slice(0, 2).toUpperCase()}</span>
        )}
      </div>

      <div className="flex flex-col gap-1 min-w-0">
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-sm font-medium text-text-primary">{name}</span>
          {badge && (
            <span
              className={`text-xs px-1.5 py-0.5 rounded font-mono ${badge === 'Local'
                  ? 'bg-success/10 text-success border border-success/20'
                  : badge === 'Fast'
                    ? 'bg-warning/10 text-warning border border-warning/20'
                    : badge === 'Enterprise'
                      ? 'bg-accent/10 text-accent border border-accent/20'
                      : 'bg-border-default text-text-muted border border-border-default'
                }`}
            >
              {badge}
            </span>
          )}
        </div>
        <span className="text-xs text-text-muted font-mono truncate" title={model}>
          {model}
        </span>
      </div>
    </div>
  )
}

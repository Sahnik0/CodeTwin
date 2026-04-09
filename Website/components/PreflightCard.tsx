interface PreflightCardProps {
  task?: string
  blastRadius?: 'LOW' | 'MEDIUM' | 'HIGH'
  onApprove?: () => void
  onReject?: () => void
}

export default function PreflightCard({
  task = 'Refactor auth module to use JWT',
  blastRadius = 'HIGH',
  onApprove,
  onReject,
}: PreflightCardProps) {
  const blastColors: Record<string, string> = {
    LOW: 'text-success',
    MEDIUM: 'text-warning',
    HIGH: 'text-danger',
  }

  return (
    <div className="bg-[#0d0d0d] border border-border-default rounded-lg p-3 mx-2 mb-2">
      <div className="flex items-start gap-2 mb-3">
        <div className="w-1.5 h-1.5 rounded-full bg-warning mt-1.5 flex-shrink-0 pulse-dot" />
        <div>
          <p className="text-[11px] font-medium text-text-primary leading-tight">
            Agent is waiting for approval
          </p>
          <p className="text-[10px] text-text-muted mt-0.5 font-mono leading-tight truncate">
            {task}
          </p>
        </div>
      </div>

      <div className="flex items-center gap-1.5 mb-3">
        <span className="text-[10px] text-text-muted">Blast radius:</span>
        <span className={`text-[10px] font-mono font-medium ${blastColors[blastRadius]}`}>
          {blastRadius}
        </span>
      </div>

      <div className="flex gap-2">
        <button
          onClick={onApprove}
          className="flex-1 py-1 text-[11px] font-medium rounded bg-success/10 text-success border border-success/20 hover:bg-success/20 transition-colors"
        >
          Approve
        </button>
        <button
          onClick={onReject}
          className="flex-1 py-1 text-[11px] font-medium rounded bg-danger/10 text-danger border border-danger/20 hover:bg-danger/20 transition-colors"
        >
          Reject
        </button>
      </div>
    </div>
  )
}

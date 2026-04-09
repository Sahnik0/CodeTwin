'use client'

import { useState } from 'react'
import { Copy, Check } from 'lucide-react'

interface InstallStripProps {
  command?: string
}

export default function InstallStrip({
  command = 'curl -fsSL https://devtwin.dev/install.sh | bash',
}: InstallStripProps) {
  const [copied, setCopied] = useState(false)

  async function handleCopy() {
    try {
      await navigator.clipboard.writeText(command)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // clipboard unavailable — silently fail
    }
  }

  return (
    <div className="flex items-center gap-3 bg-surface-elevated border border-border-default rounded-lg px-4 py-3 max-w-xl w-full">
      <span className="text-text-muted font-mono text-sm select-none flex-shrink-0">$</span>
      <code className="font-mono text-sm text-text-primary flex-1 overflow-x-auto whitespace-nowrap scrollbar-none">
        {command}
      </code>
      <button
        onClick={handleCopy}
        aria-label="Copy install command"
        className="flex-shrink-0 text-text-muted hover:text-text-primary transition-colors p-1 rounded"
      >
        {copied ? (
          <Check size={14} className="text-success" />
        ) : (
          <Copy size={14} />
        )}
      </button>
    </div>
  )
}

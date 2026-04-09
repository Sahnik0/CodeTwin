'use client'

import { useState } from 'react'
import { Copy, Check } from 'lucide-react'

interface CopyButtonProps {
  text: string
  label?: string
}

export default function CopyButton({ text, label = 'Copy code' }: CopyButtonProps) {
  const [copied, setCopied] = useState(false)

  async function handleCopy() {
    try {
      await navigator.clipboard.writeText(text)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // silently fail
    }
  }

  return (
    <button
      onClick={handleCopy}
      aria-label={label}
      className="flex items-center gap-1.5 px-2 py-1 text-xs text-text-muted hover:text-text-primary bg-surface border border-border-default rounded transition-colors"
    >
      {copied ? (
        <>
          <Check size={11} className="text-success" />
          Copied
        </>
      ) : (
        <>
          <Copy size={11} />
          Copy
        </>
      )}
    </button>
  )
}

'use client'

import { useState } from 'react'
import { Copy, Check } from 'lucide-react'

type Platform = 'linux' | 'macos' | 'windows'

interface InstallOption {
  id: Platform
  label: string
  command: string
}

const INSTALL_OPTIONS: InstallOption[] = [
  {
    id: 'linux',
    label: 'Linux',
    command: 'curl -fsSL https://code-twin.vercel.app/install.sh | bash',
  },
  {
    id: 'macos',
    label: 'macOS',
    command: 'curl -fsSL https://code-twin.vercel.app/install.sh | bash',
  },
  {
    id: 'windows',
    label: 'Windows',
    command: 'irm https://code-twin.vercel.app/install.ps1 | iex',
  },
]

interface InstallStripProps {
  defaultPlatform?: Platform
}

export default function InstallStrip({ defaultPlatform = 'linux' }: InstallStripProps) {
  const [copied, setCopied] = useState(false)
  const [selectedPlatform, setSelectedPlatform] = useState<Platform>(defaultPlatform)

  const activeOption = INSTALL_OPTIONS.find((option) => option.id === selectedPlatform) ?? INSTALL_OPTIONS[0]

  async function handleCopy() {
    try {
      await navigator.clipboard.writeText(activeOption.command)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      // clipboard unavailable — silently fail
    }
  }

  return (
    <div className="bg-surface-elevated border border-border-default rounded-lg px-3 py-2.5 max-w-2xl w-full">
      <div className="flex flex-col sm:flex-row sm:items-center gap-2">
        <div className="flex items-center gap-2 min-w-0 flex-1">
          <code className="font-mono text-xs md:text-sm text-text-primary flex-1 overflow-x-auto whitespace-nowrap scrollbar-none pr-1">
            {activeOption.command}
          </code>
          <button
            onClick={handleCopy}
            aria-label={`Copy ${activeOption.label} install command`}
            className="flex-shrink-0 text-text-muted hover:text-text-primary transition-colors p-1 rounded"
          >
            {copied ? (
              <Check size={14} className="text-success" />
            ) : (
              <Copy size={14} />
            )}
          </button>
        </div>

        <div className="sm:border-l sm:border-border-default sm:pl-2 flex-shrink-0">
          <label htmlFor="install-platform" className="sr-only">
            Select operating system
          </label>
          <select
            id="install-platform"
            value={selectedPlatform}
            onChange={(event) => {
              setSelectedPlatform(event.target.value as Platform)
              setCopied(false)
            }}
            aria-label="Select operating system"
            className="h-8 px-2 rounded-md border border-[#a6a6ed66] text-[11px] font-mono text-[#a6a6ed] bg-[#a6a6ed12] focus:outline-none focus:ring-1 focus:ring-[#a6a6ed]"
          >
            {INSTALL_OPTIONS.map((option) => (
              <option key={option.id} value={option.id} className="bg-surface-elevated text-text-primary">
                {option.label}
              </option>
            ))}
          </select>
        </div>
      </div>
    </div>
  )
}

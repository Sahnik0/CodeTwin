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

function WindowsLogo() {
  return (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <rect x="1" y="1" width="4" height="4" rx="0.6" fill="currentColor" />
      <rect x="7" y="1" width="4" height="4" rx="0.6" fill="currentColor" />
      <rect x="1" y="7" width="4" height="4" rx="0.6" fill="currentColor" />
      <rect x="7" y="7" width="4" height="4" rx="0.6" fill="currentColor" />
    </svg>
  )
}

function LinuxLogo() {
  return (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <circle cx="6" cy="3.2" r="2" fill="currentColor" />
      <ellipse cx="6" cy="8" rx="3" ry="2.7" fill="currentColor" />
      <circle cx="5.2" cy="3" r="0.25" fill="#0b0b0b" />
      <circle cx="6.8" cy="3" r="0.25" fill="#0b0b0b" />
    </svg>
  )
}

function MacLogo() {
  return (
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" aria-hidden="true">
      <path
        d="M7.9 2.4c0.3-0.4 0.5-0.9 0.5-1.3c-0.5 0-1 0.3-1.3 0.6c-0.3 0.3-0.5 0.8-0.5 1.2c0.5 0 1-0.2 1.3-0.5Z"
        fill="currentColor"
      />
      <path
        d="M9.6 6.5c0-1.1 0.8-1.7 0.8-1.8c-0.4-0.6-1.1-0.7-1.3-0.7c-0.6-0.1-1.1 0.3-1.4 0.3c-0.3 0-0.7-0.3-1.2-0.3c-1 0-1.9 0.6-2.4 1.5c-0.9 1.5-0.2 3.8 0.7 5c0.4 0.6 0.9 1.2 1.5 1.2c0.6 0 0.8-0.3 1.5-0.3c0.7 0 0.9 0.3 1.5 0.3c0.6 0 1-0.6 1.4-1.2c0.5-0.8 0.7-1.6 0.7-1.7c0 0-1.3-0.5-1.3-2.3Z"
        fill="currentColor"
      />
    </svg>
  )
}

function PlatformLogo({ platform }: { platform: Platform }) {
  if (platform === 'windows') {
    return <WindowsLogo />
  }

  if (platform === 'macos') {
    return <MacLogo />
  }

  return <LinuxLogo />
}

export default function InstallStrip({ defaultPlatform = 'linux' }: InstallStripProps) {
  const [copied, setCopied] = useState(false)
  const [selectedPlatform, setSelectedPlatform] = useState<Platform>(defaultPlatform)

  const activeOption = INSTALL_OPTIONS.find((option) => option.id === selectedPlatform) ?? INSTALL_OPTIONS[0]
  const restOptions = INSTALL_OPTIONS.filter((option) => option.id !== selectedPlatform)

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

        <div className="relative sm:border-l sm:border-border-default sm:pl-2 flex-shrink-0 group/platform overflow-visible">
          <button
            type="button"
            aria-label={`Selected operating system: ${activeOption.label}`}
            className="h-8 px-2 rounded-md border border-[#a6a6ed66] text-[11px] font-mono inline-flex items-center gap-1.5 text-[#a6a6ed] bg-[#a6a6ed12] cursor-default"
          >
            <span className="opacity-90">
              <PlatformLogo platform={activeOption.id} />
            </span>
            {activeOption.label}
          </button>

          <div className="absolute left-full top-1/2 -translate-y-1/2 ml-2 inline-flex items-center gap-1 p-1 rounded-lg border border-border-default bg-surface-elevated shadow-[0_10px_24px_rgba(0,0,0,0.35)] opacity-0 pointer-events-none translate-x-1 scale-95 origin-left transition-all duration-150 group-hover/platform:opacity-100 group-hover/platform:pointer-events-auto group-hover/platform:translate-x-0 group-hover/platform:scale-100 group-focus-within/platform:opacity-100 group-focus-within/platform:pointer-events-auto group-focus-within/platform:translate-x-0 group-focus-within/platform:scale-100 max-sm:left-0 max-sm:top-full max-sm:translate-y-0 max-sm:mt-1 max-sm:ml-0 max-sm:origin-top max-sm:translate-x-0">
            {restOptions.map((option) => (
              <button
                key={option.id}
                type="button"
                onClick={() => {
                  setSelectedPlatform(option.id)
                  setCopied(false)
                }}
                aria-label={`Use ${option.label} install command`}
                className="h-8 px-2 rounded-md border border-border-default text-[11px] font-mono inline-flex items-center gap-1.5 text-text-muted hover:text-text-primary hover:border-border-hover bg-background"
              >
                <span className="opacity-90">
                  <PlatformLogo platform={option.id} />
                </span>
                {option.label}
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}

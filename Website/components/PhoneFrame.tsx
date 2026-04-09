import type { ReactNode } from 'react'

interface PhoneFrameProps {
  children: ReactNode
}

export default function PhoneFrame({ children }: PhoneFrameProps) {
  return (
    <div
      className="relative mx-auto"
      style={{
        width: '260px',
        height: '520px',
      }}
    >
      {/* Outer bezel */}
      <div
        className="absolute inset-0 rounded-[2.5rem] border-2 border-border-hover bg-surface-elevated shadow-2xl"
        style={{
          boxShadow: '0 0 0 1px rgba(255,255,255,0.06) inset, 0 32px 64px rgba(0,0,0,0.6)',
        }}
      />

      {/* Notch */}
      <div
        className="absolute top-0 left-1/2 -translate-x-1/2 mt-3 z-10"
        style={{
          width: '72px',
          height: '24px',
          background: '#1a1a1a',
          borderRadius: '0 0 1rem 1rem',
          border: '1px solid #333',
          borderTop: 'none',
        }}
      />

      {/* Screen area */}
      <div
        className="absolute inset-2 rounded-[2.2rem] bg-[#0a0a0a] overflow-hidden"
        style={{ marginTop: '8px', marginBottom: '8px' }}
      >
        {/* Status bar */}
        <div className="flex items-center justify-between px-5 pt-8 pb-1">
          <span className="text-[10px] font-medium text-text-secondary">9:41</span>
          <span className="text-[10px] text-text-muted">●●●</span>
        </div>

        {/* Content */}
        <div className="flex flex-col h-full pb-10 overflow-hidden">
          {children}
        </div>
      </div>

      {/* Home indicator */}
      <div
        className="absolute bottom-3 left-1/2 -translate-x-1/2 rounded-full bg-border-hover"
        style={{ width: '80px', height: '4px' }}
      />
    </div>
  )
}

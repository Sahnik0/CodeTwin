'use client'

import { useEffect, useRef, useState } from 'react'
import type { TerminalLine } from '@/lib/terminal-lines'

interface TerminalProps {
  lines: TerminalLine[]
  title?: string
  animateIn?: boolean
}

export default function Terminal({
  lines,
  title = 'devtwin',
  animateIn = true,
}: TerminalProps) {
  const [visibleCount, setVisibleCount] = useState(animateIn ? 0 : lines.length)
  const [started, setStarted] = useState(!animateIn)
  const containerRef = useRef<HTMLDivElement>(null)

  // Intersection observer — start animation when in view
  useEffect(() => {
    if (!animateIn) return
    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          setStarted(true)
          observer.disconnect()
        }
      },
      { threshold: 0.2 }
    )
    if (containerRef.current) observer.observe(containerRef.current)
    return () => observer.disconnect()
  }, [animateIn])

  // Animate lines one by one
  useEffect(() => {
    if (!started) return
    if (visibleCount >= lines.length) return

    const delay = lines[visibleCount]?.delay ?? 60
    const timer = setTimeout(() => {
      setVisibleCount((c) => c + 1)
    }, delay)

    return () => clearTimeout(timer)
  }, [started, visibleCount, lines])

  return (
    <div
      ref={containerRef}
      className="rounded-lg border border-border-default overflow-hidden shadow-2xl w-full"
    >
      {/* Title bar */}
      <div className="flex items-center gap-2 px-4 py-3 bg-surface-elevated border-b border-border-default">
        <span className="w-3 h-3 rounded-full bg-[#ff5f57]" aria-hidden="true" />
        <span className="w-3 h-3 rounded-full bg-[#febc2e]" aria-hidden="true" />
        <span className="w-3 h-3 rounded-full bg-[#28c840]" aria-hidden="true" />
        <span className="ml-3 text-xs text-text-muted font-mono">{title}</span>
      </div>

      {/* Content */}
      <div
        className="bg-[#0d0d0d] p-4 font-mono text-[13px] leading-relaxed overflow-x-auto min-h-[320px]"
        aria-live="polite"
        aria-label="Terminal output"
      >
        {lines.slice(0, visibleCount).map((line, i) => (
          <div
            key={i}
            className="whitespace-pre"
            style={{ color: line.color ?? '#888888' }}
          >
            {line.text || '\u00A0'}
          </div>
        ))}

        {/* Blinking cursor */}
        {started && visibleCount < lines.length && (
          <span className="blink text-text-secondary">▋</span>
        )}
        {started && visibleCount >= lines.length && (
          <span className="blink text-text-secondary">▋</span>
        )}
      </div>
    </div>
  )
}

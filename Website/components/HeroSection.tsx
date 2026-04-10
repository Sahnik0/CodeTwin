'use client'

import Link from 'next/link'
import { ChevronDown } from 'lucide-react'
import { motion } from 'framer-motion'
import { Suspense } from 'react'
import InstallStrip from './InstallStrip'
import CircuitPattern from './CircuitPattern'
import GitHubStarBadge from './GitHubStarBadge'

const easeOut = [0.16, 1, 0.3, 1] as const

export default function HeroSection() {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-start pt-36 pb-16 px-6 overflow-hidden">
      {/* Layered radial glow */}
      <div
        className="pointer-events-none absolute inset-0"
        style={{
          background: [
            'radial-gradient(ellipse 70% 45% at 50% 0%, rgba(45,212,191,0.07) 0%, transparent 55%)',
            'radial-gradient(ellipse 50% 60% at 80% 20%, rgba(124,58,237,0.04) 0%, transparent 60%)',
          ].join(', '),
        }}
        aria-hidden="true"
      />

      {/* Decorative circuit pattern */}
      <CircuitPattern variant="top-right" className="opacity-50" />

      <div className="relative z-10 flex flex-col items-center text-center max-w-4xl w-full">
        {/* Eyebrow badge */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: easeOut }}
        >
          <span className="inline-flex items-center gap-2 text-xs text-text-muted uppercase tracking-[0.18em] font-mono mb-8 border border-border-default rounded-full px-4 py-1.5 bg-surface/60 backdrop-blur-sm">
            <span className="w-1.5 h-1.5 rounded-full bg-[#2dd4bf] animate-pulse" />
            Terminal-First AI Coding Agent
          </span>
        </motion.div>

        {/* Main headline */}
        <h1 className="font-sans font-semibold leading-[1.08] tracking-[-0.035em] mb-6">
          {/* Line 1 */}
          <motion.span
            className="block text-hero text-text-primary"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.12, duration: 0.6, ease: easeOut }}
          >
            Your Coding Agent.
          </motion.span>
          {/* Line 2 — teal accent on last two words */}
          <motion.span
            className="block text-hero"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.22, duration: 0.6, ease: easeOut }}
          >
            <span className="text-text-primary">Your Machine. </span>
            <span className="text-[#2dd4bf]">
              Your Rules.
            </span>
          </motion.span>
        </h1>

        {/* Sub-headline */}
        <motion.p
          className="text-text-secondary max-w-[520px] mx-auto leading-relaxed mb-10"
          style={{ fontSize: '1.0625rem' }}
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.38, duration: 0.5, ease: easeOut }}
        >
          CodeTwin is a terminal-first AI coding agent that runs entirely on your
          machine. BYOK. Zero telemetry. Five autonomy levels. You decide how
          autonomous it gets.
        </motion.p>

        {/* CTA row */}
        <motion.div
          className="flex flex-col sm:flex-row items-center gap-3 mb-8"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5, duration: 0.45, ease: easeOut }}
        >
          <Link
            href="/docs/getting-started"
            className="inline-flex items-center gap-2 px-6 py-2.5 rounded-lg border border-[#2dd4bf] text-[#2dd4bf] text-sm font-medium hover:bg-[#2dd4bf14] transition-all duration-200 shadow-[0_0_20px_rgba(45,212,191,0.08)]"
          >
            Get Started →
          </Link>

          <Suspense
            fallback={
              <div className="h-[38px] w-36 rounded-lg bg-surface-elevated border border-border-default animate-pulse" />
            }
          >
            <GitHubStarBadge />
          </Suspense>
        </motion.div>

        {/* Install strip */}
        <motion.div
          className="flex justify-center w-full mb-16"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.62, duration: 0.45, ease: easeOut }}
        >
          <InstallStrip />
        </motion.div>

        {/* Hero screenshot placeholder */}
        <motion.div
          className="w-full max-w-4xl"
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.78, duration: 0.7, ease: easeOut }}
        >
          <div
            className="relative rounded-xl border border-border-default bg-surface-elevated overflow-hidden shadow-2xl aspect-[16/9]"
            style={{
              boxShadow:
                '0 0 0 1px rgba(255,255,255,0.04) inset, 0 32px 80px rgba(0,0,0,0.5), 0 0 60px rgba(45,212,191,0.04)',
            }}
          >
            {/* Placeholder inner content */}
            <div className="absolute inset-0 flex flex-col items-center justify-center gap-2">
              <div className="w-8 h-8 rounded border border-border-default flex items-center justify-center opacity-30">
                <svg width="14" height="14" viewBox="0 0 14 14" fill="none">
                  <rect x="1" y="1" width="12" height="12" rx="1.5" stroke="#888" strokeWidth="1.2" />
                  <path d="M4 7h6M7 4v6" stroke="#888" strokeWidth="1.2" strokeLinecap="round" />
                </svg>
              </div>
              <span className="text-text-muted text-[11px] font-mono opacity-30 tracking-widest uppercase">
                Screenshot Coming Soon
              </span>
            </div>
            {/* Edge fade at bottom */}
            <div className="absolute inset-x-0 bottom-0 h-1/3 bg-gradient-to-t from-background/60 to-transparent" />
          </div>
        </motion.div>
      </div>

      {/* Scroll indicator */}
      <motion.div
        className="absolute bottom-8 left-1/2 -translate-x-1/2 text-text-muted scroll-indicator"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.3, duration: 0.5 }}
        aria-hidden="true"
      >
        <ChevronDown size={18} />
      </motion.div>
    </section>
  )
}

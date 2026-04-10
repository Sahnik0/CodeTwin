'use client'

import { motion } from 'framer-motion'
import { Suspense } from 'react'
import CircuitPattern from './CircuitPattern'
import InstallStrip from './InstallStrip'
import Link from 'next/link'

const easeOut = [0.16, 1, 0.3, 1] as const

export default function FinalCTASection() {
  return (
    <section className="relative py-36 px-6 border-t border-border-default overflow-hidden bg-surface">
      {/* Background circuit patterns */}
      <CircuitPattern variant="bottom-right" className="opacity-35" />
      <CircuitPattern variant="top-left" className="opacity-20" />

      {/* Ambient glow */}
      <div
        className="pointer-events-none absolute inset-0"
        style={{
          background:
            'radial-gradient(ellipse 60% 50% at 50% 100%, rgba(45,212,191,0.05) 0%, transparent 70%)',
        }}
        aria-hidden="true"
      />

      <div className="relative z-10 max-w-3xl mx-auto text-center">
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.65, ease: easeOut }}
        >
          {/* Label */}
          <p className="text-xs text-[#2dd4bf] uppercase tracking-[0.2em] font-mono mb-6">
            Get Started Free
          </p>

          {/* Headline */}
          <h2 className="text-4xl md:text-6xl font-semibold text-text-primary leading-[1.06] tracking-tight mb-5">
            Come<br />
            Get Some Air
          </h2>

          {/* Sub copy */}
          <p className="text-base text-text-secondary mb-10 max-w-md mx-auto leading-relaxed">
            CodeTwin runs fully on your machine. No cloud, no telemetry, no vendor lock-in.
            Your code stays yours — always.
          </p>

          {/* Actions */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            {/* Install strip */}
            <Suspense
              fallback={
                <div className="h-[46px] w-72 rounded-lg bg-surface-elevated border border-border-default animate-pulse" />
              }
            >
              <InstallStrip />
            </Suspense>

            <Link
              href="/docs/getting-started"
              className="inline-flex items-center gap-2 px-6 py-2.5 rounded-lg bg-[#2dd4bf] text-background text-sm font-semibold hover:bg-[#14b8a6] transition-colors duration-200"
            >
              Read the Docs →
            </Link>
          </div>
        </motion.div>
      </div>
    </section>
  )
}

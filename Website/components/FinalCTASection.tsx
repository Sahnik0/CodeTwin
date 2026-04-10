'use client'

import { motion, useScroll, useTransform } from 'framer-motion'
import { Suspense, useRef } from 'react'
import CircuitPattern from './CircuitPattern'
import InstallStrip from './InstallStrip'
import Link from 'next/link'

const easeOut = [0.16, 1, 0.3, 1] as const

export default function FinalCTASection() {
  const containerRef = useRef<HTMLElement>(null);
  const { scrollYProgress } = useScroll({ target: containerRef, offset: ["start 80%", "center center"] });
  const textOpacity = useTransform(scrollYProgress, [0, 1], [0.1, 1]);
  const textScale = useTransform(scrollYProgress, [0, 1], [0.8, 1]);
  const letterSpacing = useTransform(scrollYProgress, [0, 1], ["-0.08em", "-0.02em"]);

  return (
    <section ref={containerRef} className="relative py-36 px-6 border-t border-border-default overflow-hidden bg-surface">
      {/* Background circuit patterns */}
      <CircuitPattern variant="bottom-right" className="opacity-35" />
      <CircuitPattern variant="top-left" className="opacity-20" />

      {/* Ambient glow */}
      <div
        className="pointer-events-none absolute inset-0"
        style={{
          background: 'radial-gradient(ellipse 60% 50% at 50% 100%, rgba(166,166,237,0.05) 0%, transparent 70%)',
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
          <p className="text-xs text-[#a6a6ed] uppercase tracking-[0.2em] font-mono mb-6">
            Get Started Free
          </p>

          {/* Headline */}
          <motion.h2 
            style={{ opacity: textOpacity, scale: textScale, letterSpacing: letterSpacing }}
            className="text-4xl md:text-6xl font-semibold text-text-primary leading-[1.06] mb-5 origin-center"
          >
            Come<br />
            Get Some Air
          </motion.h2>

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
              className="inline-flex items-center gap-2 whitespace-nowrap px-6 py-2.5 rounded-lg bg-[#a6a6ed] text-background text-sm font-semibold hover:bg-[#9494e0] transition-colors duration-200"
            >
              Read the Docs →
            </Link>
          </div>
        </motion.div>
      </div>
    </section>
  )
}

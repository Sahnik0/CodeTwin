'use client'

import Link from 'next/link'
import { ChevronDown } from 'lucide-react'
import { motion } from 'framer-motion'
import InstallStrip from './InstallStrip'
import GitHubIcon from './GitHubIcon'

const easeOut = [0.16, 1, 0.3, 1] as const

const headline = ['Your coding agent.', 'Your machine. Your rules.']

export default function HeroSection() {
  return (
    <section className="relative min-h-screen flex flex-col items-center justify-center px-6 dot-grid hero-glow overflow-hidden">
      {/* Violet bloom (additional decorative layer) */}
      <div
        className="pointer-events-none absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 rounded-full opacity-20"
        style={{
          width: '600px',
          height: '400px',
          background: 'radial-gradient(ellipse, rgba(124,58,237,0.2) 0%, transparent 70%)',
        }}
        aria-hidden="true"
      />

      <div className="relative z-10 flex flex-col items-center text-center max-w-4xl">
        {/* Eyebrow label */}
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: easeOut }}
        >
          <span className="inline-block text-xs text-text-muted uppercase tracking-[0.2em] font-mono mb-8 border border-border-default rounded px-3 py-1 bg-surface/50">
            Terminal-first AI coding agent
          </span>
        </motion.div>

        {/* Headline */}
        <h1 className="font-sans font-medium leading-[1.1] tracking-[-0.03em] mb-6">
          {headline.map((line, lineIdx) => (
            <span key={lineIdx} className="block text-hero">
              {line.split(' ').map((word, wordIdx) => (
                <motion.span
                  key={wordIdx}
                  className="inline-block mr-[0.25em] text-text-primary"
                  initial={{ opacity: 0, y: 16 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{
                    delay: 0.1 + (lineIdx * 4 + wordIdx) * 0.04,
                    duration: 0.5,
                    ease: easeOut,
                  }}
                >
                  {word}
                </motion.span>
              ))}
            </span>
          ))}
        </h1>

        {/* Sub-headline */}
        <motion.p
          className="text-text-secondary max-w-prose-tight mx-auto leading-relaxed mb-10"
          style={{ fontSize: '1.125rem' }}
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.45, duration: 0.5, ease: easeOut }}
        >
          DevTwin is a terminal-first AI coding agent that runs entirely on your machine.
          BYOK. Zero telemetry. You control how autonomous it gets.
        </motion.p>

        {/* CTA buttons */}
        <motion.div
          className="flex flex-col sm:flex-row items-center gap-3 mb-8"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.55, duration: 0.45, ease: easeOut }}
        >
          <Link
            href="/docs/getting-started"
            className="px-5 py-2.5 rounded-lg border border-accent text-accent text-sm font-medium hover:bg-accent-glow transition-colors"
          >
            Get started →
          </Link>
          <a
            href="https://github.com/devtwin/devtwin"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-2 px-5 py-2.5 rounded-lg border border-border-hover text-text-secondary text-sm font-medium hover:text-text-primary hover:border-border-hover transition-colors"
          >
            <GitHubIcon size={15} />
            View on GitHub
          </a>
        </motion.div>

        {/* Install strip */}
        <motion.div
          className="flex justify-center w-full"
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.65, duration: 0.45, ease: easeOut }}
        >
          <InstallStrip />
        </motion.div>
      </div>

      {/* Scroll indicator */}
      <motion.div
        className="absolute bottom-8 left-1/2 -translate-x-1/2 text-text-muted scroll-indicator"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1, duration: 0.5 }}
        aria-hidden="true"
      >
        <ChevronDown size={20} />
      </motion.div>
    </section>
  )
}

'use client'

import {
  motion,
  useInView,
  useScroll,
  useVelocity,
  useSpring,
  useTransform,
  useMotionValue,
  useAnimationFrame,
  useReducedMotion,
} from 'framer-motion'
import Image from 'next/image'
import { Download, Settings, Play, Check } from 'lucide-react'
import InstallStrip from './InstallStrip'

const steps = [
  {
    num: '01',
    icon: <Download size={14} />,
    title: 'Install CodeTwin',
    description: 'Copy this command, run it, then open a new terminal window.',
    code: 'curl -fsSL https://code-twin.vercel.app/install.sh | bash',
  },
  {
    num: '02',
    icon: <Settings size={14} />,
    title: 'Authenticate Provider',
    description: 'Run login, pick your provider, and paste your API key when asked.',
    code: 'codetwin providers login',
  },
  {
    num: '03',
    icon: <Play size={14} />,
    title: 'Start CodeTwin in Your Project',
    description: 'Go to your project folder, run this command, then type your task in plain English.',
    code: 'codetwin',
  },
]

import { useState, useEffect, Suspense, useRef } from 'react'

interface GitHubContributor {
  id: number
  login: string
  avatar_url: string
  html_url: string
  contributions: number
}

interface ContributorsApiResponse {
  contributors: GitHubContributor[]
  source: 'stats' | 'contributors' | 'fallback'
}

const easeOut = [0.16, 1, 0.3, 1] as const
const CONTRIBUTORS_REFRESH_INTERVAL_MS = 60_000
const MARQUEE_TEXT = 'Terminal First · Local First · Zero Telemetry · '
const MARQUEE_BASE_SPEED = 0.0012
const MARQUEE_BOOST_CAP = 0.08
const MARQUEE_BOOST_DIVISOR = 6000
const MARQUEE_BOOST_MULTIPLIER = 0.0032

export default function GettingStartedSection() {
  const [contributors, setContributors] = useState<GitHubContributor[]>([])
  const [lastSyncedAt, setLastSyncedAt] = useState<number | null>(null)

  const sectionRef = useRef<HTMLElement>(null);
  const isSectionInView = useInView(sectionRef, { margin: '-20% 0px -20% 0px' })
  const prefersReducedMotion = useReducedMotion()
  
  const { scrollY } = useScroll();
  const scrollVelocity = useVelocity(scrollY);
  const smoothVelocity = useSpring(scrollVelocity, { damping: 50, stiffness: 400 });
  const skewVelocity = useTransform(smoothVelocity, [-1000, 1000], [-8, 8]);
  const skewX = useTransform(skewVelocity, (v) => `${v}deg`);
  const marqueeX = useMotionValue(0)
  const marqueeXPercent = useTransform(marqueeX, (v) => `${v}%`)
  const speedBoost = useTransform(smoothVelocity, (v) => Math.min(MARQUEE_BOOST_CAP, Math.abs(v) / MARQUEE_BOOST_DIVISOR))

  useAnimationFrame((_, delta) => {
    if (!isSectionInView || prefersReducedMotion) {
      return
    }

    const deltaX = (MARQUEE_BASE_SPEED + speedBoost.get() * MARQUEE_BOOST_MULTIPLIER) * delta
    let next = marqueeX.get() - deltaX

    // Keep translation in a tight loop so the first phrase stays readable.
    if (next <= -50) {
      next += 50
    }

    marqueeX.set(next)
  })

  useEffect(() => {
    if (!isSectionInView) {
      return
    }

    let isMounted = true

    const fetchContributors = async () => {
      try {
        const response = await fetch(`/api/contributors?t=${Date.now()}`, { cache: 'no-store' })

        if (!response.ok) {
          return
        }

        const data = (await response.json()) as ContributorsApiResponse
        const topContributors = Array.isArray(data?.contributors) ? data.contributors : []

        if (isMounted && topContributors.length > 0) {
          setContributors(topContributors)
          setLastSyncedAt(Date.now())
        }
      } catch (err) {
        console.error('Failed to fetch contributors:', err)
      }
    }

    fetchContributors()
    const intervalId = window.setInterval(fetchContributors, CONTRIBUTORS_REFRESH_INTERVAL_MS)

    return () => {
      isMounted = false
      window.clearInterval(intervalId)
    }
  }, [isSectionInView])

  const syncedLabel = lastSyncedAt
    ? new Date(lastSyncedAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    : null

  return (
    <section ref={sectionRef} className="relative py-28 px-6 border-t border-border-default overflow-hidden">
      {/* Massive Background Marquee */}
      <motion.div 
        style={{ x: marqueeXPercent, skewX }}
        className="absolute top-1/2 -translate-y-1/2 flex whitespace-nowrap pointer-events-none opacity-5 mix-blend-plus-lighter z-0 left-0"
      >
        <span className="text-[160px] md:text-[220px] font-black tracking-tighter uppercase text-[#a6a6ed] pr-20">
          {MARQUEE_TEXT.repeat(4)}
        </span>
        <span
          aria-hidden="true"
          className="text-[160px] md:text-[220px] font-black tracking-tighter uppercase text-[#a6a6ed] pr-20"
        >
          {MARQUEE_TEXT.repeat(4)}
        </span>
      </motion.div>

      <div className="relative z-10 max-w-6xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, ease: easeOut }}
          className="mb-16"
        >
          <p className="text-xs text-[#a6a6ed] uppercase tracking-[0.2em] font-mono mb-3">
            Quick Start
          </p>
          <h2 className="text-3xl md:text-4xl font-semibold text-text-primary leading-tight mb-4">
            Up and Running in 60 Seconds
          </h2>
          <p className="text-sm text-text-secondary leading-relaxed max-w-lg">
            Follow these three simple steps in order. Copy, paste, run.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-stretch">
          {/* Left — steps */}
          <div className="flex flex-col gap-8">
            {steps.map((step, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, x: -16 }}
                whileInView={{ opacity: 1, x: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.45, delay: i * 0.1, ease: easeOut }}
                className="flex gap-5"
              >
                {/* Step indicator */}
                <div className="flex flex-col items-center gap-2 flex-shrink-0">
                  <div className="w-8 h-8 rounded-full border border-[#a6a6ed44] bg-[#a6a6ed0a] flex items-center justify-center text-[#a6a6ed]">
                    {step.icon}
                  </div>
                  {i < steps.length - 1 && (
                    <div className="flex-1 w-px bg-gradient-to-b from-[#a6a6ed22] to-transparent min-h-[40px]" />
                  )}
                </div>

                {/* Content */}
                <div className="pb-2">
                  <div className="flex items-center gap-2 mb-1">
                    <span className="text-[10px] font-mono text-text-muted">{step.num}</span>
                    <h3 className="text-sm font-semibold text-text-primary">{step.title}</h3>
                  </div>
                  <p className="text-xs text-text-muted leading-relaxed mb-3">
                    {step.description}
                  </p>
                  <code className="inline-block bg-surface-elevated border border-border-default rounded px-3 py-1.5 font-mono text-xs text-text-secondary">
                    {step.code}
                  </code>
                </div>
              </motion.div>
            ))}
          </div>

          {/* Right — install strip + contributors */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.2, ease: easeOut }}
            className="flex flex-col gap-8 h-full"
          >
            {/* Quick-copy install */}
            <div className="p-6 rounded-xl border border-border-default bg-surface-elevated flex-1 flex flex-col justify-center">
              <p className="text-xs text-text-muted font-mono uppercase tracking-widest mb-4">
                Quick Install
              </p>
              <Suspense fallback={<div className="h-12 bg-background rounded-lg border border-border-default animate-pulse" />}>
                <InstallStrip />
              </Suspense>

              {/* Checklist */}
              <ul className="mt-5 flex flex-col gap-2.5">
                {[
                  'Zero cloud dependency',
                  'Bring your own API key',
                  'Five autonomy levels',
                  'Local twin memory per project',
                ].map((item) => (
                  <li key={item} className="flex items-center gap-2.5 text-xs text-text-secondary">
                    <Check size={12} className="text-[#a6a6ed] flex-shrink-0" />
                    {item}
                  </li>
                ))}
              </ul>
            </div>

            {/* Contributors */}
            <div>
              <p className="text-xs text-text-muted font-mono uppercase tracking-widest mb-4">
                Open Source Contributors
              </p>
              <div className="flex flex-col gap-3">
                {contributors.map((person) => (
                  <a
                    key={person.id}
                    href={person.html_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-3 group"
                  >
                    <div className="w-9 h-9 rounded-full overflow-hidden flex-shrink-0 border border-border-default group-hover:border-[#a6a6ed] transition-colors">
                      <Image 
                        src={person.avatar_url} 
                        alt={`${person.login}'s avatar`}
                        width={36}
                        height={36}
                        className="w-full h-full object-cover transition-transform group-hover:scale-105"
                      />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-text-primary group-hover:text-[#a6a6ed] transition-colors">
                        {person.login}
                      </p>
                      <p className="text-xs text-text-muted">
                        {person.contributions} contribution{person.contributions === 1 ? '' : 's'}
                      </p>
                    </div>
                  </a>
                ))}
                {contributors.length === 0 && (
                  <div className="text-xs text-text-muted animate-pulse">Loading contributors...</div>
                )}
              </div>
              <p className="mt-3 text-[11px] text-text-muted/80 font-mono">
                {syncedLabel ? `Live sync ${syncedLabel}` : 'Live sync in progress...'}
              </p>
              <a
                href="https://github.com/Sahnik0/CodeTwin/graphs/contributors"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-block mt-4 text-xs text-[#a6a6ed] hover:underline font-mono"
              >
                View all contributors →
              </a>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}

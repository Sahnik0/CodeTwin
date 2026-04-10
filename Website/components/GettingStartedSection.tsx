'use client'

import { motion, useScroll, useVelocity, useSpring, useTransform } from 'framer-motion'
import { Download, Settings, Play, Check } from 'lucide-react'
import InstallStrip from './InstallStrip'

const steps = [
  {
    num: '01',
    icon: <Download size={14} />,
    title: 'Install CodeTwin',
    description: 'One command to install globally via npm or a shell script.',
    code: 'npm install -g CodeTwin',
  },
  {
    num: '02',
    icon: <Settings size={14} />,
    title: 'Configure Your Project',
    description: 'Run the interactive setup to choose your LLM provider and autonomy level.',
    code: 'cd your-project && CodeTwin config init',
  },
  {
    num: '03',
    icon: <Play size={14} />,
    title: 'Start Coding with Your Agent',
    description: 'Open the TUI and start issuing tasks in natural language.',
    code: 'CodeTwin start',
  },
]

import { useState, useEffect, Suspense } from 'react'

interface GitHubContributor {
  id: number
  login: string
  avatar_url: string
  html_url: string
  contributions: number
}

const easeOut = [0.16, 1, 0.3, 1] as const

export default function GettingStartedSection() {
  const [contributors, setContributors] = useState<GitHubContributor[]>([])

  const { scrollY } = useScroll();
  const baseX = useTransform(scrollY, [0, 5000], [100, -1500]);
  const scrollVelocity = useVelocity(scrollY);
  const smoothVelocity = useSpring(scrollVelocity, { damping: 50, stiffness: 400 });
  const skewVelocity = useTransform(smoothVelocity, [-1000, 1000], [-8, 8]);
  const skewX = useTransform(skewVelocity, (v) => `${v}deg`);

  useEffect(() => {
    fetch(`https://api.github.com/repos/Sahnik0/CodeTwin/contributors?per_page=5&t=${new Date().getTime()}`, { cache: 'no-store' })
      .then((res) => res.json())
      .then((data) => {
        if (Array.isArray(data)) setContributors(data)
      })
      .catch((err) => console.error('Failed to fetch contributors:', err))
  }, [])
  return (
    <section className="relative py-28 px-6 border-t border-border-default overflow-hidden">
      {/* Massive Background Marquee */}
      <motion.div 
        style={{ x: baseX, skewX }}
        className="absolute top-1/2 -translate-y-1/2 flex whitespace-nowrap pointer-events-none opacity-5 mix-blend-plus-lighter z-0"
      >
        <span className="text-[180px] md:text-[240px] font-black tracking-tighter uppercase text-[#a6a6ed]">
          Terminal First · Local First · Zero Telemetry · Terminal First · Local First · Zero Telemetry ·
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
            Three commands to your first agent-driven task. No browser tab, no Electron app — just your terminal.
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
                      <img 
                        src={person.avatar_url} 
                        alt={`${person.login}'s avatar`}
                        className="w-full h-full object-cover transition-transform group-hover:scale-105"
                      />
                    </div>
                    <div>
                      <p className="text-sm font-medium text-text-primary group-hover:text-[#a6a6ed] transition-colors">
                        {person.login}
                      </p>
                      <p className="text-xs text-text-muted">{person.contributions} contributions</p>
                    </div>
                  </a>
                ))}
                {contributors.length === 0 && (
                  <div className="text-xs text-text-muted animate-pulse">Loading contributors...</div>
                )}
              </div>
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

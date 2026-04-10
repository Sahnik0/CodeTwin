'use client'

import { Suspense } from 'react'
import { motion } from 'framer-motion'
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

const contributors = [
  { initials: 'SA', name: 'Sahnik0', role: 'Project Lead', color: '#2dd4bf', href: 'https://github.com/Sahnik0' },
  { initials: 'AB', name: 'Contributor', role: 'Core Developer', color: '#7c3aed', href: 'https://github.com/Sahnik0/CodeTwin' },
  { initials: 'CD', name: 'Contributor', role: 'Open Source', color: '#f59e0b', href: 'https://github.com/Sahnik0/CodeTwin' },
]

const easeOut = [0.16, 1, 0.3, 1] as const

export default function GettingStartedSection() {
  return (
    <section className="py-28 px-6 border-t border-border-default">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, ease: easeOut }}
          className="mb-16"
        >
          <p className="text-xs text-[#2dd4bf] uppercase tracking-[0.2em] font-mono mb-3">
            Quick Start
          </p>
          <h2 className="text-3xl md:text-4xl font-semibold text-text-primary leading-tight mb-4">
            Up and Running in 60 Seconds
          </h2>
          <p className="text-sm text-text-secondary leading-relaxed max-w-lg">
            Three commands to your first agent-driven task. No browser tab, no Electron app — just your terminal.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-16 items-start">
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
                  <div className="w-8 h-8 rounded-full border border-[#2dd4bf44] bg-[#2dd4bf0a] flex items-center justify-center text-[#2dd4bf]">
                    {step.icon}
                  </div>
                  {i < steps.length - 1 && (
                    <div className="flex-1 w-px bg-gradient-to-b from-[#2dd4bf22] to-transparent min-h-[40px]" />
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
            className="flex flex-col gap-8"
          >
            {/* Quick-copy install */}
            <div className="p-6 rounded-xl border border-border-default bg-surface-elevated">
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
                    <Check size={12} className="text-[#2dd4bf] flex-shrink-0" />
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
                {contributors.map((person, i) => (
                  <a
                    key={i}
                    href={person.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center gap-3 group"
                  >
                    <div
                      className="w-9 h-9 rounded-full flex items-center justify-center text-xs font-semibold flex-shrink-0 transition-transform group-hover:scale-105"
                      style={{
                        backgroundColor: person.color + '22',
                        border: `1.5px solid ${person.color}44`,
                        color: person.color,
                      }}
                    >
                      {person.initials}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-text-primary group-hover:text-[#2dd4bf] transition-colors">
                        {person.name}
                      </p>
                      <p className="text-xs text-text-muted">{person.role}</p>
                    </div>
                  </a>
                ))}
              </div>
              <a
                href="https://github.com/Sahnik0/CodeTwin/graphs/contributors"
                target="_blank"
                rel="noopener noreferrer"
                className="inline-block mt-4 text-xs text-[#2dd4bf] hover:underline font-mono"
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

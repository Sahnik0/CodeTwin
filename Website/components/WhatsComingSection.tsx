'use client'

import { motion } from 'framer-motion'
import { Clock, Layers, Users, Cpu } from 'lucide-react'

const upcomingFeatures = [
  {
    icon: <Layers size={16} />,
    title: 'Plugin System',
    description: 'First-class API for building custom tool integrations into your CodeTwin workflow.',
    status: 'In Design',
  },
  {
    icon: <Users size={16} />,
    title: 'Team-Shared Twin Memory',
    description: 'Share project context, decisions, and constraints across your entire engineering team.',
    status: 'Planned',
  },
  {
    icon: <Cpu size={16} />,
    title: 'Built-in Testing & CI/CD Agent',
    description: 'Let CodeTwin write, run, and fix tests as part of any task — then push to your pipeline.',
    status: 'Planned',
  },
  {
    icon: <Clock size={16} />,
    title: 'Multi-Model Orchestration',
    description: 'Route sub-tasks to the best model for the job — fast models for simple edits, powerful ones for complex refactors.',
    status: 'Exploring',
  },
]

const statusColors: Record<string, { bg: string; text: string; border: string }> = {
  'In Design': { bg: '#2dd4bf14', text: '#2dd4bf', border: '#2dd4bf30' },
  Planned: { bg: '#7c3aed14', text: '#a78bfa', border: '#7c3aed30' },
  Exploring: { bg: '#f59e0b14', text: '#fbbf24', border: '#f59e0b30' },
}

const easeOut = [0.16, 1, 0.3, 1] as const

export default function WhatsComingSection() {
  return (
    <section className="py-28 px-6 bg-surface border-t border-border-default">
      <div className="max-w-6xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, ease: easeOut }}
          className="mb-4"
        >
          <p className="text-xs text-[#2dd4bf] uppercase tracking-[0.2em] font-mono mb-3">
            Roadmap
          </p>
          <h2 className="text-3xl md:text-4xl font-semibold text-text-primary leading-tight mb-4">
            What&apos;s Coming Next
          </h2>
          <p className="text-sm text-text-secondary leading-relaxed max-w-lg">
            CodeTwin is actively developed in the open. Here&apos;s what we&apos;re building next — follow along on GitHub.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 items-start mt-14">
          {/* Left — feature cards */}
          <div className="flex flex-col gap-4">
            {upcomingFeatures.map((feature, i) => {
              const colors = statusColors[feature.status]
              return (
                <motion.div
                  key={i}
                  initial={{ opacity: 0, x: -16 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.4, delay: i * 0.08, ease: easeOut }}
                  className="group flex gap-4 p-4 rounded-lg border border-border-default bg-surface-elevated hover:border-border-hover transition-all duration-200"
                >
                  {/* Icon */}
                  <div className="flex-shrink-0 w-8 h-8 rounded border border-border-default bg-background flex items-center justify-center text-text-muted group-hover:text-[#2dd4bf] group-hover:border-[#2dd4bf33] transition-colors duration-200">
                    {feature.icon}
                  </div>

                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1 flex-wrap">
                      <span className="text-sm font-medium text-text-primary">
                        {feature.title}
                      </span>
                      <span
                        className="text-[10px] font-mono px-2 py-0.5 rounded-full border"
                        style={{
                          background: colors.bg,
                          color: colors.text,
                          borderColor: colors.border,
                        }}
                      >
                        {feature.status}
                      </span>
                    </div>
                    <p className="text-xs text-text-muted leading-relaxed">
                      {feature.description}
                    </p>
                  </div>
                </motion.div>
              )
            })}
          </div>

          {/* Right — image placeholder */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: 0.2, ease: easeOut }}
          >
            <div
              className="rounded-xl border border-border-default bg-surface-elevated overflow-hidden aspect-[4/3] flex flex-col items-center justify-center gap-2"
              style={{
                boxShadow: '0 0 0 1px rgba(255,255,255,0.03) inset',
              }}
            >
              <div className="w-8 h-8 rounded border border-border-default flex items-center justify-center opacity-30">
                <Clock size={14} className="text-text-muted" />
              </div>
              <span className="text-[11px] font-mono text-text-muted opacity-30 tracking-widest uppercase">
                Preview Coming Soon
              </span>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  )
}

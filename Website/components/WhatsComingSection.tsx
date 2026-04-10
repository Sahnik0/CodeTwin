'use client'

import { motion, useScroll, useVelocity, useSpring, useTransform } from 'framer-motion'
import { Clock, Layers, Users, Cpu } from 'lucide-react'
import SpotlightCard from './SpotlightCard'

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
  'In Design': { bg: '#a6a6ed14', text: '#a6a6ed', border: '#a6a6ed30' },
  Planned: { bg: '#7c3aed14', text: '#a78bfa', border: '#7c3aed30' },
  Exploring: { bg: '#f59e0b14', text: '#fbbf24', border: '#f59e0b30' },
}

const easeOut = [0.16, 1, 0.3, 1] as const

export default function WhatsComingSection() {
  const { scrollY } = useScroll();
  const scrollVelocity = useVelocity(scrollY);
  const smoothVelocity = useSpring(scrollVelocity, {
    damping: 50,
    stiffness: 400
  });
  const skewVelocity = useTransform(smoothVelocity, [-1000, 1000], [-2, 2]);
  const skewY = useTransform(skewVelocity, (v) => `${v}deg`);

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
          <p className="text-xs text-[#a6a6ed] uppercase tracking-[0.2em] font-mono mb-3">
            Roadmap
          </p>
          <h2 className="text-3xl md:text-4xl font-semibold text-text-primary leading-tight mb-4">
            What&apos;s Coming Next
          </h2>
          <p className="text-sm text-text-secondary leading-relaxed max-w-lg">
            CodeTwin is actively developed in the open. Here&apos;s what we&apos;re building next — follow along on GitHub.
          </p>
        </motion.div>

        <motion.div style={{ skewY }} className="grid grid-cols-1 lg:grid-cols-2 gap-12 lg:gap-20 items-stretch mt-14">
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
                >
                  <SpotlightCard
                    className="group flex flex-row gap-4 !p-4 !rounded-lg !border-border-default !bg-surface-elevated hover:!border-border-hover transition-all duration-200"
                    spotlightColor="rgba(166, 166, 237, 0.2)"
                  >
                    {/* Icon */}
                    <div className="flex-shrink-0 w-8 h-8 rounded border border-border-default bg-background flex items-center justify-center text-text-muted group-hover:text-[#a6a6ed] group-hover:border-[#a6a6ed33] transition-colors duration-200">
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
                  </SpotlightCard>
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
            className="flex flex-col h-full items-stretch"
          >
            <div
              className="rounded-xl border border-border-default bg-surface-elevated overflow-hidden flex flex-col flex-1 items-center justify-center gap-2"
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
        </motion.div>
      </div>
    </section>
  )
}

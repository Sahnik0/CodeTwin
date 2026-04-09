'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import CopyButton from './CopyButton'

const LEVELS = [
  {
    level: 1,
    name: 'Full supervision',
    description:
      'Ask before every file write, delete, or shell command. Nothing executes without your approval. Best for unfamiliar codebases.',
  },
  {
    level: 2,
    name: 'Reads are free',
    description:
      'Silent on reads and status checks. Always asks before writes, deletes, or installs. You see everything that changes.',
  },
  {
    level: 3,
    name: 'Smart checkpoints',
    description:
      'Executes clear single-path actions. Asks when multiple valid approaches exist. The balanced default.',
    isDefault: true,
  },
  {
    level: 4,
    name: 'Destructive only',
    description:
      'Runs freely until something gets deleted, overwritten, deployed, or pushed. Then it stops and asks.',
  },
  {
    level: 5,
    name: 'Full delegation',
    description:
      'Execute and report. Interrupts only if the delegation budget allows and complexity is critical. For trusted, well-constrained tasks.',
  },
]

const easeOut = [0.16, 1, 0.3, 1] as const

interface DependencePickerProps {
  defaultLevel?: number
}

export default function DependencePicker({ defaultLevel = 3 }: DependencePickerProps) {
  const [selected, setSelected] = useState(defaultLevel)
  const currentLevel = LEVELS.find((l) => l.level === selected) ?? LEVELS[2]

  return (
    <div className="w-full">
      {/* Level selector buttons */}
      <div className="flex items-center gap-3 mb-6">
        {LEVELS.map((l) => (
          <button
            key={l.level}
            onClick={() => setSelected(l.level)}
            aria-label={`Select level ${l.level}: ${l.name}`}
            aria-pressed={selected === l.level}
            className={`w-10 h-10 rounded-full border text-sm font-mono font-medium transition-all duration-200 focus-visible:outline-accent ${
              selected === l.level
                ? 'border-accent text-accent bg-accent-glow'
                : 'border-border-default text-text-muted hover:border-border-hover hover:text-text-secondary'
            }`}
          >
            {l.level}
          </button>
        ))}
      </div>

      {/* Description panel */}
      <AnimatePresence mode="wait">
        <motion.div
          key={selected}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -8 }}
          transition={{ duration: 0.22, ease: easeOut }}
          className="bg-surface-elevated border border-border-default rounded-lg p-5"
        >
          <div className="flex items-start justify-between gap-4 mb-2">
            <div>
              <span className="text-xs font-mono text-text-muted uppercase tracking-widest">
                Level {currentLevel.level}
              </span>
              <h3 className="text-base font-medium text-text-primary mt-0.5">
                {currentLevel.name}
              </h3>
            </div>
            {currentLevel.isDefault && (
              <span className="flex-shrink-0 text-xs px-2 py-0.5 rounded border border-accent/40 text-accent bg-accent-glow font-mono">
                default
              </span>
            )}
          </div>
          <p className="text-sm text-text-secondary leading-relaxed">
            {currentLevel.description}
          </p>
        </motion.div>
      </AnimatePresence>

      {/* CLI shortcut */}
      <div className="mt-4 flex items-center gap-3">
        <code className="font-mono text-sm text-text-secondary">
          devtwin level {selected}
        </code>
        <CopyButton text={`devtwin level ${selected}`} label={`Copy devtwin level ${selected} command`} />
      </div>
    </div>
  )
}

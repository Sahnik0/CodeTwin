'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Plus, Minus } from 'lucide-react'

const faqs = [
  {
    question: 'What is CodeTwin and how does it work?',
    answer:
      'CodeTwin is a terminal-first AI coding agent that runs entirely on your machine. It accepts natural language tasks, builds a pre-flight impact map showing exactly what will change, and only executes after your approval. Five autonomy levels let you decide how much independence the agent has at any point.',
  },
  {
    question: 'Is my code ever sent to an external server?',
    answer:
      'No. CodeTwin runs locally on your machine and your code never leaves your system. The only outbound calls are to your chosen LLM provider (OpenAI, Anthropic, Groq, etc.) using your own API key. Zero telemetry, zero data collection — ever.',
  },
  {
    question: 'Which LLM providers does CodeTwin support?',
    answer:
      'CodeTwin works with OpenAI, Anthropic, Groq, Google Gemini, Mistral, Cohere, Ollama (local models), and Azure OpenAI out of the box. You bring your own API key and switch providers with a single config change — no code changes needed.',
  },
  {
    question: 'What are dependence levels and why do they matter?',
    answer:
      'Dependence levels control how autonomous the agent is during a session. Level 1 asks before every action, Level 3 (the default) pauses when multiple valid approaches exist, and Level 5 executes end-to-end then reports back. You can change the level mid-task to match your comfort level with a given change.',
  },
  {
    question: 'Can I use CodeTwin with my existing projects?',
    answer:
      'Yes — CodeTwin is language- and framework-agnostic. Run `CodeTwin config init` inside any project directory, set your preferred LLM provider and autonomy level, and start issuing tasks. The twin memory system learns your project\'s patterns, constraints, and past decisions over time.',
  },
  {
    question: 'How is twin memory stored and is it private?',
    answer:
      'Twin memory is stored locally in a SQLite database inside your project directory. It is never synced to any remote server. Each project maintains its own isolated memory — decisions, constraints, and failure patterns stay on your machine.',
  },
]

const easeOut = [0.16, 1, 0.3, 1] as const

export default function FAQSection() {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  return (
    <section className="py-28 px-6 border-t border-border-default">
      <div className="max-w-3xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, ease: easeOut }}
          className="mb-4"
        >
          <p className="text-xs text-[#2dd4bf] uppercase tracking-[0.2em] font-mono mb-3">
            Support
          </p>
          <h2 className="text-3xl md:text-4xl font-semibold text-text-primary leading-tight">
            Frequently Asked Questions
          </h2>
        </motion.div>

        <motion.p
          initial={{ opacity: 0, y: 10 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.5, delay: 0.1, ease: easeOut }}
          className="text-sm text-text-secondary leading-relaxed mb-14"
        >
          Everything you need to know about CodeTwin. Can&apos;t find your answer?{' '}
          <a
            href="https://github.com/Sahnik0/CodeTwin/issues"
            target="_blank"
            rel="noopener noreferrer"
            className="text-[#2dd4bf] hover:underline"
          >
            Open an issue on GitHub
          </a>
          .
        </motion.p>

        {/* FAQ accordion */}
        <div className="flex flex-col">
          {faqs.map((faq, i) => {
            const isOpen = openIndex === i
            return (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 10 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.4, delay: i * 0.06, ease: easeOut }}
              >
                <div className="border-t border-border-default">
                  <button
                    onClick={() => setOpenIndex(isOpen ? null : i)}
                    className="w-full flex items-center justify-between py-5 text-left group"
                    aria-expanded={isOpen}
                    id={`faq-btn-${i}`}
                    aria-controls={`faq-panel-${i}`}
                  >
                    <span
                      className={`text-sm font-medium pr-6 transition-colors duration-200 ${isOpen ? 'text-[#2dd4bf]' : 'text-text-primary group-hover:text-[#2dd4bf]'
                        }`}
                    >
                      {faq.question}
                    </span>

                    <span
                      className={`flex-shrink-0 w-6 h-6 rounded-full border flex items-center justify-center transition-all duration-300 ${isOpen
                        ? 'border-[#2dd4bf] bg-[#2dd4bf14] text-[#2dd4bf]'
                        : 'border-border-default text-text-muted group-hover:border-border-hover'
                        }`}
                    >
                      {isOpen ? <Minus size={12} /> : <Plus size={12} />}
                    </span>
                  </button>

                  <AnimatePresence initial={false}>
                    {isOpen && (
                      <motion.div
                        id={`faq-panel-${i}`}
                        role="region"
                        aria-labelledby={`faq-btn-${i}`}
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        transition={{ duration: 0.28, ease: easeOut }}
                        className="overflow-hidden"
                      >
                        <p className="text-sm text-text-secondary leading-relaxed pb-6 pr-10">
                          {faq.answer}
                        </p>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </div>
              </motion.div>
            )
          })}
          <div className="border-t border-border-default" />
        </div>
      </div>
    </section>
  )
}

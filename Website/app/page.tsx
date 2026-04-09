import { Suspense } from 'react'
import Link from 'next/link'
import {
  Terminal as TerminalIcon,
  Sliders,
  Brain,
  Key,
  Map,
  Smartphone,
  Check,
} from 'lucide-react'

import Terminal from '@/components/Terminal'
import DependencePicker from '@/components/DependencePicker'
import ProviderCard from '@/components/ProviderCard'
import PhoneFrame from '@/components/PhoneFrame'
import PreflightCard from '@/components/PreflightCard'
import TwinMemory from '@/components/TwinMemory'
import CodeBlock from '@/components/CodeBlock'
import HeroSection from '@/components/HeroSection'
import { terminalDemoLines } from '@/lib/terminal-lines'

/* ──────────────────────────────────────────────
   Feature cards data
────────────────────────────────────────────── */
const features = [
  {
    icon: <TerminalIcon size={20} className="text-accent" />,
    title: 'Terminal-first',
    desc: 'Runs in your terminal. No browser tab, no Electron app. A React Ink TUI that feels like a native tool.',
  },
  {
    icon: <Sliders size={20} className="text-accent" />,
    title: 'You set the autonomy',
    desc: 'Five dependence levels. From "ask before every keystroke" to "execute and report". Change it mid-task.',
  },
  {
    icon: <Brain size={20} className="text-accent" />,
    title: 'Twin memory',
    desc: 'Remembers decisions, constraints, and failure patterns per project. Builds context that survives session restarts.',
  },
  {
    icon: <Key size={20} className="text-accent" />,
    title: 'BYOK — any provider',
    desc: 'OpenAI, Anthropic, Groq, Gemini, Mistral, Ollama, Azure. One config. Zero code changes.',
  },
  {
    icon: <Map size={20} className="text-accent" />,
    title: 'Pre-flight maps',
    desc: 'Before any destructive action, see exactly what will change. Approve, reject, or redirect the agent.',
  },
  {
    icon: <Smartphone size={20} className="text-accent" />,
    title: 'Remote from mobile',
    desc: 'Control a running agent from your phone over an end-to-end encrypted relay. Watch logs. Approve preflights.',
  },
]

/* ──────────────────────────────────────────────
   Provider cards data
────────────────────────────────────────────── */
const providers = [
  { name: 'OpenAI', model: 'gpt-4o', abbr: 'OA', color: '#10a37f' },
  { name: 'Anthropic', model: 'claude-opus-4-5', abbr: 'AN', color: '#d4a27f' },
  { name: 'Groq', model: 'llama-3.3-70b-versatile', abbr: 'GR', color: '#f55036', badge: 'Fast' },
  { name: 'Google Gemini', model: 'gemini-2.0-flash', abbr: 'GG', color: '#4285f4' },
  { name: 'Mistral', model: 'mistral-large-latest', abbr: 'MI', color: '#ff7000' },
  { name: 'Cohere', model: 'command-r-plus', abbr: 'CO', color: '#39594d' },
  { name: 'Ollama', model: 'llama3.2, phi4', abbr: 'OL', color: '#888888', badge: 'Local' },
  { name: 'Azure OpenAI', model: 'gpt-4o (your deployment)', abbr: 'AZ', color: '#0078d4', badge: 'Enterprise' },
]

const configSnippet = `{
  "llmProvider": "groq",
  "model": "llama-3.3-70b-versatile",
  "apiKey": "****"
}`

const installCmd1 = `curl -fsSL https://devtwin.dev/install.sh | bash
# or
npm install -g devtwin`

const initCmd = `cd your-project
devtwin config init
# Follow the prompts: provider, model, API key, dependence level`

const startCmd = `devtwin start
# Opens the TUI. Start talking to your codebase.`

/* ──────────────────────────────────────────────
   Page
────────────────────────────────────────────── */
export default function HomePage() {
  return (
    <>
      {/* ── Section 1: Hero ── */}
      <HeroSection />

      {/* ── Section 2: Core Principles ── */}
      <section className="py-24 px-6 border-t border-border-default">
        <div className="max-w-6xl mx-auto">
          <p className="text-xs text-text-muted uppercase tracking-[0.2em] font-mono mb-10 text-center">
            Core Principles
          </p>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            {features.map((f, i) => (
              <div
                key={i}
                className="group flex flex-col gap-3 p-5 bg-surface-elevated border border-border-default rounded-lg hover:border-border-hover transition-colors duration-200"
              >
                <div>{f.icon}</div>
                <h3 className="text-sm font-medium text-text-primary">{f.title}</h3>
                <p className="text-sm text-text-secondary leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ── Section 3: Terminal Demo ── */}
      <section className="py-24 px-6 bg-surface border-t border-border-default">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-14 items-start">
            {/* Left */}
            <div>
              <p className="text-xs text-text-muted uppercase tracking-[0.2em] font-mono mb-4">
                How it works
              </p>
              <h2 className="text-2xl font-medium text-text-primary mb-6 leading-snug">
                Give it a task. It shows its plan. You decide.
              </h2>
              <div className="flex flex-col gap-4 text-sm text-text-secondary leading-relaxed">
                <p>
                  DevTwin builds a pre-flight impact map before touching any file. See exactly
                  which files get written, which shell commands run, and which functions get
                  affected.
                </p>
                <p>
                  At dependence level 3, it asks when multiple approaches exist. At level 1,
                  it asks before every write. You choose.
                </p>
                <p>
                  Every significant decision gets recorded to the twin memory. Future sessions
                  know why you chose JWT over sessions, or why lodash is banned in this project.
                </p>
              </div>
            </div>

            {/* Right — Terminal */}
            <div className="w-full">
              <Terminal
                lines={terminalDemoLines}
                title="devtwin — myapp"
                animateIn
              />
            </div>
          </div>
        </div>
      </section>

      {/* ── Section 4: Dependence Levels ── */}
      <section className="py-24 px-6 border-t border-border-default">
        <div className="max-w-3xl mx-auto">
          <p className="text-xs text-text-muted uppercase tracking-[0.2em] font-mono mb-4 text-center">
            Autonomy on your terms
          </p>
          <h2 className="text-2xl font-medium text-text-primary mb-10 text-center">
            Five levels. You choose when to intervene.
          </h2>
          <DependencePicker defaultLevel={3} />
        </div>
      </section>

      {/* ── Section 5: Provider Grid ── */}
      <section className="py-24 px-6 bg-surface border-t border-border-default">
        <div className="max-w-6xl mx-auto">
          <div className="text-center mb-10">
            <p className="text-xs text-text-muted uppercase tracking-[0.2em] font-mono mb-3">
              Bring your own key
            </p>
            <h2 className="text-2xl font-medium text-text-primary">
              Works with every major LLM provider.
            </h2>
            <p className="text-sm text-text-secondary mt-2">
              One config field. No vendor lock-in.
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-8">
            {providers.map((p) => (
              <ProviderCard
                key={p.name}
                name={p.name}
                model={p.model}
                badge={p.badge}
                abbr={p.abbr}
                color={p.color}
              />
            ))}
          </div>

          <div className="max-w-md mx-auto">
            <Suspense fallback={<div className="h-24 bg-surface-elevated rounded-lg border border-border-default animate-pulse" />}>
              <CodeBlock code={configSnippet} language="json" showCopy />
            </Suspense>
          </div>
        </div>
      </section>

      {/* ── Section 6: Twin Memory ── */}
      <section className="py-24 px-6 border-t border-border-default">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-14 items-start">
            {/* Left */}
            <div>
              <p className="text-xs text-text-muted uppercase tracking-[0.2em] font-mono mb-4">
                The agent that remembers
              </p>
              <h2 className="text-2xl font-medium text-text-primary mb-4">
                Project memory. Stored locally.
              </h2>
              <p className="text-sm text-text-secondary leading-relaxed mb-6">
                DevTwin maintains a twin profile per project — stored locally in SQLite, never
                sent anywhere.
              </p>
              <ul className="flex flex-col gap-3">
                {[
                  'Past decisions and why they were made',
                  'Active constraints (no lodash, use pnpm, no `any` types)',
                  'Failure patterns — what broke and in what context',
                ].map((item) => (
                  <li key={item} className="flex items-start gap-2.5 text-sm text-text-secondary">
                    <Check size={14} className="text-success flex-shrink-0 mt-0.5" />
                    {item}
                  </li>
                ))}
              </ul>
            </div>

            {/* Right */}
            <div>
              <TwinMemory />
            </div>
          </div>
        </div>
      </section>

      {/* ── Section 7: Remote Control ── */}
      <section className="py-24 px-6 bg-surface border-t border-border-default">
        <div className="max-w-6xl mx-auto">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-14 items-center">
            {/* Left — Phone mockup */}
            <div className="flex justify-center">
              <PhoneFrame>
                {/* Phone app UI */}
                <div className="px-3 pt-2 pb-1 flex items-center border-b border-border-default">
                  <span className="text-[11px] font-medium text-text-primary">DevTwin · myapp</span>
                  <span className="ml-auto w-2 h-2 rounded-full bg-success" />
                </div>

                {/* Log stream */}
                <div className="flex-1 overflow-auto px-3 py-2 flex flex-col gap-1">
                  {[
                    { text: '● analyzing codebase...', color: '#888' },
                    { text: '● building pre-flight map', color: '#888' },
                    { text: '✓ plan ready', color: '#22c55e' },
                  ].map((line, i) => (
                    <div key={i} className="text-[10px] font-mono" style={{ color: line.color }}>
                      {line.text}
                    </div>
                  ))}
                </div>

                {/* Preflight card */}
                <PreflightCard
                  task='Refactor auth module to use JWT'
                  blastRadius='HIGH'
                />

                {/* Input */}
                <div className="px-3 py-2 border-t border-border-default">
                  <div className="flex items-center gap-2 bg-surface border border-border-default rounded px-2 py-1">
                    <span className="text-[10px] text-text-muted flex-1">Send a message...</span>
                  </div>
                </div>
              </PhoneFrame>
            </div>

            {/* Right */}
            <div>
              <p className="text-xs text-text-muted uppercase tracking-[0.2em] font-mono mb-4">
                Control it from your phone
              </p>
              <h2 className="text-2xl font-medium text-text-primary mb-4">
                Start at your desk. Approve from anywhere.
              </h2>
              <p className="text-sm text-text-secondary leading-relaxed mb-6">
                Start a task from your desk. Approve pre-flight maps from your phone. The relay
                never stores your code.
              </p>
              <ul className="flex flex-col gap-3">
                {[
                  'Submit tasks remotely',
                  'Approve or reject pre-flight maps',
                  'Watch the agent log stream live',
                  'Change dependence level mid-task',
                  'Works over any network',
                ].map((item) => (
                  <li key={item} className="flex items-start gap-2.5 text-sm text-text-secondary">
                    <Check size={14} className="text-success flex-shrink-0 mt-0.5" />
                    {item}
                  </li>
                ))}
              </ul>
              <div className="mt-8 inline-flex items-center gap-3 bg-surface-elevated border border-border-default rounded-lg px-4 py-3">
                <code className="font-mono text-sm text-text-primary">devtwin connect</code>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* ── Section 8: Get Started ── */}
      <section className="py-24 px-6 border-t border-border-default">
        <div className="max-w-3xl mx-auto">
          <p className="text-xs text-text-muted uppercase tracking-[0.2em] font-mono mb-4 text-center">
            Get started in 60 seconds
          </p>
          <h2 className="text-2xl font-medium text-text-primary mb-14 text-center">
            Three commands to your first task.
          </h2>

          <div className="flex flex-col gap-10">
            {[
              { num: '01', label: 'Install', code: installCmd1, lang: 'bash' },
              { num: '02', label: 'Initialize', code: initCmd, lang: 'bash' },
              { num: '03', label: 'Start', code: startCmd, lang: 'bash' },
            ].map((step) => (
              <div key={step.num} className="flex gap-6 items-start">
                <span className="font-mono text-3xl text-text-muted flex-shrink-0 leading-none mt-1">
                  {step.num}
                </span>
                <div className="flex-1">
                  <h3 className="text-sm font-medium text-text-primary mb-3">{step.label}</h3>
                  <Suspense fallback={<div className="h-16 bg-surface-elevated rounded-lg border border-border-default animate-pulse" />}>
                    <CodeBlock code={step.code} language={step.lang} showCopy />
                  </Suspense>
                </div>
              </div>
            ))}
          </div>

          {/* Quick links */}
          <div className="mt-12 flex flex-wrap gap-4 justify-center">
            {[
              { label: 'Documentation →', href: '/docs/getting-started' },
              { label: 'CLI reference →', href: '/docs/cli-reference' },
              { label: 'Provider setup →', href: '/docs/providers' },
            ].map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className="text-sm text-text-secondary hover:text-text-primary border border-border-default hover:border-border-hover rounded-lg px-4 py-2 transition-colors"
              >
                {link.label}
              </Link>
            ))}
          </div>
        </div>
      </section>
    </>
  )
}

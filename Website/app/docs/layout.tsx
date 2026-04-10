import Link from 'next/link'
import type { ReactNode } from 'react'

const navItems = [
  {
    group: 'Getting started',
    items: [
      { label: 'Installation', slug: 'getting-started' },
      { label: 'Init wizard', slug: 'getting-started#init-wizard' },
      { label: 'First task', slug: 'getting-started#first-task' },
    ],
  },
  {
    group: 'Core concepts',
    items: [
      { label: 'Dependence levels', slug: 'dependence-levels' },
      { label: 'Pre-flight maps', slug: 'twin-memory#pre-flight' },
      { label: 'Twin memory', slug: 'twin-memory' },
    ],
  },
  {
    group: 'Providers',
    items: [
      { label: 'OpenAI', slug: 'providers#openai' },
      { label: 'Anthropic', slug: 'providers#anthropic' },
      { label: 'Groq', slug: 'providers#groq' },
      { label: 'Google Gemini', slug: 'providers#gemini' },
      { label: 'Ollama (local)', slug: 'providers#ollama' },
      { label: 'Azure', slug: 'providers#azure' },
      { label: 'All others', slug: 'providers#others' },
    ],
  },
  {
    group: 'Tools',
    items: [
      { label: 'Overview', slug: 'tools' },
      { label: 'read / write / edit', slug: 'tools#read-write-edit' },
      { label: 'bash', slug: 'tools#bash' },
      { label: 'git', slug: 'tools#git' },
    ],
  },
  {
    group: 'Remote control',
    items: [
      { label: 'Setup', slug: 'remote-control' },
      { label: 'Mobile pairing', slug: 'remote-control#pairing' },
      { label: 'Relay server', slug: 'remote-control#relay' },
    ],
  },
  {
    group: 'CLI reference',
    items: [{ label: 'All commands', slug: 'cli-reference' }],
  },
]

interface DocsLayoutProps {
  children: ReactNode
}

export default function DocsLayout({ children }: DocsLayoutProps) {
  return (
    <div className="min-h-screen pt-14">
      <div className="max-w-7xl mx-auto flex">
        {/* Sidebar */}
        <nav
          className="hidden lg:block w-60 flex-shrink-0 border-r border-border-default top-14 self-start sticky h-[calc(100vh-3.5rem)] overflow-y-auto py-8 px-4"
          aria-label="Documentation navigation"
        >
          {navItems.map((section) => (
            <div key={section.group} className="mb-6">
              <p className="text-xs text-text-muted uppercase tracking-widest font-mono mb-2 px-2">
                {section.group}
              </p>
              <ul className="flex flex-col gap-0.5">
                {section.items.map((item) => (
                  <li key={item.slug}>
                    <Link
                      href={`/docs/${item.slug}`}
                      className="block px-2 py-1.5 text-sm text-text-secondary hover:text-text-primary hover:bg-surface rounded transition-colors"
                    >
                      {item.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </nav>

        {/* Content */}
        <article className="flex-1 min-w-0 px-6 lg:px-12 py-12 prose-sm max-w-3xl">
          {children}

          {/* Edit on GitHub footer */}
          <div className="mt-16 pt-8 border-t border-border-default">
            <a
              href="https://github.com/CodeTwin/CodeTwin/tree/main/docs"
              target="_blank"
              rel="noopener noreferrer"
              className="text-xs text-text-muted hover:text-text-secondary transition-colors"
            >
              Edit this page on GitHub →
            </a>
          </div>
        </article>
      </div>
    </div>
  )
}

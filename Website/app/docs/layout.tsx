import Link from 'next/link'
import type { ReactNode } from 'react'

const navItems = [
  {
    group: 'Getting started',
    items: [
      { label: 'Installation', slug: 'getting-started' },
    ],
  },
  {
    group: 'Core concepts',
    items: [
      { label: 'Dependence levels', slug: 'dependence-levels' },
      { label: 'Twin memory', slug: 'twin-memory' },
    ],
  },
  {
    group: 'Providers',
    items: [
      { label: 'Setup & API Keys', slug: 'providers' },
    ],
  },
  {
    group: 'Tools',
    items: [
      { label: 'Overview', slug: 'tools' },
    ],
  },
  {
    group: 'Remote control',
    items: [
      { label: 'Setup', slug: 'remote-control' },
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
    <div className="min-h-screen pt-[4.5rem]">
      <div className="max-w-7xl mx-auto flex items-start">
        {/* Sidebar */}
        <nav
          className="hidden lg:block w-72 flex-shrink-0 sticky top-[4.5rem] py-10 pr-6"
          aria-label="Documentation navigation"
        >
          {navItems.map((section) => (
            <div key={section.group} className="mb-8">
              <p className="text-[12px] text-text-primary font-bold tracking-tight mb-3">
                {section.group}
              </p>
              <ul className="flex flex-col border-l border-border-default ml-1">
                {section.items.map((item) => (
                  <li key={item.slug}>
                    <Link
                      href={`/docs/${item.slug}`}
                      className="block pl-4 py-1.5 text-[14px] font-medium text-text-muted hover:text-text-primary transition-colors border-l-2 border-transparent hover:border-[#a6a6ed] -ml-px"
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
        <article className="flex-1 min-w-0 px-6 lg:px-16 py-12 prose-sm max-w-[850px] border-l border-border-default min-h-[calc(100vh-4.5rem)]">
          {children}

          {/* Edit on GitHub footer */}
          <div className="mt-20 pt-10 border-t border-border-default">
            <a
              href="https://github.com/Sahnik0/CodeTwin/tree/main/content/docs"
              target="_blank"
              rel="noopener noreferrer"
              className="text-sm font-medium text-[#a6a6ed]/80 hover:text-[#a6a6ed] transition-colors"
            >
              Edit this page on GitHub →
            </a>
          </div>
        </article>
      </div>
    </div>
  )
}

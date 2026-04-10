'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { Menu, X } from 'lucide-react'
import GitHubIcon from './GitHubIcon'

export default function NavBar() {
  const [scrolled, setScrolled] = useState(false)
  const [open, setOpen] = useState(false)

  useEffect(() => {
    const handler = () => setScrolled(window.scrollY > 20)
    window.addEventListener('scroll', handler, { passive: true })
    return () => window.removeEventListener('scroll', handler)
  }, [])

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${scrolled
        ? 'bg-background/90 backdrop-blur-md border-b border-border-default'
        : 'bg-transparent'
        }`}
    >
      <div className="max-w-6xl mx-auto px-6 h-14 flex items-center justify-between">
        {/* Wordmark */}
        <div className="hidden md:flex flex-1">
          <Link
            href="/"
            className="font-mono text-sm font-medium text-text-primary tracking-tight hover:text-[#a6a6ed] transition-colors"
          >
            Code<span className="text-[#a6a6ed]">Twin</span>
          </Link>
        </div>
        <div className="md:hidden">
          <Link
            href="/"
            className="font-mono text-sm font-medium text-text-primary tracking-tight hover:text-[#a6a6ed] transition-colors"
          >
            Code<span className="text-[#a6a6ed]">Twin</span>
          </Link>
        </div>

        {/* Desktop nav — center */}
        <nav className="hidden md:flex items-center gap-6 text-sm">
          <Link
            href="/docs/getting-started"
            className="text-text-secondary hover:text-text-primary transition-colors"
          >
            Docs
          </Link>
          <Link
            href="/changelog"
            className="text-text-secondary hover:text-text-primary transition-colors"
          >
            Changelog
          </Link>
          <Link
            href="/connect"
            className="text-text-secondary hover:text-text-primary transition-colors"
          >
            Connect
          </Link>
          <a
            href="https://github.com/Sahnik0/CodeTwin"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="View CodeTwin on GitHub"
            className="flex items-center gap-1.5 text-text-secondary hover:text-text-primary transition-colors"
          >
            <GitHubIcon size={15} />
            GitHub
          </a>
        </nav>

        {/* Desktop nav — right section */}
        <div className="hidden md:flex flex-1 justify-end items-center gap-4">
          <Link
            href="/docs/getting-started"
            className="text-xs text-[#060010] bg-[#a6a6ed] hover:bg-[#9494e0] transition-colors h-8 px-4 flex items-center justify-center rounded font-semibold uppercase tracking-wider"
          >
            Get Started
          </Link>
        </div>

        {/* Mobile menu toggle */}
        <button
          className="md:hidden text-text-secondary hover:text-text-primary transition-colors p-1"
          onClick={() => setOpen((v) => !v)}
          aria-label={open ? 'Close menu' : 'Open menu'}
        >
          {open ? <X size={18} /> : <Menu size={18} />}
        </button>
      </div>

      {/* Mobile menu */}
      {open && (
        <nav className="md:hidden bg-surface border-b border-border-default px-6 pb-4 flex flex-col gap-4 text-sm">
          <Link
            href="/docs/getting-started"
            className="text-text-secondary hover:text-text-primary transition-colors"
            onClick={() => setOpen(false)}
          >
            Docs
          </Link>
          <Link
            href="/changelog"
            className="text-text-secondary hover:text-text-primary transition-colors"
            onClick={() => setOpen(false)}
          >
            Changelog
          </Link>
          <Link
            href="/connect"
            className="text-text-secondary hover:text-text-primary transition-colors"
            onClick={() => setOpen(false)}
          >
            Connect
          </Link>
          <a
            href="https://github.com/Sahnik0/CodeTwin"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1.5 text-text-secondary hover:text-text-primary transition-colors"
            onClick={() => setOpen(false)}
          >
            <GitHubIcon size={15} />
            GitHub
          </a>

        </nav>
      )}
    </header>
  )
}

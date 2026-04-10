import Link from 'next/link'
import GitHubIcon from './GitHubIcon'
import CircuitPattern from './CircuitPattern'

export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="relative border-t border-border-default bg-background overflow-hidden">
      {/* Faint circuit decoration */}
      <CircuitPattern variant="bottom-right" className="opacity-15" />

      <div className="relative z-10 max-w-6xl mx-auto px-6 pt-12 pb-8">
        {/* Main footer row */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-10 mb-10">
          {/* Brand */}
          <div>
            <span className="font-mono text-sm font-semibold text-text-primary block mb-2">
              CodeTwin
            </span>
            <p className="text-xs text-text-muted leading-relaxed max-w-[200px]">
              A terminal-first AI coding agent. Built for developers who want control.
            </p>
          </div>

          {/* Product links */}
          <div>
            <p className="text-xs text-text-muted uppercase tracking-widest font-mono mb-4">
              Product
            </p>
            <ul className="flex flex-col gap-2.5">
              {[
                { label: 'Documentation', href: '/docs/getting-started' },
                { label: 'Changelog', href: '/changelog' },
                { label: 'CLI Reference', href: '/docs/cli-reference' },
                { label: 'Provider Setup', href: '/docs/providers' },
              ].map((link) => (
                <li key={link.href}>
                  <Link
                    href={link.href}
                    className="text-sm text-text-secondary hover:text-text-primary transition-colors"
                  >
                    {link.label}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Community / GitHub */}
          <div>
            <p className="text-xs text-text-muted uppercase tracking-widest font-mono mb-4">
              Open Source
            </p>
            <ul className="flex flex-col gap-2.5">
              {[
                {
                  label: 'GitHub Repository',
                  href: 'https://github.com/Sahnik0/CodeTwin',
                  external: true,
                },
                {
                  label: 'Issues & Bug Reports',
                  href: 'https://github.com/Sahnik0/CodeTwin/issues',
                  external: true,
                },
                {
                  label: 'Contributors',
                  href: 'https://github.com/Sahnik0/CodeTwin/graphs/contributors',
                  external: true,
                },
                { label: 'Connect', href: '/connect', external: false },
              ].map((link) => (
                <li key={link.href}>
                  {link.external ? (
                    <a
                      href={link.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-sm text-text-secondary hover:text-text-primary transition-colors inline-flex items-center gap-1"
                    >
                      {link.label}
                    </a>
                  ) : (
                    <Link
                      href={link.href}
                      className="text-sm text-text-secondary hover:text-text-primary transition-colors"
                    >
                      {link.label}
                    </Link>
                  )}
                </li>
              ))}
            </ul>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="pt-6 border-t border-border-default flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <p className="text-xs text-text-muted">
            © {currentYear} CodeTwin · MIT License · Zero Telemetry
          </p>

          <a
            href="https://github.com/Sahnik0/CodeTwin"
            target="_blank"
            rel="noopener noreferrer"
            className="flex items-center gap-1.5 text-xs text-text-muted hover:text-text-secondary transition-colors"
          >
            <GitHubIcon size={13} />
            Sahnik0/CodeTwin
          </a>
        </div>
      </div>
    </footer>
  )
}

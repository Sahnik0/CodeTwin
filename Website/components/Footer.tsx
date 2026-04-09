import Link from 'next/link'
import GitHubIcon from './GitHubIcon'

export default function Footer() {
  return (
    <footer className="border-t border-border-default bg-background">
      <div className="max-w-6xl mx-auto px-6 py-10">
        <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
          {/* Left */}
          <div className="flex flex-col gap-1">
            <span className="font-mono text-sm text-text-primary">devtwin</span>
            <span className="text-xs text-text-muted">
              Built for developers who want control.
            </span>
          </div>

          {/* Right links */}
          <div className="flex items-center gap-6 text-sm">
            <a
              href="https://github.com/devtwin/devtwin"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-1.5 text-text-secondary hover:text-text-primary transition-colors"
            >
              <GitHubIcon size={14} />
              GitHub
            </a>
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
          </div>
        </div>

        {/* Bottom row */}
        <div className="mt-8 pt-6 border-t border-border-default">
          <p className="text-xs text-text-muted">
            MIT License · Zero telemetry · Runs on your machine
          </p>
        </div>
      </div>
    </footer>
  )
}

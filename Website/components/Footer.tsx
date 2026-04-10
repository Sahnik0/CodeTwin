import Link from 'next/link'
import { Bug, Mail, Users } from 'lucide-react'
import GitHubIcon from './GitHubIcon'

type SocialIcon = 'github' | 'bug' | 'users' | 'mail'

type SocialLink = {
  label: string
  href: string
  external: boolean
  icon: SocialIcon
}

const socialLinks: SocialLink[] = [
  {
    label: 'GitHub Repository',
    href: 'https://github.com/Sahnik0/CodeTwin',
    icon: 'github',
    external: true,
  },
  {
    label: 'Issues & Bug Reports',
    href: 'https://github.com/Sahnik0/CodeTwin/issues',
    icon: 'bug',
    external: true,
  },
  {
    label: 'Contributors',
    href: 'https://github.com/Sahnik0/CodeTwin/graphs/contributors',
    icon: 'users',
    external: true,
  },
  {
    label: 'Connect',
    href: '/connect',
    icon: 'mail',
    external: false,
  },
]

const productLinks = [
  { label: 'Changelog', href: '/changelog' },
  { label: 'CLI Reference', href: '/docs/cli-reference' },
  { label: 'Provider Setup', href: '/docs/providers' },
]

function SocialLinkIcon({ icon }: { icon: SocialIcon }) {
  if (icon === 'github') {
    return <GitHubIcon size={21} />
  }

  if (icon === 'bug') {
    return <Bug size={21} strokeWidth={1.75} />
  }

  if (icon === 'users') {
    return <Users size={21} strokeWidth={1.75} />
  }

  return <Mail size={21} strokeWidth={1.75} />
}

export default function Footer() {
  const currentYear = new Date().getFullYear()

  return (
    <footer className="relative overflow-hidden border-t border-border-default bg-background">
      <div className="relative z-10 mx-auto flex w-full max-w-7xl flex-col px-6 pb-8 pt-16 md:pt-20">
        <div className="mx-auto flex w-full max-w-4xl flex-col items-center text-center">
          <div className="text-5xl font-extrabold leading-none tracking-tight text-text-primary md:text-6xl">
            Code<span className="text-teal">Twin</span><span className="text-teal">.</span>
          </div>

          <p className="mt-5 max-w-[560px] text-base leading-relaxed text-text-secondary sm:text-lg md:text-xl">
            A terminal-first AI coding agent. Built for developers who want control.
          </p>

          <nav aria-label="Footer social links" className="mt-9 flex items-center gap-7 text-text-muted">
            {socialLinks.map((link) => {
              if (link.external) {
                return (
                  <a
                    key={link.href}
                    href={link.href}
                    target="_blank"
                    rel="noopener noreferrer"
                    aria-label={link.label}
                    className="transition-colors hover:text-text-primary"
                  >
                    <SocialLinkIcon icon={link.icon} />
                  </a>
                )
              }

              return (
                <Link
                  key={link.href}
                  href={link.href}
                  aria-label={link.label}
                  className="transition-colors hover:text-text-primary"
                >
                  <SocialLinkIcon icon={link.icon} />
                </Link>
              )
            })}
          </nav>

          
        </div>

        <div className="relative mt-14 flex min-h-[220px] items-end justify-center md:mt-16 md:min-h-[290px]">
          <div
            aria-hidden="true"
            className="pointer-events-none absolute bottom-6 select-none text-[22vw] font-black uppercase leading-none tracking-[-0.06em] md:text-[18vw]"
            style={{
              backgroundImage: 'linear-gradient(to bottom, #222222 0%, #0a0a0a 85%)',
              WebkitBackgroundClip: 'text',
              backgroundClip: 'text',
              color: 'transparent',
              opacity: 0.6,
            }}
          >
            CodeTwin
          </div>
        </div>

        <p className="mt-4 text-xs text-text-muted/50">
          © {currentYear} CodeTwin · MIT License · Zero Telemetry
        </p>
      </div>
    </footer>
  )
}

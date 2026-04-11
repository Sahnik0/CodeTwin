import type { Metadata } from 'next'
import NavBar from '@/components/NavBar'
import Footer from '@/components/Footer'
import BackToTop from '@/components/BackToTop'
import './globals.css'
import { SmoothScroll } from '@/components/SmoothScroll'

export const metadata: Metadata = {
  title: 'CodeTwin — Terminal AI coding agent',
  description:
    'A terminal-first AI coding agent. Runs on your machine. BYOK. Five autonomy levels. Twin memory per project.',
  openGraph: {
    title: 'CodeTwin',
    description: 'Terminal AI coding agent. Your machine. Your rules.',
    type: 'website',
    url: 'https://CodeTwin.dev',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'CodeTwin — Terminal AI coding agent',
    description: 'Terminal AI coding agent. Your machine. Your rules.',
  },
  metadataBase: new URL('https://CodeTwin.dev'),
  icons: {
    icon: [
      { url: '/favicon.svg?v=1', type: 'image/svg+xml' },
      { url: '/final-logo.png?v=2', type: 'image/png' },
    ],
    shortcut: [{ url: '/favicon.svg?v=1', type: 'image/svg+xml' }],
    apple: [{ url: '/final-logo.png?v=2', type: 'image/png' }],
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html
      lang="en"
      className="antialiased"
    >
      <head>
        <style dangerouslySetInnerHTML={{ __html: `
          @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:ital,wght@0,100..800;1,100..800&display=swap');
          * { font-family: 'JetBrains Mono', monospace !important; }
        ` }} />
      </head>
      <body className="bg-background text-text-primary antialiased">
        <SmoothScroll>
          <NavBar />
          <main>{children}</main>
          <Footer />
          <BackToTop />
        </SmoothScroll>
      </body>
    </html>
  )
}

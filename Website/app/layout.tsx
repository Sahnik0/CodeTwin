import type { Metadata } from 'next'
import { GeistSans } from 'geist/font/sans'
import { GeistMono } from 'geist/font/mono'
import NavBar from '@/components/NavBar'
import Footer from '@/components/Footer'
import './globals.css'

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
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html
      lang="en"
      className={`${GeistSans.variable} ${GeistMono.variable}`}
    >
      <body className="bg-background text-text-primary font-sans antialiased">
        <NavBar />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  )
}

import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './content/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        background: '#0a0a0a',
        surface: '#111111',
        'surface-elevated': '#1a1a1a',
        'border-default': '#222222',
        'border-hover': '#333333',
        'text-primary': '#f5f5f5',
        'text-secondary': '#888888',
        'text-muted': '#555555',
        accent: '#7c3aed',
        'accent-glow': 'rgba(124, 58, 237, 0.15)',
        success: '#22c55e',
        warning: '#f59e0b',
        danger: '#ef4444',
      },
      fontFamily: {
        sans: ['var(--font-geist-sans)', 'system-ui', 'sans-serif'],
        mono: ['var(--font-geist-mono)', 'Consolas', 'monospace'],
      },
      fontSize: {
        'hero': ['clamp(2.5rem, 5vw, 3.75rem)', { lineHeight: '1.1', letterSpacing: '-0.03em' }],
      },
      maxWidth: {
        'prose-tight': '540px',
      },
      animation: {
        blink: 'blink 1s step-end infinite',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
        'scroll-bounce': 'scroll-bounce 2s ease-in-out infinite',
      },
      keyframes: {
        blink: {
          '0%, 100%': { opacity: '1' },
          '50%': { opacity: '0' },
        },
        'scroll-bounce': {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(6px)' },
        },
      },
      backdropBlur: {
        xs: '2px',
      },
      borderRadius: {
        DEFAULT: '0.5rem',
      },
    },
  },
  plugins: [],
}

export default config

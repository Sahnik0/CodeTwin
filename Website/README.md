# CodeTwin Website

A modern, high-performance, and visually stunning landing page built for **CodeTwin** — the premier terminal-first AI coding agent.

## Technology Stack

- **Framework**: [Next.js 14](https://nextjs.org) (App Router architecture)
- **Styling**: [Tailwind CSS](https://tailwindcss.com/)
- **Animation Engine**: [Framer Motion](https://www.framer.com/motion/)
- **Scroll Physics**: [Lenis](https://lenis.studiofreight.com/) (Fluid smooth scrolling matrix)
- **Typography**: [JetBrains Mono](https://fonts.google.com/specimen/JetBrains+Mono) (Applied globally via raw `<style>` HTML mapping)
- **Icons**: [Lucide React](https://lucide.dev/)

## Key Design & UX Features

- **Velocity "Jelly" Scrolling**: High-performance framer hooks (`useVelocity`, `useTransform`) interpolating user scroll speed into physical element skews and delays.
- **Interactive BorderGlow API**: Custom GPU-accelerated mouse-tracking edge illumination mapping to dynamic radial gradients.
- **3D Parallax Viewports**: Hero-section implementations of layout perspective projections.
- **Scroll Scrubbing Reveal**: Typography layers structurally tied to absolute wrapper boundaries for flawless textual reveals.
- **GitHub Live Polling**: Dynamically fetching actual open-source repository structures while breaking manual statically cached boundaries.

## Getting Started

First, ensure all `node_modules` are properly pulled down:

```bash
npm install
```

Boot the local development server:

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser. Core landing architecture flows through `app/page.tsx`, wrapped by the global root definitions residing in `app/layout.tsx`.

## Structural Decisions

- **Absolute Google Fonts Handling**: We forcefully bypassed standard Next.js `localFont` loading caching constraints to ensure JetBrains Mono cascades down perfectly to all structural nodes.
- **No Native `Geist` Loading**: Standard pre-configured `create-next-app` variable mappings were purged for a strict dark-mode `/` monospace aesthetic layout.

'use client'

import { Terminal, Sliders, Brain, Key } from 'lucide-react'

const features = [
  {
    icon: <Terminal size={24} />,
    label: 'Terminal-first',
    sublabel: 'Runs in your shell',
  },
  {
    icon: <Sliders size={24} />,
    label: 'You set the autonomy',
    sublabel: 'Five dependence levels',
  },
  {
    icon: <Brain size={24} />,
    label: 'Twin memory',
    sublabel: 'Context that survives restarts',
  },
  {
    icon: <Key size={24} />,
    label: 'BYOK — any provider',
    sublabel: 'Zero vendor lock-in',
  },
]

export default function FeatureIconsRow() {
  return (
    <section className="py-20 px-6 border-t border-border-default relative overflow-hidden">
      <div className="max-w-5xl mx-auto">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-8 md:gap-4 items-start">
          {features.map((f, i) => (
            <div key={i} className="flex flex-col items-center text-center relative group">
              {/* Connecting line (visible between items on desktop) */}
              {i < features.length - 1 && (
                <div className="hidden md:block absolute top-8 left-[calc(50%+32px)] w-[calc(100%-64px)] h-[1px] border-t border-dashed border-[#2dd4bf33]" />
              )}

              {/* Diamond icon container */}
              <div className="relative mb-4">
                <div
                  className="w-16 h-16 flex items-center justify-center rotate-45 border-2 border-[#2dd4bf44] rounded-lg bg-[#2dd4bf08] group-hover:border-[#2dd4bf88] group-hover:bg-[#2dd4bf12] transition-all duration-300"
                >
                  <div className="-rotate-45 text-[#2dd4bf]">
                    {f.icon}
                  </div>
                </div>
                {/* Glow effect */}
                <div className="absolute inset-0 rotate-45 rounded-lg bg-[#2dd4bf] opacity-0 group-hover:opacity-[0.06] blur-xl transition-opacity duration-300" />
              </div>

              <h3 className="text-sm font-medium text-text-primary mb-1">
                {f.label}
              </h3>
              <p className="text-xs text-text-muted">
                {f.sublabel}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

'use client'

import { motion, useScroll, useTransform } from 'framer-motion'
import { useRef } from 'react'
import Link from 'next/link'
import BorderGlow from './BorderGlow'

export default function FinalCTASection() {
  const containerRef = useRef<HTMLElement>(null);
  const { scrollYProgress } = useScroll({ target: containerRef, offset: ["start 90%", "center center"] });
  const textOpacity = useTransform(scrollYProgress, [0, 1], [0.1, 1]);
  const textScale = useTransform(scrollYProgress, [0, 1], [0.8, 1]);
  const letterSpacing = useTransform(scrollYProgress, [0, 1], ["-0.08em", "-0.02em"]);

  return (
    <section ref={containerRef} className="relative py-24 px-6 overflow-hidden bg-background">
      <div className="relative z-10 max-w-5xl mx-auto">
        <BorderGlow
          edgeSensitivity={40}
          glowColor="240 60 70"
          backgroundColor="#0a0a0a"
          borderRadius={24}
          glowRadius={60}
          glowIntensity={1.5}
          coneSpread={30}
          animated={true}
          colors={['#a6a6ed', '#ffffff', '#2dd4bf']}
          className="w-full flex flex-col items-center justify-center py-24 px-6 text-center"
        >
          {/* Headline */}
          <motion.h2 
            style={{ opacity: textOpacity, scale: textScale, letterSpacing: letterSpacing }}
            className="text-4xl md:text-5xl lg:text-6xl font-semibold text-text-primary leading-[1.06] mb-5 origin-center z-10 relative"
          >
            Ready to Take Control?
          </motion.h2>

          {/* Sub copy */}
          <p className="text-base text-text-secondary mb-10 max-w-md mx-auto leading-relaxed z-10 relative">
            No cloud. No vendor lock-in. Just you, your terminal, and an AI agent that listens.
          </p>

          {/* Actions */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 z-10 relative">
            <Link
              href="/docs/getting-started"
              className="inline-flex items-center gap-2 whitespace-nowrap px-8 h-12 rounded-lg bg-[#a6a6ed] text-[#060010] text-sm font-semibold hover:bg-[#9494e0] transition-colors duration-200"
            >
              Get Started Now
            </Link>
          </div>
        </BorderGlow>
      </div>
    </section>
  )
}

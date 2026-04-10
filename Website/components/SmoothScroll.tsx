'use client'
import React, { useEffect } from 'react'
import Lenis from 'lenis'

export const LENIS_ACTIVATE_EVENT = 'codetwin:lenis-activate'

export function SmoothScroll({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      orientation: 'vertical',
      gestureOrientation: 'vertical',
      smoothWheel: true,
      wheelMultiplier: 1,
      touchMultiplier: 2,
    })

    const handleActivate = () => {
      lenis.start()
    }
    window.addEventListener(LENIS_ACTIVATE_EVENT, handleActivate)

    let rafId = 0

    function raf(time: number) {
      lenis.raf(time)
      rafId = requestAnimationFrame(raf)
    }

    rafId = requestAnimationFrame(raf)

    return () => {
      window.removeEventListener(LENIS_ACTIVATE_EVENT, handleActivate)
      cancelAnimationFrame(rafId)
      lenis.destroy()
    }
  }, [])

  return <>{children}</>
}

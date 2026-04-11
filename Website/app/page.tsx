import HeroSection from '@/components/HeroSection'
import FeatureIconsRow from '@/components/FeatureIconsRow'
import FeatureWalkthrough from '@/components/FeatureWalkthrough'
import GettingStartedSection from '@/components/GettingStartedSection'
import FAQSection from '@/components/FAQSection'
import FinalCTASection from '@/components/FinalCTASection'

/* ──────────────────────────────────────────────
   Page — CodeTwin Landing
────────────────────────────────────────────── */
export default function HomePage() {
  return (
    <>
      {/* ── Section 1: Hero ── */}
      <HeroSection />

      {/* ── Section 2: Feature Icons Row ── */}
      <FeatureIconsRow />

      {/* ── Section 3: Feature Walkthrough (alternating) ── */}
      <FeatureWalkthrough />

      {/* ── Section 4: Getting Started ── */}
      <GettingStartedSection />

      {/* ── Section 5: FAQ ── */}
      <FAQSection />

      {/* ── Section 6: Final CTA ── */}
      <FinalCTASection />
    </>
  )
}

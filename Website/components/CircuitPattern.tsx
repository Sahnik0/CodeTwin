interface CircuitPatternProps {
  className?: string
  variant?: 'top-right' | 'bottom-left' | 'bottom-right' | 'top-left' | 'full'
}

export default function CircuitPattern({
  className = '',
  variant = 'top-right',
}: CircuitPatternProps) {
  const positionClasses: Record<string, string> = {
    'top-right': 'top-0 right-0',
    'bottom-left': 'bottom-0 left-0',
    'bottom-right': 'bottom-0 right-0',
    'top-left': 'top-0 left-0',
    full: 'inset-0',
  }

  return (
    <div
      className={`absolute pointer-events-none overflow-hidden ${positionClasses[variant]} ${className}`}
      aria-hidden="true"
      style={{ width: variant === 'full' ? '100%' : '320px', height: variant === 'full' ? '100%' : '320px' }}
    >
      <svg
        width="100%"
        height="100%"
        viewBox="0 0 320 320"
        fill="none"
        xmlns="http://www.w3.org/2000/svg"
        style={{ opacity: 0.15 }}
      >
        {/* Grid of diamond nodes with connecting lines */}
        {/* Row 1 */}
        <rect x="40" y="40" width="12" height="12" rx="2" transform="rotate(45 46 46)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="100" y="40" width="12" height="12" rx="2" transform="rotate(45 106 46)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="160" y="40" width="12" height="12" rx="2" transform="rotate(45 166 46)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="220" y="40" width="12" height="12" rx="2" transform="rotate(45 226 46)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="280" y="40" width="12" height="12" rx="2" transform="rotate(45 286 46)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Row 2 */}
        <rect x="70" y="70" width="12" height="12" rx="2" transform="rotate(45 76 76)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="130" y="70" width="12" height="12" rx="2" transform="rotate(45 136 76)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="190" y="70" width="12" height="12" rx="2" transform="rotate(45 196 76)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="250" y="70" width="12" height="12" rx="2" transform="rotate(45 256 76)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Row 3 */}
        <rect x="40" y="100" width="12" height="12" rx="2" transform="rotate(45 46 106)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="100" y="100" width="12" height="12" rx="2" transform="rotate(45 106 106)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="160" y="100" width="12" height="12" rx="2" transform="rotate(45 166 106)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="220" y="100" width="12" height="12" rx="2" transform="rotate(45 226 106)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="280" y="100" width="12" height="12" rx="2" transform="rotate(45 286 106)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Row 4 */}
        <rect x="70" y="130" width="12" height="12" rx="2" transform="rotate(45 76 136)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="130" y="130" width="12" height="12" rx="2" transform="rotate(45 136 136)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="190" y="130" width="12" height="12" rx="2" transform="rotate(45 196 136)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="250" y="130" width="12" height="12" rx="2" transform="rotate(45 256 136)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Row 5 */}
        <rect x="40" y="160" width="12" height="12" rx="2" transform="rotate(45 46 166)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="100" y="160" width="12" height="12" rx="2" transform="rotate(45 106 166)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="160" y="160" width="12" height="12" rx="2" transform="rotate(45 166 166)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="220" y="160" width="12" height="12" rx="2" transform="rotate(45 226 166)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="280" y="160" width="12" height="12" rx="2" transform="rotate(45 286 166)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Row 6 */}
        <rect x="70" y="190" width="12" height="12" rx="2" transform="rotate(45 76 196)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="130" y="190" width="12" height="12" rx="2" transform="rotate(45 136 196)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="190" y="190" width="12" height="12" rx="2" transform="rotate(45 196 196)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="250" y="190" width="12" height="12" rx="2" transform="rotate(45 256 196)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Row 7 */}
        <rect x="40" y="220" width="12" height="12" rx="2" transform="rotate(45 46 226)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="100" y="220" width="12" height="12" rx="2" transform="rotate(45 106 226)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="160" y="220" width="12" height="12" rx="2" transform="rotate(45 166 226)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="220" y="220" width="12" height="12" rx="2" transform="rotate(45 226 226)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="280" y="220" width="12" height="12" rx="2" transform="rotate(45 286 226)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Row 8 */}
        <rect x="70" y="250" width="12" height="12" rx="2" transform="rotate(45 76 256)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="130" y="250" width="12" height="12" rx="2" transform="rotate(45 136 256)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="190" y="250" width="12" height="12" rx="2" transform="rotate(45 196 256)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="250" y="250" width="12" height="12" rx="2" transform="rotate(45 256 256)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Row 9 */}
        <rect x="40" y="280" width="12" height="12" rx="2" transform="rotate(45 46 286)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="100" y="280" width="12" height="12" rx="2" transform="rotate(45 106 286)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="160" y="280" width="12" height="12" rx="2" transform="rotate(45 166 286)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="220" y="280" width="12" height="12" rx="2" transform="rotate(45 226 286)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />
        <rect x="280" y="280" width="12" height="12" rx="2" transform="rotate(45 286 286)" stroke="#2dd4bf" strokeWidth="1.5" fill="none" />

        {/* Connecting lines - horizontal */}
        <line x1="52" y1="46" x2="94" y2="46" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="112" y1="46" x2="154" y2="46" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="172" y1="46" x2="214" y2="46" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="232" y1="46" x2="274" y2="46" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />

        <line x1="82" y1="76" x2="124" y2="76" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="142" y1="76" x2="184" y2="76" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="202" y1="76" x2="244" y2="76" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />

        <line x1="52" y1="106" x2="94" y2="106" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="112" y1="106" x2="154" y2="106" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="172" y1="106" x2="214" y2="106" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="232" y1="106" x2="274" y2="106" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />

        {/* Connecting lines - vertical */}
        <line x1="46" y1="52" x2="46" y2="94" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="106" y1="52" x2="106" y2="94" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="166" y1="52" x2="166" y2="94" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="226" y1="52" x2="226" y2="94" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="286" y1="52" x2="286" y2="94" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />

        <line x1="46" y1="112" x2="46" y2="154" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="106" y1="112" x2="106" y2="154" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="166" y1="112" x2="166" y2="154" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="226" y1="112" x2="226" y2="154" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="286" y1="112" x2="286" y2="154" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />

        <line x1="46" y1="172" x2="46" y2="214" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="106" y1="172" x2="106" y2="214" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="166" y1="172" x2="166" y2="214" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="226" y1="172" x2="226" y2="214" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="286" y1="172" x2="286" y2="214" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />

        {/* Diagonal connecting lines */}
        <line x1="52" y1="52" x2="70" y2="70" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="112" y1="52" x2="130" y2="70" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="172" y1="52" x2="190" y2="70" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="232" y1="52" x2="250" y2="70" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />

        <line x1="82" y1="82" x2="100" y2="100" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="142" y1="82" x2="160" y2="100" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />
        <line x1="202" y1="82" x2="220" y2="100" stroke="#2dd4bf" strokeWidth="0.5" strokeDasharray="3 3" />

        {/* Some filled nodes for variety */}
        <circle cx="76" cy="76" r="3" fill="#2dd4bf" opacity="0.4" />
        <circle cx="196" cy="136" r="3" fill="#2dd4bf" opacity="0.4" />
        <circle cx="106" cy="166" r="3" fill="#2dd4bf" opacity="0.4" />
        <circle cx="256" cy="196" r="3" fill="#2dd4bf" opacity="0.4" />
        <circle cx="46" cy="226" r="3" fill="#2dd4bf" opacity="0.4" />
        <circle cx="166" cy="286" r="3" fill="#2dd4bf" opacity="0.4" />
      </svg>
    </div>
  )
}

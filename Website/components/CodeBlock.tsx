import { highlight } from '@/lib/shiki'
import CopyButton from './CopyButton'

interface CodeBlockProps {
  code: string
  language?: string
  showCopy?: boolean
  filename?: string
}

export default async function CodeBlock({
  code,
  language = 'bash',
  showCopy = true,
  filename,
}: CodeBlockProps) {
  const html = await highlight(code.trim(), language)

  return (
    <div className="relative group w-full">
      {filename && (
        <div className="flex items-center gap-2 px-4 py-2 bg-surface-elevated border border-b-0 border-border-default rounded-t-lg">
          <span className="text-xs text-text-muted font-mono">{filename}</span>
        </div>
      )}
      <div
        className={`relative ${filename ? 'rounded-t-none rounded-b-lg' : 'rounded-lg'} overflow-hidden border border-border-default`}
      >
        <div
          className="shiki-wrapper"
          dangerouslySetInnerHTML={{ __html: html }}
        />
        {showCopy && (
          <div className="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
            <CopyButton text={code.trim()} />
          </div>
        )}
      </div>
    </div>
  )
}

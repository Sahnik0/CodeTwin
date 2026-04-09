import { notFound } from 'next/navigation'
import { readFile } from 'fs/promises'
import path from 'path'
import matter from 'gray-matter'

// Map slug → MDX filename
const slugMap: Record<string, string> = {
  'getting-started': 'getting-started.mdx',
  providers: 'providers.mdx',
  'dependence-levels': 'dependence-levels.mdx',
  'remote-control': 'remote-control.mdx',
  'twin-memory': 'twin-memory.mdx',
  tools: 'tools.mdx',
  'cli-reference': 'cli-reference.mdx',
}

async function getDocContent(slug: string): Promise<{ content: string; title: string } | null> {
  const filename = slugMap[slug]
  if (!filename) return null

  try {
    const filePath = path.join(process.cwd(), 'content', 'docs', filename)
    const raw = await readFile(filePath, 'utf-8')
    const { content, data } = matter(raw)
    return { content, title: data.title ?? slug }
  } catch {
    return null
  }
}

// Very lightweight markdown → HTML renderer (no MDX compilation needed at runtime)
function renderMarkdown(md: string): string {
  return md
    .replace(/^### (.+)$/gm, '<h3 id="$1" class="text-base font-medium text-text-primary mt-8 mb-3">$1</h3>')
    .replace(/^## (.+)$/gm, '<h2 id="$1" class="text-lg font-medium text-text-primary mt-12 mb-4 border-b border-border-default pb-2">$1</h2>')
    .replace(/^# (.+)$/gm, '<h1 class="text-2xl font-medium text-text-primary mb-6">$1</h1>')
    .replace(/\*\*(.+?)\*\*/g, '<strong class="text-text-primary font-medium">$1</strong>')
    .replace(/`([^`]+)`/g, '<code class="font-mono text-xs bg-surface-elevated border border-border-default rounded px-1.5 py-0.5 text-text-secondary">$1</code>')
    .replace(/^- (.+)$/gm, '<li class="text-text-secondary text-sm">$1</li>')
    .replace(/^(?!<[h|l|c]).+$/gm, (line) =>
      line.trim() ? `<p class="text-sm text-text-secondary leading-relaxed mb-4">${line}</p>` : ''
    )
}

interface DocsPageProps {
  params: { slug: string }
}

export function generateStaticParams() {
  return Object.keys(slugMap).map((slug) => ({ slug }))
}

export default async function DocsPage({ params }: DocsPageProps) {
  const doc = await getDocContent(params.slug)

  if (!doc) {
    notFound()
  }

  const html = renderMarkdown(doc.content)

  return (
    <div>
      <div
        className="docs-content"
        dangerouslySetInnerHTML={{ __html: html }}
      />
    </div>
  )
}

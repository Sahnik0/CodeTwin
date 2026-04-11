import { notFound } from 'next/navigation'
import { readFile } from 'fs/promises'
import path from 'path'
import matter from 'gray-matter'
import { codeToHtml } from 'shiki'
import CopyButton from '@/components/CopyButton'
import Link from 'next/link'

const orderedPages = [
  { slug: 'getting-started', title: 'Getting Started', group: 'Getting started' },
  { slug: 'dependence-levels', title: 'Dependence Levels', group: 'Core concepts' },
  { slug: 'twin-memory', title: 'Twin Memory', group: 'Core concepts' },
  { slug: 'providers', title: 'Providers', group: 'Providers' },
  { slug: 'tools', title: 'Tools', group: 'Tools' },
  { slug: 'remote-control', title: 'Remote Control', group: 'Remote control' },
  { slug: 'cli-reference', title: 'CLI Reference', group: 'CLI reference' },
]

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

type Block =
  | { type: 'markdown'; content: string }
  | { type: 'code'; lang: string; code: string; html: string }

async function parseAndRenderBlocks(md: string): Promise<Block[]> {
  const blocks: Block[] = []
  
  // Split by code blocks: ```lang \n code \n ```
  const parts = md.split(/``` *(\w+)? *\n([\s\S]*?)```/g)
  
  for (let i = 0; i < parts.length; i += 3) {
    if (parts[i]) {
      blocks.push({ type: 'markdown', content: parts[i] })
    }
    if (i + 1 < parts.length) {
      const lang = parts[i + 1] || 'text'
      const code = parts[i + 2].trim()
      
      let html = ''
      try {
        html = await codeToHtml(code, { lang, theme: 'github-dark' })
      } catch (e) {
        html = await codeToHtml(code, { lang: 'text', theme: 'github-dark' })
      }
      
      blocks.push({ type: 'code', lang, code, html })
    }
  }
  
  return blocks
}

function escapeHtml(unsafe: string) {
    return unsafe
         .replace(/&/g, "&amp;")
         .replace(/</g, "&lt;")
         .replace(/>/g, "&gt;")
         .replace(/"/g, "&quot;")
         .replace(/'/g, "&#039;");
}

// Improved markdown renderer for inline styles
function renderMarkdown(md: string): string {
  let html = md.replace(/\r\n/g, '\n')

  html = html
    .replace(/\*\*(.*?)\*\*/g, '<strong class="text-text-primary font-bold bg-[#a6a6ed]/10 px-1.5 py-0.5 rounded">$1</strong>')
    .replace(/`([^`\n]+)`/g, (m, codeText) => `<code class="font-mono text-[13px] bg-[#eb5757]/10 border border-[#eb5757]/20 rounded px-1.5 py-0.5 text-[#eb5757] font-medium break-all sm:break-normal">${escapeHtml(codeText)}</code>`)
    .replace(/^### (.+)$/gm, (m, title) => `<h3 id="${title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}" class="text-lg font-semibold text-text-primary mt-12 mb-4 flex items-center gap-2 tracking-tight"><div class="w-1.5 h-5 bg-[#a6a6ed] rounded-full"></div>${title}</h3>`)
    .replace(/^## (.+)$/gm, (m, title) => `<h2 id="${title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}" class="text-xl md:text-2xl font-bold text-text-primary mt-16 mb-6 border-b border-border-default pb-4 tracking-tight">${title}</h2>`)
    .replace(/^# (.+)$/gm, (m, title) => `<h1 class="text-4xl md:text-5xl font-black text-transparent bg-clip-text bg-gradient-to-r from-text-primary to-text-secondary mb-8 tracking-tighter">${title}</h1>`)
    .replace(/^- (.+)$/gm, '<li class="text-text-secondary text-[15px] ml-6 list-disc mb-2 pl-2 marker:text-[#a6a6ed]">$1</li>')
    .replace(/^\d+\. (.+)$/gm, '<li class="text-text-secondary text-[15px] ml-6 list-decimal mb-2 pl-2 marker:text-[#a6a6ed] font-medium">$1</li>')
    .replace(/^> (.+)$/gm, '<blockquote class="border-l-2 border-[#a6a6ed] pl-4 py-1 italic text-text-muted my-6 bg-[#a6a6ed]/5 rounded-r">$1</blockquote>')
    .replace(/\[(.*?)\]\((.*?)\)/g, '<a href="$2" class="text-[#a6a6ed] hover:underline underline-offset-4 pointer-events-auto">$1</a>')
    .replace(/^(?!<(?:h|li|blockquote)).+$/gm, (line) =>
      line.trim() ? `<p class="text-[15px] md:text-base text-text-secondary leading-relaxed mb-6">${line.trim()}</p>` : ''
    )

  return html
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

  const blocks = await parseAndRenderBlocks(doc.content)

  const currentIndex = orderedPages.findIndex(p => p.slug === params.slug)
  const prevPage = currentIndex > 0 ? orderedPages[currentIndex - 1] : null
  const nextPage = currentIndex < orderedPages.length - 1 ? orderedPages[currentIndex + 1] : null

  return (
    <div className="max-w-3xl mx-auto py-8 lg:py-12 animate-in fade-in duration-500">
      {blocks.map((block, index) => {
        if (block.type === 'markdown') {
          return (
            <div 
              key={index} 
              className="docs-prose"
              dangerouslySetInnerHTML={{ __html: renderMarkdown(block.content) }} 
            />
          )
        } else {
          return (
            <div key={index} className="my-8 rounded-xl overflow-hidden border border-border-default bg-[#0d1117] shadow-xl group">
              <div className="flex items-center justify-between px-4 py-2.5 bg-surface-elevated/50 border-b border-border-default">
                <div className="flex items-center gap-3">
                  <div className="flex gap-1.5 opacity-60">
                    <div className="w-2.5 h-2.5 rounded-full bg-border-default hover:bg-[#ff5f56] transition-colors cursor-pointer" />
                    <div className="w-2.5 h-2.5 rounded-full bg-border-default hover:bg-[#ffbd2e] transition-colors cursor-pointer" />
                    <div className="w-2.5 h-2.5 rounded-full bg-border-default hover:bg-[#27c93f] transition-colors cursor-pointer" />
                  </div>
                  <span className="text-[11px] font-mono font-semibold text-text-muted uppercase tracking-widest pl-2 border-l border-border-default">{block.lang}</span>
                </div>
                <CopyButton text={block.code} label={`Copy ${block.lang} code`} />
              </div>
              <div 
                className="p-5 overflow-x-auto text-[13px] sm:text-sm font-mono leading-relaxed"
                dangerouslySetInnerHTML={{ __html: block.html.replace(/<pre[^>]*>/, '<pre class="bg-transparent m-0 p-0">') }}
              />
            </div>
          )
        }
      })}

      <div className="mt-16 pt-8 border-t border-border-default flex flex-col sm:flex-row items-stretch justify-between gap-4">
        {prevPage ? (
          <Link href={`/docs/${prevPage.slug}`} className="group flex flex-col items-start p-4 bg-surface hover:bg-surface-elevated border border-border-default hover:border-[#a6a6ed] rounded-xl transition-all w-full sm:w-1/2">
            <span className="text-xs text-text-muted font-mono tracking-[0.2em] uppercase mb-1.5 flex items-center gap-2 group-hover:-translate-x-1 transition-transform">
              <span className="text-lg leading-none">←</span> Previous
            </span>
            <span className="text-sm font-semibold text-text-primary">{prevPage.title}</span>
          </Link>
        ) : <div className="hidden sm:block sm:w-1/2" />}
        
        {nextPage ? (
          <Link href={`/docs/${nextPage.slug}`} className="group flex flex-col items-end text-right p-4 bg-surface hover:bg-surface-elevated border border-border-default hover:border-[#a6a6ed] rounded-xl transition-all w-full sm:w-1/2">
            <span className="text-xs text-text-muted font-mono tracking-[0.2em] uppercase mb-1.5 flex items-center gap-2 group-hover:translate-x-1 transition-transform">
              Next <span className="text-lg leading-none">→</span>
            </span>
            <span className="text-sm font-semibold text-text-primary">{nextPage.title}</span>
          </Link>
        ) : <div className="hidden sm:block sm:w-1/2" />}
      </div>
    </div>
  )
}


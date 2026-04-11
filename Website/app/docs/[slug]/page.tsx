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
  
  // Normalize line endings to avoid \r breaking the regex match
  const cleanMd = md.replace(/\r\n/g, '\n').replace(/\r/g, '\n')
  
  // Split by code blocks: ```lang \n code \n ```
  const parts = cleanMd.split(/``` *(\w+)? *\n([\s\S]*?)```/g)
  
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
      } catch {
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

  // Compile links first to prevent regex collisions with Tailwind bracket classes like `text-[14px]`
  html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" class="text-[#a6a6ed] font-medium hover:text-[#c4c4ff] hover:underline underline-offset-4 pointer-events-auto transition-colors">$1</a>')

  html = html
    .replace(/\*\*(.*?)\*\*/g, '<strong class="text-text-primary font-bold bg-[#a6a6ed]/10 px-1 rounded">$1</strong>')
    .replace(/`([^`\n]+)`/g, (m, codeText) => `<code class="font-mono text-xs md:text-[13px] bg-surface-elevated border border-border-default rounded px-1.5 py-0.5 text-[#ff7b72] font-semibold tracking-tight shadow-sm break-words">${escapeHtml(codeText)}</code>`)
    .replace(/^### (.+)$/gm, (m, title) => `<h3 id="${title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}" class="text-base md:text-lg font-bold text-text-primary mt-10 mb-4 flex items-center gap-3 tracking-tight"><div class="w-1.5 h-5 bg-gradient-to-b from-[#a6a6ed] to-[#7373ed] rounded-full shadow-[0_0_8px_rgba(166,166,237,0.4)]"></div>${title}</h3>`)
    .replace(/^## (.+)$/gm, (m, title) => `<h2 id="${title.toLowerCase().replace(/[^a-z0-9]+/g, '-')}" class="text-xl md:text-2xl font-bold text-text-primary mt-12 mb-5 pb-2 tracking-tight group"><span class="border-b-2 border-border-default group-hover:border-[#a6a6ed] transition-colors pb-1.5">${title}</span></h2>`)
    .replace(/^# (.+)$/gm, (m, title) => `<h1 class="text-3xl md:text-4xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-text-primary via-text-primary to-[#a6a6ed] mb-10 tracking-tight leading-tight drop-shadow-sm">${title}</h1>`)
    .replace(/^- (.+)$/gm, '<li class="text-text-secondary text-[14px] md:text-[15px] ml-6 list-disc mb-2 pl-1 marker:text-[#a6a6ed] font-medium">$1</li>')
    .replace(/^\d+\. (.+)$/gm, '<li class="text-text-secondary text-[14px] md:text-[15px] ml-6 list-decimal mb-2 pl-1 marker:text-[#a6a6ed] font-bold">$1</li>')
    .replace(/^> (.+)$/gm, '<blockquote class="border-l-4 border-[#a6a6ed] pl-4 py-2 text-base italic text-text-primary font-medium my-6 bg-gradient-to-r from-[#a6a6ed]/10 to-transparent rounded-r-lg">$1</blockquote>')
    .replace(/^(?!<(?:h|li|blockquote|a)).+$/gm, (line) =>
      line.trim() ? `<p class="text-[14px] md:text-[15px] text-text-secondary leading-relaxed mb-5 font-medium">${line.trim()}</p>` : ''
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
            <div key={index} className="my-8 rounded-[14px] overflow-hidden border border-white/10 bg-[#0A0D15] shadow-2xl group relative ring-1 ring-black/20">
              {/* Subtle top edge highlight for 3D glass effect */}
              <div className="absolute inset-x-0 top-0 h-[1px] bg-white/5 z-10" />
              
              <div className="flex items-center justify-between px-4 py-3 bg-[#ffffff03] border-b border-white/5 relative z-20">
                <div className="flex items-center gap-3.5">
                  <div className="flex gap-1.5 opacity-90">
                    <div className="w-[11px] h-[11px] rounded-full bg-[#FF5F56] border border-[#DF3F36]" />
                    <div className="w-[11px] h-[11px] rounded-full bg-[#FFBD2E] border border-[#DE9B24]" />
                    <div className="w-[11px] h-[11px] rounded-full bg-[#27C93F] border border-[#1BAA2B]" />
                  </div>
                  <span className="text-[11px] font-mono font-medium text-text-muted/60 uppercase tracking-widest pl-3 ml-1 border-l border-white/10">{block.lang}</span>
                </div>
                <div className="opacity-0 group-hover:opacity-100 transition-opacity">
                  <CopyButton text={block.code} label={`Copy ${block.lang} code`} />
                </div>
              </div>
              <div 
                className="p-5 overflow-x-auto text-[13px] sm:text-[14px] font-mono leading-loose tracking-wide !bg-transparent relative z-20 selection:bg-[#a6a6ed]/30"
                dangerouslySetInnerHTML={{ __html: block.html.replace(/<pre[^>]*>/, '<pre class="bg-transparent m-0 p-0">') }}
              />
              
              {/* Subtle ambient light from bottom right on hover */}
              <div className="absolute -bottom-[200px] -right-[200px] w-[400px] h-[400px] bg-[#a6a6ed]/5 blur-[100px] rounded-full opacity-0 group-hover:opacity-100 transition-opacity duration-1000 pointer-events-none" />
            </div>
          )
        }
      })}

      <div className="mt-24 pt-10 border-t border-border-default flex flex-col sm:flex-row items-stretch justify-between gap-6">
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


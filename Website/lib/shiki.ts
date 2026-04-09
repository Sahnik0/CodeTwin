import { createHighlighter, type Highlighter } from 'shiki'

let highlighterInstance: Highlighter | null = null

export async function getHighlighter(): Promise<Highlighter> {
  if (highlighterInstance) {
    return highlighterInstance
  }

  highlighterInstance = await createHighlighter({
    themes: ['github-dark-dimmed'],
    langs: ['bash', 'typescript', 'javascript', 'json', 'mdx', 'markdown', 'shell'],
  })

  return highlighterInstance
}

export async function highlight(
  code: string,
  lang: string = 'bash'
): Promise<string> {
  const highlighter = await getHighlighter()
  return highlighter.codeToHtml(code, {
    lang,
    theme: 'github-dark-dimmed',
  })
}

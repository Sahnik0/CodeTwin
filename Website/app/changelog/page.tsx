import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Changelog — CodeTwin',
  description: 'Release history for CodeTwin.',
}

const GITHUB_COMMITS_API = 'https://api.github.com/repos/Sahnik0/CodeTwin/commits?sha=main&per_page=50'

interface GitHubCommit {
  sha: string
  html_url: string
  commit: {
    message: string
    author: {
      name: string
      date: string
    } | null
  }
}

interface CommitEntry {
  sha: string
  url: string
  message: string
  author: string
  date: string
}

const FALLBACK_COMMITS: CommitEntry[] = [
  {
    sha: 'ae2a4e38d018841f220976b5809da77530190af4',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/ae2a4e38d018841f220976b5809da77530190af4',
    message: 'chore: remove unused bessa.txt file',
    author: 'sanks011',
    date: '2026-04-11T00:00:00Z',
  },
  {
    sha: 'ca407b2d95bed658a427ff43c9b675d2d0ad0aaf',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/ca407b2d95bed658a427ff43c9b675d2d0ad0aaf',
    message: 'refactor: remove unused modal screens and integrate decision handling in chat',
    author: 'sanks011',
    date: '2026-04-11T00:00:00Z',
  },
  {
    sha: 'd65932b503f75b4bd8109f6e677c1246dbc80ade',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/d65932b503f75b4bd8109f6e677c1246dbc80ade',
    message: 'fix: simplify next step command for worker in login process',
    author: 'sanks011',
    date: '2026-04-11T00:00:00Z',
  },
  {
    sha: 'da00690b085e18acf6bf4cbd372c2b93617bea5c',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/da00690b085e18acf6bf4cbd372c2b93617bea5c',
    message: 'chore: remove unused tree-sitter dependencies from package.json and bun.lock',
    author: 'sanks011',
    date: '2026-04-11T00:00:00Z',
  },
  {
    sha: '0ccb2156778410f0e2e07cf4694d5080a2935cd9',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/0ccb2156778410f0e2e07cf4694d5080a2935cd9',
    message: 'docs: update installation instructions and enhance getting started guide',
    author: 'sanks011',
    date: '2026-04-11T00:00:00Z',
  },
  {
    sha: '5f27a63d756db27ab2053a28dc5d29d7de4139bf',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/5f27a63d756db27ab2053a28dc5d29d7de4139bf',
    message: 'Refactor CodeTwin installation and usage documentation',
    author: 'sanks011',
    date: '2026-04-11T00:00:00Z',
  },
  {
    sha: 'e2327703e31d1d319e567e56098adbbbe4cac46f',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/e2327703e31d1d319e567e56098adbbbe4cac46f',
    message: 'feat: enhance user decision handling by adding rejection logic and option management',
    author: 'sanks011',
    date: '2026-04-11T00:00:00Z',
  },
  {
    sha: '9a7776e1fc442c2dfc407757999461f8772becf5',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/9a7776e1fc442c2dfc407757999461f8772becf5',
    message: 'feat: improve question handling by adding automatic response logic for skipped approvals',
    author: 'sanks011',
    date: '2026-04-11T00:00:00Z',
  },
  {
    sha: '11be0d805658b90a6e92ebbe2e902ebcb1858108',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/11be0d805658b90a6e92ebbe2e902ebcb1858108',
    message: 'feat: implement CLI-themed dashboard screen and bridge listener service for session management',
    author: 'aninda8680',
    date: '2026-04-10T00:00:00Z',
  },
  {
    sha: 'b14f674880d34093a5d69663a79d80945f48d783',
    url: 'https://github.com/Sahnik0/CodeTwin/commit/b14f674880d34093a5d69663a79d80945f48d783',
    message: 'feat: implement remote worker command for executing shell and CLI jobs via WebSocket broker',
    author: 'aninda8680',
    date: '2026-04-10T00:00:00Z',
  },
]

function isMergeCommit(message: string): boolean {
  const firstLine = message.split('\n')[0].trim().toLowerCase()
  return firstLine.startsWith('merge ')
}

function formatDay(dateKey: string): string {
  return new Date(`${dateKey}T00:00:00Z`).toLocaleDateString('en-US', {
    timeZone: 'UTC',
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })
}

function groupByDay(commits: CommitEntry[]): Array<[string, CommitEntry[]]> {
  const grouped = commits.reduce<Record<string, CommitEntry[]>>((acc, commit) => {
    const dateKey = commit.date.slice(0, 10)

    if (!acc[dateKey]) {
      acc[dateKey] = []
    }

    acc[dateKey].push(commit)
    return acc
  }, {})

  return Object.entries(grouped).sort(([a], [b]) => (a > b ? -1 : 1))
}

async function getRecentCommits(): Promise<CommitEntry[]> {
  try {
    const response = await fetch(GITHUB_COMMITS_API, {
      headers: {
        Accept: 'application/vnd.github+json',
      },
      next: { revalidate: 1800 },
    })

    if (!response.ok) {
      return FALLBACK_COMMITS
    }

    const data = (await response.json()) as GitHubCommit[]

    const commits = data
      .map((entry) => ({
        sha: entry.sha,
        url: entry.html_url,
        message: entry.commit.message.split('\n')[0].trim(),
        author: entry.commit.author?.name ?? 'unknown',
        date: entry.commit.author?.date ?? new Date().toISOString(),
      }))
      .filter((entry) => entry.message.length > 0)
      .filter((entry) => !isMergeCommit(entry.message))
      .slice(0, 24)

    return commits.length > 0 ? commits : FALLBACK_COMMITS
  } catch {
    return FALLBACK_COMMITS
  }
}

export default async function ChangelogPage() {
  const commits = await getRecentCommits()
  const commitGroups = groupByDay(commits)

  return (
    <div className="min-h-screen pt-24 pb-20 px-6">
      <div className="max-w-2xl mx-auto">
        <div className="mb-10">
          <h1 className="text-2xl font-medium text-text-primary mb-2">Changelog</h1>
          <p className="text-sm text-text-secondary">
            Recent commits from main branch. Merge pull request commits are excluded.
          </p>
        </div>

        <div className="space-y-8">
          {commitGroups.map(([dateKey, items]) => (
            <section key={dateKey}>
              <h2 className="text-xs font-mono uppercase tracking-[0.16em] text-[#a6a6ed] mb-4">
                {formatDay(dateKey)}
              </h2>
              <ul className="space-y-2">
                {items.map((commit) => (
                  <li key={commit.sha} className="py-1">
                    <a
                      href={commit.url}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="group"
                    >
                      <p className="text-sm text-text-primary leading-relaxed group-hover:text-[#a6a6ed] transition-colors">
                        {commit.message}
                      </p>
                      <p className="text-xs font-mono text-text-muted">
                        by {commit.author}
                      </p>
                    </a>
                  </li>
                ))}
              </ul>
            </section>
          ))}
        </div>

        <div className="mt-12 pt-8 border-t border-border-default">
          <a
            href="https://github.com/Sahnik0/CodeTwin/commits/main/"
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs text-text-muted hover:text-text-secondary transition-colors"
          >
            View full commit history on GitHub →
          </a>
        </div>
      </div>
    </div>
  )
}

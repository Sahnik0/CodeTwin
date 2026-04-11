import { NextResponse } from 'next/server'

interface Contributor {
  id: number
  login: string
  avatar_url: string
  html_url: string
  contributions: number
}

interface GitHubStatsContributor {
  total: number
  author: {
    id: number
    login: string
    avatar_url: string
    html_url: string
  } | null
}

interface GitHubRepoContributor {
  id: number
  login: string
  avatar_url: string
  html_url: string
  contributions: number
  type?: string
}

const REPO_OWNER = 'Sahnik0'
const REPO_NAME = 'CodeTwin'
const TOP_CONTRIBUTORS_LIMIT = 5

// Static fallback keeps the section visible even if GitHub APIs are unavailable.
const FALLBACK_CONTRIBUTORS: Contributor[] = [
  {
    id: 1,
    login: 'sanks011',
    avatar_url: 'https://github.com/sanks011.png?size=72',
    html_url: 'https://github.com/sanks011',
    contributions: 31,
  },
  {
    id: 2,
    login: 'Atanu2k4',
    avatar_url: 'https://github.com/Atanu2k4.png?size=72',
    html_url: 'https://github.com/Atanu2k4',
    contributions: 26,
  },
  {
    id: 3,
    login: 'aninda8680',
    avatar_url: 'https://github.com/aninda8680.png?size=72',
    html_url: 'https://github.com/aninda8680',
    contributions: 11,
  },
  {
    id: 4,
    login: 'Sahnik0',
    avatar_url: 'https://github.com/Sahnik0.png?size=72',
    html_url: 'https://github.com/Sahnik0',
    contributions: 6,
  },
]

function getGitHubHeaders() {
  const token = process.env.GITHUB_TOKEN
  const headers: Record<string, string> = {
    Accept: 'application/vnd.github+json',
    'X-GitHub-Api-Version': '2022-11-28',
    'User-Agent': 'CodeTwin-Website',
  }

  if (token) {
    headers.Authorization = `Bearer ${token}`
  }

  return headers
}

function normalizeContributors(data: Contributor[]): Contributor[] {
  return data
    .filter((entry) => Boolean(entry?.login) && Number.isFinite(entry?.contributions))
    .sort((a, b) => b.contributions - a.contributions)
    .slice(0, TOP_CONTRIBUTORS_LIMIT)
}

async function fetchStatsContributors(): Promise<Contributor[] | null> {
  const response = await fetch(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/stats/contributors`,
    {
      headers: getGitHubHeaders(),
      next: { revalidate: 300 },
    }
  )

  // GitHub can return 202 while contributor stats are being generated.
  if (response.status === 202 || !response.ok) {
    return null
  }

  const stats = (await response.json()) as GitHubStatsContributor[]

  if (!Array.isArray(stats)) {
    return null
  }

  const mapped = stats
    .filter(
      (entry): entry is GitHubStatsContributor & { author: NonNullable<GitHubStatsContributor['author']> } =>
        Boolean(entry?.author?.login)
    )
    .map((entry) => ({
      id: entry.author.id,
      login: entry.author.login,
      avatar_url: entry.author.avatar_url,
      html_url: entry.author.html_url,
      contributions: entry.total,
    }))

  return normalizeContributors(mapped)
}

async function fetchRepoContributors(): Promise<Contributor[] | null> {
  const response = await fetch(
    `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/contributors?per_page=100`,
    {
      headers: getGitHubHeaders(),
      next: { revalidate: 300 },
    }
  )

  if (!response.ok) {
    return null
  }

  const contributors = (await response.json()) as GitHubRepoContributor[]

  if (!Array.isArray(contributors)) {
    return null
  }

  const filtered = contributors
    .filter((entry) => entry.type !== 'Bot')
    .map((entry) => ({
      id: entry.id,
      login: entry.login,
      avatar_url: entry.avatar_url,
      html_url: entry.html_url,
      contributions: entry.contributions,
    }))

  return normalizeContributors(filtered)
}

export async function GET() {
  try {
    const statsContributors = await fetchStatsContributors()
    if (statsContributors && statsContributors.length > 0) {
      return NextResponse.json({ contributors: statsContributors, source: 'stats' })
    }

    const repoContributors = await fetchRepoContributors()
    if (repoContributors && repoContributors.length > 0) {
      return NextResponse.json({ contributors: repoContributors, source: 'contributors' })
    }

    return NextResponse.json({ contributors: FALLBACK_CONTRIBUTORS, source: 'fallback' })
  } catch {
    return NextResponse.json({ contributors: FALLBACK_CONTRIBUTORS, source: 'fallback' })
  }
}

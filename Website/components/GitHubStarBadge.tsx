// Server component — fetches star count from GitHub at build/request time
async function getStarCount(): Promise<number> {
  try {
    const res = await fetch('https://api.github.com/repos/Sahnik0/CodeTwin', {
      next: { revalidate: 3600 }, // re-fetch every hour
      headers: {
        Accept: 'application/vnd.github.v3+json',
      },
    })
    if (!res.ok) return 0
    const data = await res.json()
    return data.stargazers_count ?? 0
  } catch {
    return 0
  }
}

function formatStars(n: number): string {
  if (n >= 1000) return `${(n / 1000).toFixed(1)}k`
  return String(n)
}

export default async function GitHubStarBadge() {
  const stars = await getStarCount()

  return (
    <a
      href="https://github.com/Sahnik0/CodeTwin"
      target="_blank"
      rel="noopener noreferrer"
      className="inline-flex items-center gap-2 px-4 py-2 rounded-lg border border-border-default bg-surface-elevated hover:border-border-hover transition-colors duration-200 group"
      aria-label={`View CodeTwin on GitHub — ${stars} stars`}
    >
      {/* GitHub icon */}
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width={15}
        height={15}
        viewBox="0 0 24 24"
        fill="currentColor"
        className="text-text-secondary group-hover:text-text-primary transition-colors"
        aria-hidden="true"
      >
        <path d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0 1 12 6.844a9.59 9.59 0 0 1 2.504.337c1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.02 10.02 0 0 0 22 12.017C22 6.484 17.522 2 12 2z" />
      </svg>

      <span className="text-sm text-text-secondary group-hover:text-text-primary transition-colors font-medium">
        Star on GitHub
      </span>

      {/* Separator */}
      <span className="w-px h-4 bg-border-default" />

      {/* Star count */}
      <span className="flex items-center gap-1 text-sm font-mono text-text-muted">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          width={12}
          height={12}
          viewBox="0 0 24 24"
          fill="#f59e0b"
          aria-hidden="true"
        >
          <polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2" />
        </svg>
        {formatStars(stars)}
      </span>
    </a>
  )
}

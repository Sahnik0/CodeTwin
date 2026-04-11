import type { Permission } from "./index"

export type DependenceLevel = 1 | 2 | 3 | 4 | 5

function deny(permission: string): Permission.Rule {
  return { permission, pattern: "*", action: "deny" }
}

function allow(permission: string): Permission.Rule {
  return { permission, pattern: "*", action: "allow" }
}

function ask(permission: string): Permission.Rule {
  return { permission, pattern: "*", action: "ask" }
}

const READ_ONLY_PERMISSIONS = ["read", "list", "glob", "grep", "codesearch", "websearch", "webfetch", "lsp", "skill"]

const WRITE_LIKE_PERMISSIONS = ["edit", "write", "multiedit", "patch", "bash", "task", "todowrite", "external_directory"]

const DESTRUCTIVE_PERMISSIONS = ["bash", "edit", "write", "multiedit", "patch", "task", "external_directory", "workflow_tool_approval", "doom_loop"]

export function rules(level?: number): Permission.Ruleset {
  if (!level) return []

  if (level === 1) {
    return [ask("*")]
  }

  if (level === 2) {
    return [
      ...READ_ONLY_PERMISSIONS.map(allow),
      ...WRITE_LIKE_PERMISSIONS.map(ask),
      ask("workflow_tool_approval"),
      ask("doom_loop"),
      deny("question"),
    ]
  }

  if (level === 3) {
    return [
      allow("*"),
      ask("question"),
      ask("workflow_tool_approval"),
      ask("doom_loop"),
    ]
  }

  if (level === 4) {
    return [
      allow("*"),
      ...DESTRUCTIVE_PERMISSIONS.map(ask),
      deny("question"),
    ]
  }

  if (level === 5) {
    return [allow("*"), deny("question")]
  }

  return []
}

export function isDependenceLevel(input: number): input is DependenceLevel {
  return input >= 1 && input <= 5
}

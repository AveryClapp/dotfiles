# Global Engineering Guidance

Work from the repository's own instructions and tooling before applying these
defaults. Keep changes scoped, preserve unrelated user work, and verify behavior
with the narrowest relevant checks before reporting completion.

## Working Style

- Work in the current checkout. Do not create worktrees, branches, tmux
  sessions, or task trackers to organize your own work unless the user asks.
- Delegate only self-contained side work, such as research, a focused review,
  or an independent search, to headless subagents that report back. Keep
  integration and the final diff in your own session.
- A reviewer reports findings and does not edit the code under review.

## Beads

- When a repository contains `.beads/`, use it as the backlog for work that
  outlives the session: check `bd ready` for existing work, and record deferred
  follow-ups as Beads instead of TODO files.
- Do not create Beads for routine steps or for defects fixed in the same change.
- Do not initialize Beads in a repository that lacks `.beads/` unless the user
  asks.

## Safety And Verification

- Do not disable sandboxing or approval checks by default.
- Never expose credentials, SSH material, keychains, or unrelated home files.
- Treat destructive-command hooks as guardrails, not as a security boundary.
- Prefer `just check` when the repository provides it, then fall back to its
  native test or check command. Report commands that could not be run.
- Do not merge or push unless the user explicitly requests it.

## Tool Selection

- Use `ast-grep` for syntax-aware searches or mechanical rewrites when text
  matching would be ambiguous.
- Use `agent-browser` for browser interaction and visual verification when it is
  installed; take a fresh accessibility snapshot after page changes.
- Use `cass search --robot` when relevant knowledge may exist in a prior coding
  agent session. Never run bare `cass` from a non-interactive agent.

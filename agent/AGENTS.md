# Global Engineering Guidance

Work from the repository's own instructions and tooling before applying these
defaults. Keep changes scoped, preserve unrelated user work, and verify behavior
with the narrowest relevant checks before reporting completion.

## Task State

- When a repository contains `.beads/`, run `bd prime` before substantial work.
- Use `bd ready`, `bd show <id>`, `bd update <id> --claim`, and `bd close <id>`.
- Use `bd remember` for durable project knowledge instead of ad hoc memory files.
- Keep task state in Beads and implementation evidence in commits and test output.

## Parallel Work

- Use one Git worktree per independent task or agent.
- Parallelize only work with clear ownership boundaries.
- Before editing shared files, check Agent Mail reservations when it is available.
- Use the Bead ID as the worktree handle, mail thread ID, and commit reference.
- Keep review independent: a reviewer reports findings and does not silently alter
  the implementation under review.

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

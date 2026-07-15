# Global Engineering Guidance

Work from the repository's own instructions and tooling before applying these
defaults. Keep changes scoped, preserve unrelated user work, and verify behavior
with the narrowest relevant checks before reporting completion.

## Beads Control Plane

- When a repository contains `.beads/`, Beads is the authoritative source for
  tasks, bugs, priorities, dependencies, follow-ups, and durable project memory.
- Run `bd prime` at session start, then use `bd ready`, `bd show <id>`,
  `bd update <id> --claim`, and `bd close <id>` around implementation work.
- Do not begin substantial untracked work in a Beads repository. Create and claim
  a Bead first when the user request does not already have one.
- When any defect is discovered, immediately create a bug Bead before continuing:
  `bd create "Bug: <concise title>" -t bug`. Link it with
  `--deps discovered-from:<current-id>` when working from another Bead. Do this
  even when the defect will be fixed in the current session, then close it only
  after verification.
- Record every deferred improvement or follow-up as a Bead. Do not use markdown
  TODO files, private agent task lists, or chat context as a competing tracker.
- Use `bd remember` for durable project knowledge instead of ad hoc memory files.
- Do not initialize Beads in a repository that lacks `.beads/` unless the user or
  repository explicitly requests it; `agent init` can add project files and an
  initialization commit.

## Parallel Work

- Use one Git worktree per independent task or agent.
- Parallelize only work with clear ownership boundaries.
- Before editing shared files, check Agent Mail reservations when it is available.
- Use the Bead ID as the worktree handle, mail thread ID, and commit reference.
- Create child Beads before dispatching independent Claude or Codex workers, and
  preserve parent or `discovered-from` relationships in the Beads graph.
- Keep review independent: a reviewer reports findings and does not silently alter
  the implementation under review. Reviewers create bug Beads for actionable
  defects before reporting them.

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

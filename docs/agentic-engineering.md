# Agentic Engineering Workflow

This repository keeps the manual and agentic environments in one source tree.
The shell, Git, tmux, Neovim, and navigation config stay shared; profiles only
control which additional programs and configuration are installed.

## Profiles

| Profile | Base environment | Agent tools | GUI terminal |
|---|---|---|---|
| `full` | Full workstation | No | Alacritty |
| `ssh` | Terminal-only | No | None |
| `agent` | Terminal-only | Yes | None |
| `agent-workstation` | Full workstation | Yes | Alacritty and Ghostty |

`--agent` is composable with the existing profiles. For example,
`--profile ssh --agent` adds the agent layer to an SSH installation. `--ghostty`
adds Ghostty without removing Alacritty.

```bash
# Headless or SSH host
./setup_config.sh --profile agent

# Local workstation, preserving the existing manual environment
./setup_config.sh --profile agent-workstation

# User-space installation where possible
./setup_config.sh --profile agent --no-sudo

# Config only, no package installation
./setup_config.sh --profile agent --skip-packages

# Preview
./setup_config.sh --profile agent-workstation --dry-run
```

Agent profiles install Beads, workmux, Destructive Command Guard, and MCP Agent
Mail. They also install CASS, ast-grep, gitleaks, Lefthook, just, mise, language
servers, and the focused Claude plugin set when Claude is present. Use
`--skip-agent-mail`, `--skip-dcg`, `--skip-personal-skills`, or
`--skip-claude-plugins` to omit an integration.

## Skill Packs

The personal repository at `github.com/AveryClapp/agent-skills` is cloned to the
sibling `../agent-skills` path by default and published to both Claude Code and Codex.
Third-party packs are optional:

| Pack | Contents | Download impact |
|---|---|---|
| `general` | `grill-with-docs`, `domain-modeling`, `codebase-design`, `prototype`, `handoff`, `resolving-merge-conflicts` | Default, text only |
| `web` | `vercel-react-best-practices`, `web-design-guidelines`, `agent-browser` | Downloads Chromium |
| `security` | Cloudflare's `security-audit` | Text and validation scripts |
| `research` | Matt Pocock's primary-source `research` workflow | Text only |

```bash
# General is automatic for agent profiles
./setup_config.sh --profile agent

# Repeat packs or install all of them
./setup_config.sh --profile agent-workstation \
  --skill-pack web --skill-pack security
./setup_config.sh --profile agent-workstation --skill-pack all

# Keep only personal skills; skip third-party packs
./setup_config.sh --profile agent --skill-pack none

# Skip the personal repo as well
./setup_config.sh --profile agent --skill-pack none --skip-personal-skills
```

## Architecture

```text
Beads task
  -> agent-new
  -> workmux worktree + tmux window
  -> Codex or Claude
  -> checks + independent review
  -> explicit agent-land
```

Beads is the centralized control plane and owns tasks, bugs, priorities,
dependencies, follow-ups, and durable project memory. Workmux owns worktree and
tmux lifecycle. Agent Mail owns messages and advisory file reservations. Git
owns source history. The identifier should match across all four systems.

## First Project Setup

Run this once inside each project that should use the workflow:

```bash
agent doctor
agent init
```

`agent-init` initializes Beads, installs its detected Codex/Claude integration,
installs tools from an existing `.mise.toml`, activates an existing Lefthook
configuration, adds the centralized Beads policy to project `AGENTS.md` and
`CLAUDE.md`, and configures workmux status hooks and skills. Beads Git hooks
are deliberately off by default so `git push` has no hidden Beads work; use
`agent-init --beads-git-hooks` only when the repository wants Beads' full Git
lifecycle integration. Pass `--no-tooling` to skip mise and Lefthook. On a
repository where Beads state must remain private, use `agent-init --stealth`;
this skips project hooks and agent-specific project files.

The agent profile does not initialize Beads automatically. Repository metadata
should be an explicit project decision.

`agent init` is idempotent and can be rerun in an existing project. It refreshes
the managed Beads integrations and replaces the dotfiles-owned policy blocks
without overwriting project-specific instructions outside those markers. The
first initialization of a repository without `.beads/` may add Beads metadata
and an initialization commit. `agent init` therefore requires a clean worktree
for the first normal initialization; commit or stash current changes, or use
`--stealth` when Beads state must remain local.

The unified `agent <command>` dispatcher maps to the underlying hyphenated
commands, so `agent doctor`, `agent new`, and `agent status` are equivalent to
`agent-doctor`, `agent-new`, and `agent-status`. Both forms remain supported.

## Daily Workflow

Create and inspect work:

```bash
bd create "Implement token refresh" -p 1 -t feature
bd ready
agent-new bd-a1b2
```

`agent-new` claims a Bead before launching its worktree. With no argument, it
offers an `fzf` picker over ready tasks. In a repository with `.beads/`, create
and claim a Bead before substantial work. The branch-only form is for repositories
that have not adopted Beads:

```bash
agent-new fix-timeout --agent codex --prompt "Fix the timeout and add regression tests"
agent-new docs-refresh --agent claude --layout solo --prompt-editor
```

Discovered defects and deferred work go into Beads immediately:

```bash
bd create "Bug: refresh token survives logout" -t bug \
  --deps discovered-from:bd-a1b2
bd create "Split cache migration" -t task --parent bd-a1b2
```

Create child Beads before dispatching independent workers. Any Claude or Codex
session can launch another worker without surrendering its own pane:

```bash
agent new <child-id> --agent claude --background
agent new <child-id> --agent codex --background
```

Each worker has an independent model context and worktree. The parent monitors
Beads for authoritative state, uses Agent Mail for coordination, and uses
`agent status`, `agent capture`, or `agent send` for tmux-level observation and
intervention. Do not use private model task lists as a second source of truth.

Inspect and communicate:

```bash
agent-status
agent-status --dashboard
agent-send %42 "Run the focused integration test and report the result"
agent-capture %42 250
```

Review and land:

```bash
agent-review bd-a1b2
agent-check
bd close bd-a1b2 "Implemented and verified"
agent-land
agent-gc
```

`agent-land` runs `agent-check` and then performs a workmux rebase merge. It never
runs automatically. Set `AGENT_CHECK_COMMAND` per machine or project when the
conventional detector does not select the right command.

`agent-check` prefers `just check`, then repository scripts, Make, and native
language test commands. This repository's Lefthook configuration scans staged
changes with gitleaks at commit time. There is deliberately no pre-push hook, so
network operations do not inherit a hidden test-suite delay.

This repository's `just check` parses shell, TOML, and tmux configuration, runs
ShellCheck, compiles every Neovim Lua file, and scans the current tracked and
untracked non-ignored tree with gitleaks. It does not scan Git-ignored local
credential files. Install or refresh the hook with `just hooks`.

## Hooks

Four independent hook layers may be present, and only the first is a Git hook by
default:

| Layer | Trigger | Behavior |
|---|---|---|
| Lefthook | Git `pre-commit` | Runs gitleaks against staged content and blocks a commit that contains a secret. There is no `pre-push` job. |
| workmux agent hooks | Claude/Codex lifecycle events | Marks the tmux window working, waiting, or done. A Bash pre-tool hook invokes DCG to reject risky destructive commands. |
| Beads agent hooks | Session start, prompt submission, and context compaction | Loads or refreshes `bd prime` context inside an initialized project. `bd setup codex` and `bd setup claude` own these project-local hooks. |
| Beads Git hooks | Opt-in with `agent-init --beads-git-hooks` | Adds `pre-commit`, `post-merge`, `pre-push`, `post-checkout`, and commit-message integration for Beads synchronization and identity trailers. |

DCG is a guardrail, not a security boundary. It can stop a risky command before
the agent shell runs it, but it does not replace sandboxing, review, or backups.
The workmux status hooks only update tmux state; they do not run project tests.

Inspect or exercise hooks without pushing:

```bash
mise exec -- lefthook run pre-commit
git config --get core.hooksPath
bd hooks list
```

Remove previously installed Beads Git hooks with `bd hooks uninstall`. Do this
only after confirming the repository does not rely on them for Beads sync.

## Agent Mail

The agent profile installs a localhost user service and synchronizes the MCP
client entries for detected agents. It prefers port `8765`, selects another
local port when that port is occupied, and records the choice in
`~/.config/dotfiles/agent-mail-port`. On SSH or container hosts where native
user services are unavailable, it runs the server in a persistent tmux session
named `agent-mail-service`.

Agent Mail releases are validated by executing `am --version`. If the latest
GNU binary requires a newer glibc than an x86_64 Linux host provides, setup
falls back to the pinned static musl release configured by
`AGENT_MAIL_LINUX_X86_64_COMPAT_VERSION`.

Inspect or restart the service with:

```bash
am service status
am service restart
am setup status
tmux capture-pane -pt agent-mail-service
```

The server binds to localhost only. Use the Bead ID as the mail thread ID and
reservation reason. Reserve narrow file globs with finite leases, announce
interface changes, and release reservations at completion. A reservation is a
coordination mechanism, not a substitute for worktree isolation.

## tmux

The original manual workflow remains available:

| Key | Action |
|---|---|
| `prefix + w` | Existing manual branch/worktree sessionizer |
| `prefix + W` | Select/claim task and launch an agent worktree |
| `prefix + g` | workmux agent dashboard |
| `prefix + G` | Jump to the latest completed/waiting agent |
| `prefix + Tab` | Toggle between the two most recent agents |

workmux status is included in the existing window format. The tmux status poll is
five seconds rather than one second to keep idle fleet overhead modest.

## Shared Instructions And Skills

Personal skill source is the separate Git repository:

```text
../agent-skills/skills/
```

Setup clones it only when the sibling repo is absent; it never auto-pulls or
overwrites local skill edits. Install and sync link every personal skill into the
shared `~/.agents/skills` catalog, then publish that catalog under
`~/.claude/skills` and `~/.codex/skills`. Existing non-symlink client-specific
skills are preserved. List or update third-party skills with `npx skills list -g`
and `npx skills update -g`.

Claude Code receives Pyright, TypeScript, and Lua language servers and their LSP
plugins, plus skill-creator and the PR review toolkit. `plugin-dev` is installed
but disabled until explicitly needed. The large `academic-research-skills`
plugin is also disabled by default; the lightweight portable `research` skill is
available without its always-on context cost.

## Search And Verification

Search prior local agent work without opening an interactive TUI:

```bash
cass search "authentication timeout" --robot --limit 5 --fields minimal
```

Use `ast-grep` when syntax matters, and the normal `rg` path for text. The web
pack installs `agent-browser`; its reliable loop is open, snapshot, act by stable
element reference, then snapshot again after the page changes.

The shell loads cached completions for mise, just, and CASS. `mise` activates
exact project tool versions from `.mise.toml`, while `just` remains the stable
human/agent command surface.

Codex global guidance is generated from `agent/AGENTS.md`. Machine-local additions
belong in `~/.config/dotfiles/agent.local.md`; sync preserves that file and appends
it to the generated `~/.codex/AGENTS.md`.

Project instructions still take precedence. Put project commands, architectural
rules, and acceptance criteria in the project rather than the global dotfiles.

## Ghostty

The workstation profile installs Ghostty alongside Alacritty. It enables shell
integration, inherited working directories, SSH terminfo support, a global
quick-terminal shortcut (`Cmd+backquote`), and notifications for unfocused
commands that run longer than ten seconds.

Machine-local Ghostty overrides belong in
`~/.config/dotfiles/ghostty.local`; synchronization preserves that file.

macOS asks for Accessibility permission when the global quick-terminal shortcut
is first used. Ghostty is not installed by the CLI-only agent profile.

## Upstream Components

- [Beads](https://github.com/gastownhall/beads)
- [workmux](https://github.com/raine/workmux)
- [MCP Agent Mail](https://github.com/Dicklesworthstone/mcp_agent_mail_rust)
- [Destructive Command Guard](https://github.com/Dicklesworthstone/destructive_command_guard)
- [Agent Skills](https://agentskills.io/specification)
- [Ghostty](https://ghostty.org/docs)

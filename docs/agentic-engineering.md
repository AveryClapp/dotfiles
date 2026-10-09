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

Agent profiles install Beads, Destructive Command Guard, CASS, ast-grep,
gitleaks, Lefthook, just, mise, language servers, and the focused Claude plugin
set when Claude is present. Use `--skip-dcg`, `--skip-personal-skills`, or
`--skip-claude-plugins` to omit an integration.

## How Agents Work Here

Agents work in the current checkout and delegate self-contained side work, such
as research or an independent review, to headless subagents that report back.
The dotfiles deliberately do not add worktree orchestration, inter-agent
messaging, or tmux fleet management: coordinating many worktrees costs more
than it saves. The global rules live in `agent/AGENTS.md`.

Beads is installed for projects that keep a `.beads/` backlog. Agents use it for
work that outlives a session, not as a per-step tracker. To adopt it in a
project, run `bd init` and, if wanted, `bd setup claude` or `bd setup codex`.

`agent-check` runs a repository's verification contract. It prefers
`just check`, then repository scripts, Make, and native language test commands.
Set `AGENT_CHECK_COMMAND` per machine or project when the conventional detector
does not select the right command. `agent-doctor` checks the installed agent
tools, skills, and plugins.

This repository's `just check` parses shell, TOML, and tmux configuration, runs
ShellCheck, compiles every Neovim Lua file, and scans the current tracked and
untracked non-ignored tree with gitleaks. It does not scan Git-ignored local
credential files. Install or refresh the hook with `just hooks`.

## Skill Packs

The personal repository at `github.com/AveryClapp/agent-skills` is cloned to the
sibling `../agent-skills` path by default and published to both Claude Code and Codex.
Third-party packs are optional:

| Pack | Contents | Download impact |
|---|---|---|
| `general` | `grill-with-docs`, `domain-modeling`, `codebase-design`, `handoff`, `resolving-merge-conflicts` | Default, text only |
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

Every installed skill's description loads into each agent session, so keep the
set small and avoid skills that duplicate each other or built-in features.

## Hooks

Three independent hook layers may be present, and only the first is a Git hook
by default:

| Layer | Trigger | Behavior |
|---|---|---|
| Lefthook | Git `pre-commit` | Runs gitleaks against staged content and blocks a commit that contains a secret. There is no `pre-push` job. |
| DCG | Claude Code Bash pre-tool hook | Rejects risky destructive commands before the agent shell runs them. |
| Beads | Opt-in per project with `bd setup` or `bd hooks install` | Agent hooks refresh `bd prime` context; Git hooks synchronize Beads state on commit and push. |

DCG is a guardrail, not a security boundary. It can stop a risky command before
the agent shell runs it, but it does not replace sandboxing, review, or backups.

Inspect or exercise hooks without pushing:

```bash
mise exec -- lefthook run pre-commit
git config --get core.hooksPath
bd hooks list
```

Remove previously installed Beads Git hooks with `bd hooks uninstall`. Do this
only after confirming the repository does not rely on them for Beads sync.

## Shared Instructions And Skills

Personal skill source is the separate Git repository:

```text
../agent-skills/skills/
```

Setup clones it when absent and fast-forwards it when the checkout is clean.
Local edits or divergent history are preserved and produce a warning instead of
being reset, stashed, or overwritten. Install and sync link every personal skill
into the shared `~/.agents/skills` catalog, then publish that catalog under
`~/.claude/skills` and `~/.codex/skills`. Existing non-symlink client-specific
skills are preserved. List or update third-party skills with `npx skills list -g`
and `npx skills update -g`.

Claude Code receives Pyright, TypeScript, and Lua language servers and their LSP
plugins, plus the PR review toolkit. Claude already ships `skill-creator`, so the
plugin copy is not installed. `plugin-dev` is installed but disabled until
explicitly needed. The large `academic-research-skills` plugin is also disabled
by default; the lightweight portable `research` skill is available without its
always-on context cost.

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
- [Destructive Command Guard](https://github.com/Dicklesworthstone/destructive_command_guard)
- [Agent Skills](https://agentskills.io/specification)
- [Ghostty](https://ghostty.org/docs)

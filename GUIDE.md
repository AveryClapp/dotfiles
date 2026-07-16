# Config Guide

A C++/Rust/Python development environment built on Neovim + Tmux + Bash with Kanagawa Wave theme.

---

## Shell

Sync repository changes to the active machine with `make sync`, or preview them
with `make sync ARGS="--dry-run"`. Remote machines can use
`make sync ARGS="--ssh"`. Put host-specific paths and helper functions in
`~/.config/dotfiles/local.bash`; this file is sourced last and never overwritten.

Run `dotfiles-doctor` after syncing to check completion, Git helpers, binary
architecture, nested repositories, missing commands, and config drift.

Agent hosts use `make agent-sync` or
`make sync ARGS="--profile agent-workstation"`. Run `agent doctor` after syncing.
Use `--skill-pack all` during installation for the complete general, web,
security, and research skill set. Config-only sync preserves installed external
skills. Personal skills come from the separate sibling `../agent-skills` repo, are linked
through `~/.agents/skills`, and are published to Claude and Codex. Existing
client-specific skill directories are preserved.

### Aliases
| Alias | Expands to |
|-------|-----------|
| `ls` / `ll` / `lt` / `la` | eza with color, icons, grouped dirs |
| `v` / `vim` | nvim |
| `ta` / `tn` / `tl` / `tk` | tmux attach/new/list/kill-session |
| `gs` / `gd` / `ga` / `gc` / `gp` | git status/diff/add/commit/push |
| `gl` | git log --oneline --graph --decorate |
| `gco` / `gb` | git checkout / git branch |
| `lg` | lazygit |
| `..` / `...` / `....` | cd up 1/2/3 levels |
| `cd ...` / `cd ....` | cd up 2/3 levels, even when used as an argument |
| `up 3` | cd up N levels |
| `j <query>` / `ji` | zoxide jump / interactive zoxide jump |
| `mkcd <dir>` | mkdir -p and cd into it |
| `croot` | jump to the current git repo root |

### fzf Functions
| Command | Action |
|---------|--------|
| `fcd` | Fuzzy cd into any directory |
| `fv` | Fuzzy find file and open in nvim |
| `fkill` | Fuzzy pick and kill a process |
| `fbr` | Fuzzy git branch checkout |
| `flog` | Fuzzy git log with diff preview |
| `Ctrl+R` | Fuzzy search shell history |

### zoxide
`z <partial>` or `j <partial>` — jump to any recently visited directory by fuzzy match. `zi` / `ji` opens the interactive picker. Replaces manual long-path `cd` for anything beyond one level.

### bat
`bat <file>` — syntax-highlighted file viewer. Automatically used as MANPAGER.

### Bash extras
- **sudo toggle** — double-tap `Esc` to prepend or strip `sudo`
- **smart cd** — `cd ...`, `cd ....`, `up 4`, `mkcd`, and `croot`
- **fast fuzzy cd** — `fcd` uses `fd` without following symlink trees and skips heavy build/dependency dirs

### entr — file watcher
Pipe a list of files into `entr` and it re-runs a command whenever any of them change. Uses `git ls-files` to watch only tracked files:

```bash
watch-make          # git ls-files | entr -c make
watch-cargo         # git ls-files | entr -c cargo run
watch-test          # git ls-files | entr -c cargo test
```

Custom usage:
```bash
git ls-files | entr -c ./my_binary        # re-run binary on any change
ls *.py      | entr -c python main.py     # Python
echo main.cpp | entr -c 'make && ./sol'   # watch a single file
```
`-c` clears the screen before each run. `entr` exits cleanly with `Ctrl+C`.

### btop
`top` — full system monitor. CPU, memory, processes, network, disk IO in one view. Better than htop.

### hyperfine
`bench <command>` — statistical benchmarking with warmup runs, min/max/mean, and outlier detection.
```bash
bench './my_binary'
bench --warmup 5 './my_binary arg1'
bench 'make' 'ninja'    # compare two build systems
```

### tldr
`help <command>` — practical examples instead of full man pages.
```bash
help git rebase
help rsync
help entr
```

### direnv
Drop a `.envrc` in any project directory and it auto-loads when you `cd` in, unloads when you leave:
```bash
# .envrc
export DATABASE_URL=postgres://localhost/mydb
export API_KEY=dev-key-123
export PATH="$PWD/scripts:$PATH"
layout python   # activate .venv automatically
```
Run `direnv allow` once to trust a new `.envrc`. After that it's automatic.

### ssh-agent
Agent starts once on first terminal open and persists via `~/.ssh/agent.env`. Every subsequent terminal reuses the same socket — enter your passphrase once per reboot, never again mid-session.

### Tab Completion
- `TAB` — complete + show visible list of all matches
- `Shift+TAB` — cycle forward through completions
- Case-insensitive, `-` and `_` treated as equivalent
- Arrow keys search history by typed prefix (not full history scroll)

---

## Tmux

### Agent Workflow

The existing manual `prefix+w` flow remains available. Agent profiles add a
parallel workmux flow:

| Command / key | Action |
|---|---|
| `agent <command>` | Unified dispatcher; `agent-doctor` style commands remain available |
| `agent-init` | Initialize Beads without adding a Git pre-push hook |
| `agent-init --beads-git-hooks` | Opt into Beads commit/push lifecycle hooks |
| `agent-new <id>` / `prefix+W` | Claim a task and launch an isolated agent worktree |
| `bd create "Bug: ..." -t bug` | Immediately record a discovered defect in the central task graph |
| `agent-status` / `prefix+g` | List worktrees or open the agent dashboard |
| `agent ntm ...` | Use the optional NTM fleet dashboard and pane operator commands |
| `agent-send %42 text` | Safely send literal text to a stable tmux pane ID |
| `agent-review <branch>` | Launch an independent, non-editing review worktree |
| `agent-land` | Run project checks, rebase-merge, and clean up |
| `agent-gc` | Prune merged remote worktrees and stale Claude entries |
| `just check` | Run the same deterministic verification contract used by agents |
| `just security` | Scan tracked and untracked, non-ignored files for secrets |
| `just hooks` | Install the staged-secret pre-commit hook; no pre-push hook |
| `cass search QUERY --robot` | Search local history across coding agents |

See [docs/agentic-engineering.md](docs/agentic-engineering.md) for profiles,
Agent Mail coordination, shared skills, and the complete lifecycle.

### Sessionizer
`prefix+f` — fuzzy-find any project under `~/Documents/Coding` and jump to a dedicated tmux session for it. If the session doesn't exist it's created with the working directory set to the project root. If it does exist you switch to it instantly.

Each project gets its own session, so you can have `pulse`, `dotfiles`, and `onyx` all running simultaneously with their own windows, panes, and history. Switch between them in one keypress.

### Worktree Sessionizer
`prefix+w` — pick a branch from the current repo, get a dedicated tmux session and git worktree for it at `~/worktrees/<repo>-<branch>`. Type a new branch name to create it.

The key insight: your `main` session keeps running untouched. The worktree is a full separate checkout — different directory, own session, own nvim, own build artifacts. No stashing, no branch switching mid-thought.

```
Working on pulse/main when a hotfix is needed:
  prefix+w → type "hotfix/auth" → enter
  → ~/worktrees/pulse-hotfix-auth created
  → new tmux session "pulse-hotfix-auth" opened
  → fix the bug, push
  prefix+f → pulse → back to feature work, nothing disturbed
```

Clean up when done: `git worktree remove ~/worktrees/<name>`

### Session Persistence (tmux-resurrect)
| Key | Action |
|-----|--------|
| `prefix + Ctrl+s` | Save all sessions, windows, and panes to disk |
| `prefix + Ctrl+r` | Restore everything after a reboot |

Save before shutting down. Restore after booting. Your entire tmux layout comes back exactly as you left it.

### Pane Management
| Key | Action |
|-----|--------|
| `prefix + arrows` | Switch panes (hold prefix, spam arrows) |
| `prefix + hjkl` | Enter resize mode — spam hjkl freely, `Esc` to exit |
| `Alt + Left/Right` | Switch windows |

---

## Navigation

### Flash — instant jump anywhere
| Key | Action |
|-----|--------|
| `s` | Jump to any location (normal/visual/operator) |
| `<leader>S` | Jump to any **treesitter node** by type (function, argument, block, etc.) |
| `r` (operator) | Remote flash — operate on text far away without moving cursor |
| `R` (visual/operator) | Treesitter search across the file |

`ys<flash-motion>` to surround a distant target. `d<flash-motion>` to delete it. `r` in operator mode is the most powerful: `yr<flash>` yanks text anywhere on screen.

### Harpoon — persistent file bookmarks
| Key | Action |
|-----|--------|
| `<leader>a` | Mark current file |
| `<leader>h` | Open mark menu |
| `<leader>1-4` | Jump to marked file 1–4 |

### Zoxide (terminal) — `z <query>` to jump to any recently visited directory.

### Oil — edit the filesystem like a buffer
Press `-` to open the parent directory. Rename, move, delete files by editing the buffer and saving with `:w`. `<CR>` to open, `-` to go up, `g.` toggles hidden files.

### Telescope
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fr` | Recent files |
| `<leader>fb` | Open buffers |

### Aerial — code outline
| Key | Action |
|-----|--------|
| `<leader>o` | Toggle outline sidebar |
| `[s` / `]s` | Jump prev/next symbol |

---

## Editing

### Motion
| Key | Action |
|-----|--------|
| `w` / `e` / `b` / `ge` | Subword-aware (stops at camelCase/snake_case boundaries) |
| `H` / `L` | Line start / end |
| `J` / `K` | Jump 10 lines down/up |
| `s` | Flash jump |

### Text Objects
Three layers stack on top of each other:

**mini.ai** (treesitter-aware):
- `af` / `if` — around/inside function
- `ac` / `ic` — around/inside class
- Standard `a(` `i"` etc. but whitespace-aware

**targets.vim** (next/last + separators):
- `cin,` — change inside next comma argument
- `vin)` — visual inside next parens
- `cil)` — change inside last parens
- Works for `, . ; : + - = ~ _ * # / | \`

**Treesitter textobjects** (select mode):
- `af` / `if`, `ac` / `ic` — same as mini.ai but treesitter-driven

### Surround (`nvim-surround`)
- `ys<motion><char>` — add: `ysiw)` wraps word in `()`
- `ds<char>` — delete: `ds"` removes quotes
- `cs<old><new>` — change: `cs'"` swaps `'` → `"`
- Visual `S<char>` wraps selection

### Macros (`nvim-recorder`)
Replaces the default `q` with named slots:
| Key | Action |
|-----|--------|
| `q` | Start/stop recording (current slot) |
| `Q` | Play macro |
| `<C-q>` | Cycle slots (a → b → c → d) |
| `cq` | Edit macro as text in a buffer |
| `yq` | Yank macro as string |
| `##` | Insert breakpoint (pauses playback) |

### Split / Join (`treesj`)
| Key | Action |
|-----|--------|
| `gS` | Split block to multiline |
| `gJ` | Join block to single line |
| `gM` | Toggle split/join |

Works on function args, arrays, objects, conditions — anything treesitter understands.
`{a, b, c}` → `gS` → three-line block. `gJ` collapses it back.

### Search & Replace
| Key | Action |
|-----|--------|
| `<leader>sr` | grug-far — project-wide regex search/replace with live preview |
| `<leader>sw` | Search word under cursor |
| `<leader>sR` | SSR — structural search & replace using treesitter patterns |

SSR is the power tool: search for `foo(___) + bar(___)` and replace with `baz(___)` — matches actual code structure, not text.

---

## LSP

Servers managed by Mason: **clangd**, **rust_analyzer**, **pyright**, **lua_ls**.

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find all references (Telescope) |
| `gh` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol (live preview as you type) |
| `]d` / `[d` | Next/prev diagnostic |
| `<leader>e` | Float diagnostic message |

Install new servers: `:Mason`

Format on save is automatic. Formatters by language:
- C/C++ → `clang_format`
- Rust → `rustfmt`
- Python → `ruff_format`
- Lua → `stylua`

---

## Diagnostics & Trouble

| Key | Action |
|-----|--------|
| `<leader>xx` | All project diagnostics |
| `<leader>xX` | Current buffer diagnostics |
| `<leader>xs` | Symbol list |
| `<leader>xr` | LSP references panel |
| `<leader>xq` | Quickfix list |
| `<leader>xl` | Location list |

---

## Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Open Neogit (full git UI) |
| `<leader>gd` | Diffview — side-by-side diff |
| `<leader>gh` | Diffview file history |
| `<leader>gp` | Preview hunk inline |

Neogit is Magit-style: stage hunks, commit, push, branch all from inside nvim.
Diffview supports `]c` / `[c` to jump between diff hunks.

---

## C++ Specific

### Debug (DAP + codelldb)
| Key | Action |
|-----|--------|
| `<F5>` | Start/continue |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>b` | Toggle breakpoint |
| `<leader>B` | Conditional breakpoint |
| `<leader>du` | Toggle DAP UI |

### CMake
| Key | Action |
|-----|--------|
| `<leader>cg` | Generate |
| `<leader>cb` | Build |
| `<leader>cr` | Run |
| `<leader>cd` | Debug |
| `<leader>ct` | Run tests |
| `<leader>cs` | Select build type |

### Other
| Key | Action |
|-----|--------|
| `<leader>hh` | Switch header ↔ source |
| `<leader>nc` | Generate doxygen comment |

### Competitive Programming (cpp files only)
| Key | Action |
|-----|--------|
| `<leader>tc` | Receive problem (competitive companion) |
| `<leader>tr` | Run test cases |
| `<leader>ta` | Add test case |
| `<leader>te` | Edit test case |
| `<leader>tS` | Submit |

---

## Rust Specific

| Key | Action |
|-----|--------|
| `<leader>rr` | Runnables |
| `<leader>rd` | Debuggables |
| `<leader>re` | Explain error (full rustc output) |

Clippy runs on save. Inlay hints enabled by default.

---

## Testing (neotest)

Supports C++ (gtest) and Rust (cargo test).

| Key | Action |
|-----|--------|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run all tests in file |
| `<leader>ts` | Toggle test summary panel |

---

## Tasks (Overseer)

| Key | Action |
|-----|--------|
| `<leader>oo` | Toggle task panel |
| `<leader>or` | Run task |

CMake uses Overseer as its executor — build output appears in the Overseer panel.

---

## Utilities

| Key | Action |
|-----|--------|
| `<leader>U` | Undotree (visual undo history — persistent across sessions) |
| `<leader>z` | Zen mode |
| `<leader>o` | Aerial outline |

**Todo comments** — `TODO`, `FIXME`, `HACK`, `NOTE`, `WARN` are highlighted in source.
Run `:TodoTelescope` to list all across the project.

**Which-key** — press `<leader>` and pause to see all available keybinds.

**Fidget** — LSP progress shown as a small spinner in the corner, non-intrusive.

**nvim-notify** — replaces `vim.notify` with animated pop-up notifications (compact, fade-in, bottom-right).

**Illuminate** — automatically highlights all occurrences of the word under the cursor.

**Indent Blankline** — `│` guides on every indent level; excluded on dashboard/lazy/mason.

**Treesitter Context** — pins the current function/class header at the top of the window when you scroll past it.

**Dressing** — upgrades `vim.ui.select` (code actions picker) and `vim.ui.input` (rename prompt) with a floating Telescope UI.

**Toggleterm** — `<leader>T` opens a persistent terminal at the bottom of the screen. State is preserved between toggles.

**Project-local config** — drop a `.nvim.lua` in any project root to define project-specific keymaps. Auto-sourced on open.

---

## Session Management

| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session for current directory |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Disable session save on exit |

Sessions are managed by `folke/persistence.nvim` and saved automatically on exit.

---

## Vim Fundamentals (high ceiling, no plugins)

### Marks
| Key | Action |
|-----|--------|
| `ma` | Set mark `a` at cursor |
| `'a` | Jump to line of mark `a` |
| `` `a `` | Jump to exact position of mark `a` |
| `'` / `` ` `` | Jump back to position before last jump |
| `:marks` | List all marks |

Use marks for positions you'll return to within a file. Harpoon for files, marks for positions inside files.

### Registers
| Register | Contains |
|----------|----------|
| `"0` | Last yank (not delete) |
| `"_` | Black hole — delete without clobbering clipboard |
| `"+` | System clipboard |
| `"a`–`"z` | Named registers (pair with macros) |
| `".` | Last inserted text |
| `"%` | Current filename |

`"_d` to delete without losing your yanked text. `"0p` to paste your last yank even after deletions.

### Power Commands
```
:g/pattern/command       " run command on every matching line
:g/TODO/norm @q          " run macro on every TODO line
:%norm A;                " append ; to every line
:g/^$/d                  " delete all blank lines
:v/pattern/d             " delete all lines NOT matching pattern
```

`:.,$s/old/new/g` — replace from current line to end of file.
`:'<,'>norm I//` — comment every line in visual selection with `norm`.

### Count Motions
```
3<C-a>     increment number under cursor by 3
g<C-a>     increment each line's number sequentially (visual mode)
5.         repeat last change 5 times
"2p        paste the second-to-last delete
```

---

## Adding Plugins

1. Create `lua/custom/plugins/<name>.lua`
2. Return a valid lazy.nvim spec
3. Restart nvim or run `:Lazy sync`

```lua
-- lua/custom/plugins/example.lua
return {
  'author/plugin-name',
  event = 'VeryLazy',       -- or: cmd = '...', ft = '...', keys = {...}
  config = function()
    require('plugin-name').setup {}
    vim.keymap.set('n', '<leader>X', '<cmd>PluginCmd<CR>', { desc = 'Do thing' })
  end,
}
```

Use `ft = { 'cpp', 'rust' }` to restrict to specific languages.
Use `keys = { { '<leader>X', mode = 'n' } }` for key-triggered lazy loading.

---

## Adding LSP Servers

Open `:Mason`, find the server, press `i` to install.
Then add it to `ensure_installed` in `lsp.lua`:

```lua
ensure_installed = { 'clangd', 'rust_analyzer', 'pyright', 'lua_ls', 'your_server' },
```

Add a formatter to `formatting.lua`:
```lua
your_ft = { 'your_formatter' },
```

---

## Philosophy & Priorities

This setup makes deliberate choices. Understanding them helps you use it at full depth.

### What this prioritizes

**Keyboard permanence** — every operation has a keyboard path. Mouse is optional everywhere. The entire workflow from opening a file to pushing a commit can be done without leaving the home row.

**Speed at scale** — different tools handle different scales of movement:
- Character → `f`/`t`/Flash `s`
- Word → nvim-spider `w`/`e`/`b`
- Line → `H`/`L`, `J`/`K` (10-line jumps)
- File → Harpoon `<leader>1-4`
- Project → Telescope `<leader>ff`/`<leader>fg`
- Directory → zoxide `z`

**Composability over shortcuts** — rather than `<leader>dw` (delete word), the setup teaches you `dw`, `diw`, `daw`, `dt,` — primitives that compose. Every new motion you learn multiplies all operators you know.

**C++ and Rust as first-class citizens** — clangd + CMake + DAP + codelldb for C++, rustaceanvim (not just lspconfig) for Rust. Both have full debug loops inside the editor.

**Git inside the editor** — Neogit + Diffview + gitsigns means you never need a separate git GUI. Stage hunks, resolve conflicts, browse history — all without leaving nvim.

**Minimal chrome** — fidget over a full LSP status bar, treesitter-context over always-visible breadcrumbs, notify over blocking messages. UI elements appear when relevant and disappear otherwise.

---

## Tool Synergies

Understanding how tools interact unlocks workflows that no single tool provides alone.

### Flash + operators
`s` is not just a jump — it's the most powerful motion. Every operator composes with it:
- `d<flash>` — delete to a distant target
- `c<flash>` — change a distant word
- `y<flash>` — yank from here to anywhere on screen
- `ys<flash>"` — surround a distant target with quotes
- `r` (operator mode) — operate on text anywhere without moving cursor at all

### Harpoon + marks
Two-layer spatial memory. Harpoon for files (persistent, up to 4), marks for positions inside files (26 slots per file, lost on close unless combined with `undofile`). Together: jump to the right file in one key, jump to the right line in one more.

### Telescope + everything
Telescope is the universal UI layer. It's not just file finding — LSP references (`gr`), diagnostics, git commits (`flog`), todo comments (`:TodoTelescope`), old files (`<leader>fr`), and open buffers (`<leader>fb`) all funnel through the same interface with the same keybinds.

### treesj + SSR + inc-rename
Structural refactoring stack:
1. `gS`/`gJ` — reshape code structure (inline vs multiline)
2. `<leader>sR` — find all instances of a structural pattern and replace them
3. `<leader>rn` — rename a symbol everywhere with live preview

These three together handle most refactors without a dedicated refactoring tool.

### fzf (shell) + Telescope (nvim)
Both use the same mental model — fuzzy type to filter. `fv` in the shell fuzzy-opens a file in nvim. Once in nvim, `<leader>ff` and `<leader>fg` continue the same pattern. The workflow is identical across shell and editor.

### zoxide + Oil
Two complementary navigation models. Zoxide (`z`) gets you to the right directory from anywhere based on frequency. Oil (`-`) gives you a filesystem buffer to navigate and edit structure once you're there. Together they replace `cd`/`ls`/`mv`/`mkdir` for most operations.

### gitsigns + Neogit + Diffview
Three git tools at three granularities:
- gitsigns — per-line hunk info inline, `<leader>gp` to preview a single change
- Neogit (`<leader>gg`) — stage/unstage/commit/push the full staging workflow
- Diffview (`<leader>gd`/`<leader>gh`) — side-by-side diffs and file history

### toggleterm + `.nvim.lua`
Toggleterm gives you a persistent shell inside nvim. `.nvim.lua` gives you project-specific keymaps. Together: define `<leader>mc` to compile in the terminal, `<leader>mr` to run — different per project, no global config pollution.

### DAP + Overseer
DAP handles interactive debugging (breakpoints, step through, inspect state). Overseer handles build tasks (CMake configure/build/run). For C++ the loop is: Overseer builds → DAP launches the binary → you debug. Both panels stay open side by side.

### Tmux + nvim focus-events
`focus-events on` in tmux means nvim's `autoread` triggers when you switch panes. Files edited outside nvim (by a build tool, a script, a git operation) are automatically reloaded when you switch back. No manual `:e!` needed.

---

## Acknowledged Tradeoffs

These are deliberate decisions with real costs. Not gaps — choices.

**No AI completion** — copilot/codeium would slot into the existing cmp pipeline trivially. The choice not to include it is intentional: AI completion trains you to read suggestions instead of write code. It's a productivity tool and a skill-atrophy tool simultaneously. Add it when you want it; the infra is ready.

**Mouse is de-prioritized** — mouse support is on in tmux and nvim, but the entire keymap assumes you won't use it. If you reach for the mouse you're slower, not faster.

**Python DAP not configured** — pyright + ruff is solid but no step-through debugger for Python. `print()` and `pdb` are fast enough for most Python work. Add `nvim-dap-python` if you need it.

**No snippet library beyond friendly-snippets** — LuaSnip is wired up and friendly-snippets is loaded. No custom snippets defined. Custom snippets have high ROI for repetitive patterns but require investment to write and maintain.

**Bash over zsh** — zsh has better interactive features out of the box. Bash is the correct choice when your code runs on Linux servers (bash is universal, zsh is not). The readline config in this setup closes most of the gap.

**Startup time** — 43 nvim plugins with lazy loading is fast but not instant. Everything is lazy-loaded by event/key/command. Cold start is ~80ms. If you need sub-10ms, remove plugins. The current set is calibrated for capability over raw startup speed.

**Terminal inside nvim vs tmux panes** — toggleterm exists for quick one-off commands. For real terminal work (long-running processes, multiple shells), use tmux panes. Don't try to replace tmux with toggleterm.

---

## Strengths

- **C++ is first-class**: clangd with background indexing and clang-tidy, DAP debugging, CMake integration, header/source switching, doxygen generation, competitive programming workflow
- **Rust is first-class**: rustaceanvim (not just lspconfig), clippy on save, runnables/debuggables as native commands
- **Navigation is fast**: Flash + Harpoon + Telescope + zoxide covers every scale of movement
- **Text editing is deep**: three text object layers (mini.ai + targets + treesitter), subword motions, surround, enhanced macros, structural split/join, structural search/replace
- **Git without leaving nvim**: Neogit + Diffview covers everything a git GUI does, from inside the editor
- **Persistent everything**: undofile, persistence.nvim sessions, Harpoon marks — state survives restarts

## Weaknesses / Gaps

- **Python is shallow** — pyright + ruff_format is solid but no DAP debugger configured. Add `mfussenegger/nvim-dap-python` if needed
- **No AI completion** — intentional. Add `github/copilot.vim` or `zbirenbaum/copilot-cmp` when ready

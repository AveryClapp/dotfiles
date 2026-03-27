# Neovim Config Guide

A C++/Rust/Python IDE built on lazy.nvim with Kanagawa Wave theme.

---

## Navigation

### Flash — instant jump anywhere
Press `s` + 2 chars → labels appear on every match → type label to teleport.
Works in normal, visual, and operator-pending mode (`ys<flash>)` to surround a jump target).

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

### Search & Replace
| Key | Action |
|-----|--------|
| `<leader>sr` | Open grug-far (project-wide search/replace with preview) |
| `<leader>sw` | Search word under cursor |

---

## LSP

Servers managed by Mason: **clangd**, **rust_analyzer**, **pyright**, **lua_ls**.

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | Find all references (Telescope) |
| `gh` | Hover docs |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
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

---

## Session Management

| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session for current directory |
| `<leader>ql` | Restore last session |
| `<leader>qd` | Disable session save on exit |

Sessions are managed by `folke/persistence.nvim` and saved automatically on exit.

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

## Strengths

- **C++ is first-class**: clangd with background indexing and clang-tidy, DAP debugging, CMake integration, header/source switching, doxygen generation, competitive programming workflow
- **Rust is first-class**: rustaceanvim (not just lspconfig), clippy on save, runnables/debuggables as native commands
- **Navigation is fast**: Flash + Harpoon + Telescope + Zoxide covers every scale of movement
- **Text editing is deep**: three text object layers (mini.ai + targets + treesitter), subword motions, surround, enhanced macros
- **Git without leaving nvim**: Neogit + Diffview covers everything lazygit does, from inside the editor
- **Persistent undo**: `undofile` enabled — undotree works across sessions

## Weaknesses / Gaps

- **Python is shallow** — pyright + ruff_format is solid but no DAP debugger configured for Python. Add `mfussenegger/nvim-dap-python` if needed
- **No copilot/AI completion** — add `github/copilot.vim` or `zbirenbaum/copilot-cmp` to wire into the existing cmp setup

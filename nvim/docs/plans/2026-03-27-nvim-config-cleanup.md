# Nvim Config Cleanup & Rebuild Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove duplicate/dead plugin config, fix git conflicts, add conform.nvim formatting, lua_ls, overseer.nvim (universal build runner), rustaceanvim, and neotest-rust for a clean, fast, in-buffer workflow across C++/Rust/Python/Lua.

**Architecture:** All plugins live under `lua/custom/plugins/`. The `lua/kickstart/plugins/` directory is orphaned (not loaded by init.lua) and will be deleted. Each task is one file change verified by launching nvim and checking for errors or expected behavior.

**Tech Stack:** Neovim 0.11.5, lazy.nvim, mason.nvim, conform.nvim, overseer.nvim, rustaceanvim, neotest

---

### Task 1: Delete git-addons.lua and migrate its keybind

**Problem:** `git-addons.lua` duplicates gitsigns and diffview (already in `git.lua`), causing two competing setups.

**Files:**
- Delete: `lua/custom/plugins/git-addons.lua`
- Modify: `lua/custom/plugins/git.lua`

**Step 1: Delete the file**

```bash
rm lua/custom/plugins/git-addons.lua
```

**Step 2: Add the one useful keybind from git-addons into git.lua**

In `lua/custom/plugins/git.lua`, inside the gitsigns config function after `require('gitsigns').setup { ... }`, add:

```lua
vim.keymap.set('n', '<leader>gp', ':Gitsigns preview_hunk<CR>', { desc = 'Preview hunk' })
```

**Step 3: Verify**

Launch nvim. Expected: no error about duplicate gitsigns setup, `<leader>gp` previews a hunk in a git repo.

**Step 4: Commit**

```bash
git add lua/custom/plugins/git.lua
git rm lua/custom/plugins/git-addons.lua
git commit -m "fix: remove duplicate gitsigns/diffview setup in git-addons"
```

---

### Task 2: Delete kanagawa.lua (duplicate colorscheme)

**Problem:** `kanagawa.lua` and `colorscheme.lua` both configure the kanagawa theme. Only `colorscheme.lua` is needed.

**Files:**
- Delete: `lua/custom/plugins/kanagawa.lua`

**Step 1: Confirm colorscheme.lua is the authoritative config**

Read `lua/custom/plugins/colorscheme.lua` and verify it has `colorscheme 'kanagawa'` or equivalent. If kanagawa.lua has any unique setup not in colorscheme.lua, migrate it first.

**Step 2: Delete the file**

```bash
git rm lua/custom/plugins/kanagawa.lua
```

**Step 3: Verify**

Launch nvim. Expected: kanagawa theme loads, no duplicate plugin error in `:Lazy`.

**Step 4: Commit**

```bash
git commit -m "fix: remove duplicate kanagawa colorscheme config"
```

---

### Task 3: Remove outline.nvim from c.lua

**Problem:** Symbol outline is dead weight — telescope already exposes symbols via `<leader>ls`. Adds a plugin load for a rarely-used feature.

**Files:**
- Modify: `lua/custom/plugins/c.lua`

**Step 1: Remove the outline.nvim block**

Delete the entire `hedyhli/outline.nvim` plugin spec from `c.lua` (lines ~202-216, the block from `-- Symbol outline` through the closing `},`).

**Step 2: Verify**

Launch nvim, open a `.cpp` file. Expected: no errors, clangd still works normally.

**Step 3: Commit**

```bash
git add lua/custom/plugins/c.lua
git commit -m "chore: remove outline.nvim, telescope covers symbol navigation"
```

---

### Task 4: Delete orphaned kickstart directory

**Problem:** `lua/kickstart/plugins/` is not loaded by init.lua (which only loads `custom.plugins`). These files are dead but misleading.

**Files:**
- Delete: `lua/kickstart/` (entire directory)

**Step 1: Confirm nothing in init.lua references kickstart**

Check `init.lua` — confirm `require('lazy').setup('custom.plugins', ...)` is the only setup call with no `{ import = 'kickstart.plugins' }` line.

**Step 2: Delete the directory**

```bash
git rm -r lua/kickstart/
```

**Step 3: Verify**

Launch nvim. Expected: clean startup, no missing module errors.

**Step 4: Note on autopairs**

The kickstart `autopairs.lua` was not loaded, so `nvim-autopairs` is currently inactive. Add it to `utils.lua`:

```lua
{
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup {}
  end,
},
```

**Step 5: Commit**

```bash
git add lua/custom/plugins/utils.lua
git commit -m "chore: remove orphaned kickstart dir, restore autopairs in utils"
```

---

### Task 5: Add conform.nvim for auto-formatting on save

**Problem:** No formatter is running. stylua-as-LSP is fragile. Python/Rust/C++ have no format-on-save.

**Files:**
- Create: `lua/custom/plugins/formatting.lua`

**Step 1: Ensure formatters are installed**

In nvim, run:
```
:MasonInstall stylua clang-format ruff
```
rustfmt ships with the Rust toolchain — no mason install needed.

**Step 2: Create the file**

```lua
-- lua/custom/plugins/formatting.lua
return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua      = { 'stylua' },
          c        = { 'clang_format' },
          cpp      = { 'clang_format' },
          rust     = { 'rustfmt' },
          python   = { 'ruff_format' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      }
    end,
  },
}
```

**Step 3: Verify**

Open a `.lua` file, add a badly-formatted line, save. Expected: it formats on save with no error notification.

Repeat for `.cpp`, `.py`, `.rs`.

**Step 4: Commit**

```bash
git add lua/custom/plugins/formatting.lua
git commit -m "feat: add conform.nvim with format-on-save for lua/c/cpp/rust/python"
```

---

### Task 6: Add lua_ls to LSP

**Problem:** No LSP for Lua. Writing nvim config without completions/diagnostics/go-to-def is painful.

**Files:**
- Modify: `lua/custom/plugins/lsp.lua`

**Step 1: Add lua_ls to ensure_installed**

In `lsp.lua`, change:

```lua
ensure_installed = { 'clangd', 'rust_analyzer', 'pyright' },
```

to:

```lua
ensure_installed = { 'clangd', 'rust_analyzer', 'pyright', 'lua_ls' },
```

**Step 2: Add a specific handler for lua_ls with nvim runtime awareness**

In the `handlers` table, before the default handler, add:

```lua
lua_ls = function()
  require('lspconfig').lua_ls.setup {
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file('', true),
        },
        diagnostics = { globals = { 'vim' } },
        telemetry = { enable = false },
      },
    },
  }
end,
```

**Step 3: Also add a stylua no-op handler to stop the --lsp error**

```lua
stylua = function() end,
```

**Step 4: Verify**

Launch nvim, open `init.lua`. Expected: `vim.keymap` completes, `gd` on `require('lazy')` jumps to source, no stylua LSP error.

**Step 5: Commit**

```bash
git add lua/custom/plugins/lsp.lua
git commit -m "feat: add lua_ls with nvim runtime awareness, suppress stylua LSP"
```

---

### Task 7: Add overseer.nvim and wire to cmake-tools

**Problem:** cmake-tools currently uses `quickfix` executor. Overseer gives a proper buffer-based output panel and works for any build system (cmake, cargo, make).

**Files:**
- Create: `lua/custom/plugins/overseer.lua`
- Modify: `lua/custom/plugins/c.lua`

**Step 1: Create overseer.lua**

```lua
-- lua/custom/plugins/overseer.lua
return {
  {
    'stevearc/overseer.nvim',
    cmd = { 'OverseerRun', 'OverseerToggle', 'OverseerBuild' },
    keys = {
      { '<leader>oo', '<cmd>OverseerToggle<CR>',  desc = 'Overseer: Toggle panel' },
      { '<leader>or', '<cmd>OverseerRun<CR>',     desc = 'Overseer: Run task' },
    },
    config = function()
      require('overseer').setup {
        task_list = {
          direction = 'bottom',
          min_height = 12,
          max_height = 20,
        },
      }
    end,
  },
}
```

**Step 2: Wire cmake-tools to overseer in c.lua**

In `c.lua`, change the `cmake_executor` block from:

```lua
cmake_executor = {
  name = 'quickfix',
  opts = {},
  default_opts = {
    quickfix = {
      show = 'always',
      position = 'belowright',
      size = 10,
    },
  },
},
```

to:

```lua
cmake_executor = { name = 'overseer', opts = {} },
```

Also add `'stevearc/overseer.nvim'` to the cmake-tools `dependencies` list.

**Step 3: Verify**

Open a CMake project, run `<leader>cb`. Expected: overseer panel opens at bottom with build output streaming in, errors navigable in quickfix.

**Step 4: Commit**

```bash
git add lua/custom/plugins/overseer.lua lua/custom/plugins/c.lua
git commit -m "feat: add overseer.nvim, wire cmake-tools to overseer executor"
```

---

### Task 8: Add rustaceanvim and neotest-rust

**Problem:** rust_analyzer via mason-lspconfig gives basic LSP. rustaceanvim adds cargo-aware runnables, debuggables, and proper Rust toolchain integration. neotest-rust adds in-buffer test output for Rust.

**Files:**
- Create: `lua/custom/plugins/rust.lua`
- Modify: `lua/custom/plugins/lsp.lua`

**Step 1: Exclude rust_analyzer from mason-lspconfig default handler**

In `lsp.lua`, add a no-op handler for rust_analyzer so mason-lspconfig doesn't set it up (rustaceanvim manages its own rust_analyzer):

```lua
rust_analyzer = function() end,
```

**Step 2: Create rust.lua**

```lua
-- lua/custom/plugins/rust.lua
return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        tools = {
          hover_actions = { auto_focus = true },
        },
        server = {
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = { command = 'clippy' },
              inlayHints = { enable = true },
            },
          },
        },
        dap = {
          adapter = {
            type = 'server',
            port = '${port}',
            executable = {
              command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
              args = { '--port', '${port}' },
            },
          },
        },
      }

      vim.keymap.set('n', '<leader>rr', function()
        vim.cmd.RustLsp 'runnables'
      end, { desc = 'Rust: Runnables' })

      vim.keymap.set('n', '<leader>rd', function()
        vim.cmd.RustLsp 'debuggables'
      end, { desc = 'Rust: Debuggables' })

      vim.keymap.set('n', '<leader>re', function()
        vim.cmd.RustLsp 'explainError'
      end, { desc = 'Rust: Explain error' })
    end,
  },

  -- Rust test runner (integrates with existing neotest in c.lua)
  {
    'nvim-neotest/neotest',
    optional = true,
    dependencies = { 'rouge8/neotest-rust' },
    config = function()
      local neotest = require 'neotest'
      neotest.setup {
        adapters = {
          require 'neotest-rust',
          require('neotest-gtest').setup {},
        },
      }
    end,
  },
}
```

**Note:** The `optional = true` on neotest means this spec merges with the neotest spec in `c.lua` rather than replacing it. You must also remove the `neotest` config block from `c.lua` and let this file own neotest entirely — otherwise both configs run.

**Step 3: Remove neotest config from c.lua**

In `c.lua`, remove the entire `nvim-neotest/neotest` plugin spec (the block from `-- Google Test integration` through its closing `},`). The `rust.lua` neotest spec handles both adapters now.

**Step 4: Verify**

Open a `.rs` file. Expected:
- rust-analyzer attaches (check `:LspInfo`)
- `<leader>rr` opens a picker of cargo runnables
- `<leader>re` on an error shows a detailed explanation

Open a Rust project with tests, run `<leader>tt`. Expected: neotest runs the test and shows pass/fail in the summary panel.

**Step 5: Commit**

```bash
git add lua/custom/plugins/rust.lua lua/custom/plugins/lsp.lua lua/custom/plugins/c.lua
git commit -m "feat: add rustaceanvim with runnables/debuggables, neotest-rust"
```

---

### Task 9: Final verification pass

**Step 1: Check for startup errors**

```bash
nvim --headless "+Lazy sync" +qa
```

Then launch nvim normally and run `:checkhealth` — look for any ERROR lines in the LSP or mason sections.

**Step 2: Verify each language end-to-end**

| File type | Check |
|-----------|-------|
| `.lua` | LSP attaches, `gd` works, formats on save |
| `.cpp` | clangd attaches, `<leader>cb` builds via overseer |
| `.rs` | rustaceanvim attaches, `<leader>rr` shows runnables |
| `.py` | pyright attaches, ruff formats on save |

**Step 3: Verify no duplicate plugin warnings in `:Lazy`**

Run `:Lazy` — confirm no plugins appear twice.

**Step 4: Commit**

```bash
git add -A
git commit -m "chore: final cleanup and verification pass"
```

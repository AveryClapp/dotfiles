# Cracked Plugin Additions Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add six high-value plugins (lazydev, fidget, oil, mini.ai, trouble, grug-far) that maximize editing speed and UI cleanliness with minimal clutter.

**Architecture:** Each plugin gets its own file under `lua/custom/plugins/`. No git operations. Verification is launching nvim and confirming behavior. lazydev replaces the lua_ls workspace library hack already in lsp.lua.

**Tech Stack:** Neovim 0.11.5, lazy.nvim, treesitter (already installed)

---

### Task 1: Add lazydev.nvim (better Lua/nvim config dev)

**Problem:** The current lua_ls handler uses `vim.api.nvim_get_runtime_file('', true)` to inject nvim runtime types — this is slow and imprecise. lazydev.nvim is the proper replacement: it auto-detects nvim config context and injects correct types including lazy.nvim plugin specs.

**Files:**
- Create: `lua/custom/plugins/lazydev.lua`
- Modify: `lua/custom/plugins/lsp.lua`

**Step 1: Create lazydev.lua**

```lua
-- lua/custom/plugins/lazydev.lua
return {
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true },
}
```

**Step 2: Remove the library hack from lua_ls handler in lsp.lua**

In `lua/custom/plugins/lsp.lua`, find the `lua_ls` handler and replace it with a simpler version — lazydev handles the runtime injection now:

Change:
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

To:
```lua
lua_ls = function()
  require('lspconfig').lua_ls.setup {
    capabilities = capabilities,
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  }
end,
```

**Step 3: Verify**

Open `init.lua`. Expected: `vim.keymap`, `vim.opt`, `require('lazy')` all complete correctly with types. No "undefined global vim" warnings.

---

### Task 2: Add fidget.nvim (subtle LSP progress)

**Problem:** No indication of when LSP servers are indexing. fidget shows subtle progress text in the bottom-right that fades once done.

**Files:**
- Create: `lua/custom/plugins/fidget.lua`

**Step 1: Create fidget.lua**

```lua
-- lua/custom/plugins/fidget.lua
return {
  {
    'j-hui/fidget.nvim',
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },
}
```

**Step 2: Verify**

Open a `.cpp` or `.rs` file in a project. Expected: a small progress indicator appears bottom-right while clangd/rust-analyzer indexes, then disappears silently.

---

### Task 3: Add oil.nvim (filesystem as a buffer)

**Problem:** neo-tree was cut. oil.nvim is a better replacement — opens the filesystem as an editable buffer. Rename by editing text, delete by deleting lines, create by adding lines.

**Files:**
- Create: `lua/custom/plugins/oil.lua`

**Step 1: Create oil.lua**

```lua
-- lua/custom/plugins/oil.lua
return {
  {
    'stevearc/oil.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('oil').setup {
        default_file_explorer = true,
        columns = { 'icon' },
        view_options = {
          show_hidden = true,
        },
        keymaps = {
          ['<CR>'] = 'actions.select',
          ['-']    = 'actions.parent',
          ['_']    = 'actions.open_cwd',
          ['gs']   = 'actions.change_sort',
          ['g.']   = 'actions.toggle_hidden',
        },
      }
      vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory' })
    end,
  },
}
```

**Step 2: Verify**

Press `-` in normal mode. Expected: current file's directory opens as a buffer with files listed. Navigate into a subdirectory with `<CR>`, go up with `-`. Edit a filename and save — the file should be renamed on disk.

---

### Task 4: Add mini.ai (extended text objects)

**Problem:** Default text objects are limited. mini.ai adds powerful `around`/`inside` objects for: function arguments (`a`), function body (`f`), class/type (`c`), quotes (`q`), and more. Works via treesitter for code-aware selections.

**Files:**
- Create: `lua/custom/plugins/mini.lua`

**Step 1: Create mini.lua**

```lua
-- lua/custom/plugins/mini.lua
return {
  {
    'echasnovski/mini.ai',
    version = '*',
    event = 'VeryLazy',
    config = function()
      local ai = require 'mini.ai'
      ai.setup {
        n_lines = 500,
        custom_textobjects = {
          -- function definition (treesitter)
          f = ai.gen_spec.treesitter {
            a = '@function.outer',
            i = '@function.inner',
          },
          -- class/struct (treesitter)
          c = ai.gen_spec.treesitter {
            a = '@class.outer',
            i = '@class.inner',
          },
        },
      }
    end,
  },
}
```

**Step 2: Verify**

Open a `.cpp` file with a function. Place cursor inside the function body:
- `vaf` — should visually select the entire function including signature
- `vif` — should select only the function body
- `daa` — delete a function argument (with surrounding comma)
- `cia` — change inside argument

---

### Task 5: Add trouble.nvim (diagnostics + quickfix as buffer)

**Problem:** Raw `:copen` quickfix and `:lua vim.diagnostic.setloclist()` are ugly and hard to navigate. trouble.nvim gives a structured, grouped, navigable panel.

**Files:**
- Create: `lua/custom/plugins/trouble.lua`

**Step 1: Create trouble.lua**

```lua
-- lua/custom/plugins/trouble.lua
return {
  {
    'folke/trouble.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'Trouble',
    keys = {
      { '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>',                        desc = 'Diagnostics (Trouble)' },
      { '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',           desc = 'Buffer diagnostics (Trouble)' },
      { '<leader>xq', '<cmd>Trouble qflist toggle<CR>',                             desc = 'Quickfix (Trouble)' },
      { '<leader>xl', '<cmd>Trouble loclist toggle<CR>',                            desc = 'Location list (Trouble)' },
      { '<leader>xs', '<cmd>Trouble symbols toggle focus=false<CR>',                desc = 'Symbols (Trouble)' },
      { '<leader>xr', '<cmd>Trouble lsp toggle focus=false win.position=right<CR>', desc = 'LSP references (Trouble)' },
    },
    opts = {
      modes = {
        diagnostics = {
          auto_close = true,
        },
      },
    },
  },
}
```

**Step 2: Verify**

Open any file with LSP errors. Press `<leader>xx`. Expected: a panel opens at the bottom showing all diagnostics grouped by file, with icons and line numbers. Press `<CR>` on an entry to jump to it. Press `<leader>xx` again to close.

---

### Task 6: Add grug-far.nvim (project-wide search/replace in a buffer)

**Problem:** No good project-wide find/replace. `:s///g` is limited to one file. grug-far opens a buffer where you type the pattern, see all matches live, edit replacements, and apply.

**Files:**
- Create: `lua/custom/plugins/grug-far.lua`

**Step 1: Create grug-far.lua**

```lua
-- lua/custom/plugins/grug-far.lua
return {
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>sr',
        function()
          require('grug-far').open { transient = true }
        end,
        desc = 'Search and replace (grug-far)',
      },
      {
        '<leader>sw',
        function()
          require('grug-far').open {
            transient = true,
            prefills = { search = vim.fn.expand '<cword>' },
          }
        end,
        desc = 'Search word under cursor (grug-far)',
      },
    },
    opts = {},
  },
}
```

**Step 2: Verify**

Press `<leader>sr`. Expected: a buffer opens with search/replace fields. Type a search term — matching lines from the project appear below in real time. Fill in replacement, press the apply keybind (shown in the buffer). Files update on disk.

Press `<leader>sw` with cursor on a word — same but pre-filled with the word.

---

### Task 7: Final check

**Step 1: Launch nvim and run `:Lazy sync`**

All 6 new plugins should install: lazydev.nvim, luvit-meta, fidget.nvim, oil.nvim, mini.ai, trouble.nvim, grug-far.nvim.

**Step 2: Check `:Lazy` for any errors**

No red entries. All plugins should show as installed.

**Step 3: Smoke test each plugin**

| Key | Expected |
|-----|----------|
| `-` | Oil opens current directory as buffer |
| `<leader>xx` | Trouble diagnostics panel |
| `<leader>xq` | Trouble quickfix panel |
| `<leader>sr` | Grug-far search/replace buffer |
| `<leader>sw` | Grug-far pre-filled with word under cursor |
| `vaf` in a function | Selects entire function (mini.ai) |
| Open `.cpp` file | Fidget progress appears while clangd indexes |
| Open `.lua` file | `vim.*` completions work (lazydev) |

# Neovim Config

C++/Rust/Python IDE built on lazy.nvim with Kanagawa Wave theme. See [GUIDE.md](../GUIDE.md) for the full keybind and plugin reference.

## Structure

```
init.lua                    # options, keymaps, lazy bootstrap
lua/custom/plugins/         # one file per plugin
```

## Quick Start

```bash
# From the dotfiles root
cp -r nvim/ ~/.config/nvim/
nvim  # lazy.nvim auto-installs all plugins
```

Then run `:Mason` to install LSP servers and `:TSUpdate` to update parsers.

## Adding a Plugin

1. Create `lua/custom/plugins/<name>.lua`
2. Return a lazy.nvim spec
3. Restart nvim or `:Lazy sync`

## Project-Local Keymaps

Drop a `.nvim.lua` in any project root — it's auto-sourced on open (`exrc = true`):

```lua
-- myproject/.nvim.lua
vim.keymap.set('n', '<leader>mc', '<cmd>!g++ -std=c++17 -O2 -o out main.cpp<CR>', { desc = 'Compile' })
vim.keymap.set('n', '<leader>mr', '<cmd>!./out<CR>', { desc = 'Run' })
```

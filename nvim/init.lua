-- ~/.config/nvim/init.lua
-- Leader must be set before lazy loads
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Options
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'auto:2'
vim.opt.updatetime = 250
vim.opt.termguicolors = true
vim.opt.scrolloff = 5
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.exrc = true


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Load all plugin specs from lua/custom/plugins/
require('lazy').setup('custom.plugins', {
  change_detection = { notify = false },
})

-- Keymaps
local map = vim.keymap.set
map('n', 'J', '10j')
map('n', 'K', '10k')
map('n', 'H', '0')
map('n', 'L', '$')

-- Autocmds
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yank',
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local buf = args.buf
    local map_buf = function(keys, fn) vim.keymap.set('n', keys, fn, { buffer = buf }) end
    map_buf('gd',           vim.lsp.buf.definition)
    map_buf('gr',           require('telescope.builtin').lsp_references)
    map_buf('<leader>ca',   vim.lsp.buf.code_action)
    map_buf('gh',           vim.lsp.buf.hover)
    map_buf(']d',           vim.diagnostic.goto_next)
    map_buf('[d',           vim.diagnostic.goto_prev)
    map_buf('<leader>e',    vim.diagnostic.open_float)
  end,
})

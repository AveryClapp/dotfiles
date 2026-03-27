-- lua/custom/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'c', 'cpp', 'rust', 'lua', 'python',
        'bash', 'json', 'yaml', 'toml', 'markdown', 'markdown_inline',
        'cmake', 'make', 'vim', 'vimdoc', 'regex',
      },
      highlight = { enable = true },
      indent    = { enable = true },
      textobjects = {
        select = {
          enable    = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
      },
    },
  },
  { 'nvim-treesitter/nvim-treesitter-textobjects' },
}


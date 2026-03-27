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

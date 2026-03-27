-- lua/custom/plugins/aerial.lua
return {
  'stevearc/aerial.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('aerial').setup {
      on_attach = function(bufnr)
        vim.keymap.set('n', '[s', '<cmd>AerialPrev<CR>', { buffer = bufnr, desc = 'Aerial prev symbol' })
        vim.keymap.set('n', ']s', '<cmd>AerialNext<CR>', { buffer = bufnr, desc = 'Aerial next symbol' })
      end,
    }
    vim.keymap.set('n', '<leader>o', '<cmd>AerialToggle!<CR>', { desc = 'Toggle outline' })
  end,
}

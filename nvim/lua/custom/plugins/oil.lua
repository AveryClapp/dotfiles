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

-- lua/custom/plugins/zen-mode.lua
return {
  'folke/zen-mode.nvim',
  config = function()
    require('zen-mode').setup {}
    vim.keymap.set('n', '<leader>z', '<cmd>ZenMode<CR>', { desc = 'Toggle zen mode' })
  end,
}

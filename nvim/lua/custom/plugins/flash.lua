-- lua/custom/plugins/flash.lua
return {
  'folke/flash.nvim',
  config = function()
    require('flash').setup {}
    vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
  end,
}

-- lua/custom/plugins/flash.lua
return {
  'folke/flash.nvim',
  config = function()
    require('flash').setup {}
    vim.keymap.set({ 'n', 'x', 'o' }, 's',         function() require('flash').jump() end,              { desc = 'Flash jump' })
    vim.keymap.set({ 'n', 'x', 'o' }, '<leader>S', function() require('flash').treesitter() end,        { desc = 'Flash treesitter node' })
    vim.keymap.set('o',               'r',          function() require('flash').remote() end,            { desc = 'Flash remote (operate on distant text)' })
    vim.keymap.set({ 'x', 'o' },      'R',          function() require('flash').treesitter_search() end, { desc = 'Flash treesitter search' })
  end,
}

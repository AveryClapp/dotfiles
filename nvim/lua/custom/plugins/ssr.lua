-- lua/custom/plugins/ssr.lua
-- Structural search & replace using treesitter patterns
return {
  'cshuaimin/ssr.nvim',
  keys = { { '<leader>sR', mode = { 'n', 'x' } } },
  config = function()
    require('ssr').setup {
      border = 'rounded',
      min_width = 50,
      min_height = 5,
      max_width = 120,
      max_height = 25,
    }
    vim.keymap.set({ 'n', 'x' }, '<leader>sR', function() require('ssr').open() end, { desc = 'Structural search & replace' })
  end,
}

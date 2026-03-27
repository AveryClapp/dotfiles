-- lua/custom/plugins/toggleterm.lua
return {
  'akinsho/toggleterm.nvim',
  version = '*',
  keys = { { '<leader>T', mode = 'n' } },
  config = function()
    require('toggleterm').setup {
      size = 15,
      open_mapping = '<leader>T',
      direction = 'horizontal',
      shade_terminals = false,
    }
  end,
}

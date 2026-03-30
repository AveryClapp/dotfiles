-- lua/custom/plugins/which-key.lua
return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  config = function()
    require('which-key').setup {
      triggers = {
        { '<leader>', mode = { 'n', 'v' } },
      },
    }
  end,
}

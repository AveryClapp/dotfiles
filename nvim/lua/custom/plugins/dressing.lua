-- lua/custom/plugins/dressing.lua
-- Improves vim.ui.select (code actions, etc.) and vim.ui.input (rename, etc.)
return {
  'stevearc/dressing.nvim',
  event = 'VeryLazy',
  config = function()
    require('dressing').setup {}
  end,
}

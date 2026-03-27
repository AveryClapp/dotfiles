-- lua/custom/plugins/notify.lua
return {
  'rcarriga/nvim-notify',
  config = function()
    require('notify').setup {
      timeout  = 3000,
      render   = 'compact',
      stages   = 'fade',
      top_down = false,
    }
    vim.notify = require('notify')
  end,
}

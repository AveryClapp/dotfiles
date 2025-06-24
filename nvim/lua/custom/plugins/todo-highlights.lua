return {
  'folke/todo-comments.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('todo-comments').setup {
      signs = true, -- show icons in the signs column
      keywords = {
        TODO = { icon = ' ', color = 'info' },
        HACK = { icon = ' ', color = 'warning' },
        WARN = { icon = ' ', color = 'warning' },
        NOTE = { icon = ' ', color = 'hint' },
        FIX = { icon = ' ', color = 'error' },
      },
    }
  end,
}

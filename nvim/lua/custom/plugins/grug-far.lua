-- lua/custom/plugins/grug-far.lua
return {
  {
    'MagicDuck/grug-far.nvim',
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>sr',
        function()
          require('grug-far').open { transient = true }
        end,
        desc = 'Search and replace (grug-far)',
      },
      {
        '<leader>sw',
        function()
          require('grug-far').open {
            transient = true,
            prefills = { search = vim.fn.expand '<cword>' },
          }
        end,
        desc = 'Search word under cursor (grug-far)',
      },
    },
    opts = {},
  },
}

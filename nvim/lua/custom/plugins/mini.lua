-- lua/custom/plugins/mini.lua
return {
  {
    'echasnovski/mini.ai',
    version = '*',
    event = 'VeryLazy',
    config = function()
      local ai = require 'mini.ai'
      ai.setup {
        n_lines = 500,
        custom_textobjects = {
          -- function definition (treesitter)
          f = ai.gen_spec.treesitter {
            a = '@function.outer',
            i = '@function.inner',
          },
          -- class/struct (treesitter)
          c = ai.gen_spec.treesitter {
            a = '@class.outer',
            i = '@class.inner',
          },
        },
      }
    end,
  },
}

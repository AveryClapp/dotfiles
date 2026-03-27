-- lua/custom/plugins/indent-blankline.lua
return {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl',
  config = function()
    require('ibl').setup {
      indent = { char = '│' },
      scope  = { enabled = true },
      exclude = {
        filetypes = { 'alpha', 'help', 'lazy', 'mason', 'trouble' },
      },
    }
  end,
}

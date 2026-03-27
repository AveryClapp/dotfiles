-- lua/custom/plugins/illuminate.lua
return {
  'RRethy/vim-illuminate',
  config = function()
    require('illuminate').configure {
      delay             = 100,
      under_cursor      = true,
      large_file_cutoff = 2000,
    }
  end,
}

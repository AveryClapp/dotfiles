-- ocaml lsp integration --
return {
  'tarides/ocaml.nvim',
  config = function()
    require('ocaml').setup()
  end,
}

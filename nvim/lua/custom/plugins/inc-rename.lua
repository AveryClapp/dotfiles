-- lua/custom/plugins/inc-rename.lua
-- Live preview of LSP rename as you type
return {
  'smjonas/inc-rename.nvim',
  config = function()
    require('inc_rename').setup {}
    vim.keymap.set('n', '<leader>rn', function()
      return ':IncRename ' .. vim.fn.expand('<cword>')
    end, { expr = true, desc = 'Rename symbol (live preview)' })
  end,
}

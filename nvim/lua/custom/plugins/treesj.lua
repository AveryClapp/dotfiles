-- lua/custom/plugins/treesj.lua
-- Split/join blocks: {a, b, c} <-> multiline and back
return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  keys = {
    { 'gS', mode = 'n' },
    { 'gJ', mode = 'n' },
    { 'gM', mode = 'n' },
  },
  config = function()
    require('treesj').setup { use_default_keymaps = false }
    vim.keymap.set('n', 'gS', '<cmd>TSJSplit<cr>', { desc = 'Split block to multiline' })
    vim.keymap.set('n', 'gJ', '<cmd>TSJJoin<cr>',  { desc = 'Join block to single line' })
    vim.keymap.set('n', 'gM', '<cmd>TSJToggle<cr>', { desc = 'Toggle split/join' })
  end,
}

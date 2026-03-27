-- lua/custom/plugins/spider.lua
return {
  'chrisgrieser/nvim-spider',
  keys = {
    { 'w',  mode = { 'n', 'o', 'x' } },
    { 'e',  mode = { 'n', 'o', 'x' } },
    { 'b',  mode = { 'n', 'o', 'x' } },
    { 'ge', mode = { 'n', 'o', 'x' } },
  },
  config = function()
    -- replaces w/e/b/ge with subword-aware versions
    local spider = require('spider')
    vim.keymap.set({ 'n', 'o', 'x' }, 'w',  function() spider.motion 'w'  end, { desc = 'Spider w' })
    vim.keymap.set({ 'n', 'o', 'x' }, 'e',  function() spider.motion 'e'  end, { desc = 'Spider e' })
    vim.keymap.set({ 'n', 'o', 'x' }, 'b',  function() spider.motion 'b'  end, { desc = 'Spider b' })
    vim.keymap.set({ 'n', 'o', 'x' }, 'ge', function() spider.motion 'ge' end, { desc = 'Spider ge' })
  end,
}

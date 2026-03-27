-- lua/custom/plugins/harpoon.lua
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local harpoon = require('harpoon')
    harpoon.setup {}

    vim.keymap.set('n', '<leader>a', function() harpoon:list():add() end,                              { desc = 'Harpoon add file' })
    vim.keymap.set('n', '<leader>h', function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,      { desc = 'Harpoon menu' })

    for i = 1, 4 do
      vim.keymap.set('n', ('<leader>%d'):format(i), function() harpoon:list():select(i) end, { desc = 'Harpoon file ' .. i })
    end
  end,
}

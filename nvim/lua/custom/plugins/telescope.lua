-- lua/custom/plugins/telescope.lua
return {
  'nvim-telescope/telescope.nvim',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup {
      defaults = {
        layout_strategy = 'horizontal',
        sorting_strategy = 'ascending',
        layout_config = { prompt_position = 'top' },
      },
    }
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>ff', builtin.find_files,  { desc = 'Telescope find files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep,   { desc = 'Telescope live grep' })
    vim.keymap.set('n', '<leader>fr', builtin.oldfiles,    { desc = 'Telescope recent files' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers,     { desc = 'Telescope buffers' })
  end,
}

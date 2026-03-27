-- lua/custom/plugins/undotree.lua
return {
  'mbbill/undotree',
  config = function()
    vim.keymap.set('n', '<leader>U', vim.cmd.UndotreeToggle, { desc = 'Toggle undotree' })
  end,
}

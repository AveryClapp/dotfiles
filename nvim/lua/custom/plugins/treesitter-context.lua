-- lua/custom/plugins/treesitter-context.lua
return {
  'nvim-treesitter/nvim-treesitter-context',
  config = function()
    require('treesitter-context').setup {
      max_lines      = 3,
      trim_scope     = 'outer',
      mode           = 'cursor',
    }
    -- Jump up into the context
    vim.keymap.set('n', '[C', function()
      require('treesitter-context').go_to_context(vim.v.count1)
    end, { desc = 'Jump to context' })
  end,
}

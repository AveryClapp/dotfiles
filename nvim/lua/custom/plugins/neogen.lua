return {
  {
    'danymat/neogen',
    cmd = 'Neogen',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      snippet_engine = 'luasnip',
      languages = {
        python = { template = { annotation_convention = 'google_docstrings' } },
      },
    },
    keys = {
      { '<leader>nc', '<cmd>Neogen<cr>', desc = 'Generate docstring' },
    },
  },
}

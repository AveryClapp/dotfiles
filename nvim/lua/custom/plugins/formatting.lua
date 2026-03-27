-- lua/custom/plugins/formatting.lua
return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      require('conform').setup {
        formatters_by_ft = {
          lua    = { 'stylua' },
          c      = { 'clang_format' },
          cpp    = { 'clang_format' },
          rust   = { 'rustfmt' },
          python = { 'ruff_format' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      }
    end,
  },
}

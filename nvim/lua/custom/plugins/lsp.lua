-- lua/custom/plugins/lsp.lua
return {
  {
    'williamboman/mason.nvim',
    config = function()
      require('mason').setup()
    end,
  },
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'neovim/nvim-lspconfig',
    },
    config = function()
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      require('mason-lspconfig').setup {
        ensure_installed = { 'clangd', 'rust_analyzer', 'pyright', 'lua_ls' },
        handlers = {
          -- default handler
          function(server_name)
            require('lspconfig')[server_name].setup {
              capabilities = capabilities,
            }
          end,
          -- lua_ls: lazydev.nvim handles runtime type injection
          lua_ls = function()
            require('lspconfig').lua_ls.setup {
              capabilities = capabilities,
              settings = {
                Lua = {
                  runtime = { version = 'LuaJIT' },
                  workspace = { checkThirdParty = false },
                  telemetry = { enable = false },
                },
              },
            }
          end,
          -- rustaceanvim manages rust_analyzer itself
          rust_analyzer = function() end,
          -- stylua is a formatter, not an LSP server
          stylua = function() end,
        },
      }
    end,
  },
  { 'neovim/nvim-lspconfig' },
}

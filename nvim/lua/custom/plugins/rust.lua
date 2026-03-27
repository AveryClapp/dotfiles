-- lua/custom/plugins/rust.lua
return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    config = function()
      vim.g.rustaceanvim = {
        tools = {
          hover_actions = { auto_focus = true },
        },
        server = {
          capabilities = require('cmp_nvim_lsp').default_capabilities(),
          settings = {
            ['rust-analyzer'] = {
              checkOnSave = { command = 'clippy' },
              inlayHints = { enable = true },
            },
          },
        },
        dap = {
          adapter = {
            type = 'server',
            port = '${port}',
            executable = {
              command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
              args = { '--port', '${port}' },
            },
          },
        },
      }

      vim.keymap.set('n', '<leader>rr', function()
        vim.cmd.RustLsp 'runnables'
      end, { desc = 'Rust: Runnables' })

      vim.keymap.set('n', '<leader>rd', function()
        vim.cmd.RustLsp 'debuggables'
      end, { desc = 'Rust: Debuggables' })

      vim.keymap.set('n', '<leader>re', function()
        vim.cmd.RustLsp 'explainError'
      end, { desc = 'Rust: Explain error' })
    end,
  },

  -- neotest with both C++ (gtest) and Rust adapters
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      'alfaix/neotest-gtest',
      'rouge8/neotest-rust',
    },
    keys = {
      { '<leader>tt', function() require('neotest').run.run() end,               desc = 'Run nearest test' },
      { '<leader>tf', function() require('neotest').run.run(vim.fn.expand('%')) end, desc = 'Run file tests' },
      { '<leader>ts', function() require('neotest').summary.toggle() end,        desc = 'Toggle test summary' },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require('neotest-gtest').setup {},
          require('neotest-rust'),
        },
      }
    end,
  },
}

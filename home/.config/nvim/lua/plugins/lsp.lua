return {
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    config = function()
      require('mason').setup()
    end,
  },
  {
    -- Passive data source: provides server definitions to vim.lsp.config() via
    -- runtimepath. Do NOT call require('lspconfig') — just having it installed
    -- is enough. See: https://github.com/neovim/nvim-lspconfig/wiki/v2-migration
    'neovim/nvim-lspconfig',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      -- Override defaults only where needed (most servers need nothing)

      -- Sorbet must run through Bundler so it uses the project's exact version
      vim.lsp.config('sorbet', {
        cmd = { 'bundle', 'exec', 'srb', 'tc', '--lsp' },
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file('', true),
            },
            diagnostics = { globals = { 'vim' } },
            telemetry = { enable = false },
          },
        },
      })

      -- Activate servers; nvim-lspconfig provides their cmd/filetypes/root markers
      vim.lsp.enable({
        'ts_ls', 'lua_ls', 'pyright', 'bashls', 'jsonls', 'yamlls', 'cssls', 'html',
        'gopls',
        'ruby_lsp', 'sorbet',
      })

      -- Keymaps applied to every buffer where an LSP attaches
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf, silent = true }
          local map = vim.keymap.set
          map('n', 'gd',         vim.lsp.buf.definition,     opts)
          map('n', 'gD',         vim.lsp.buf.declaration,    opts)
          map('n', 'gr',         vim.lsp.buf.references,     opts)
          map('n', 'gi',         vim.lsp.buf.implementation, opts)
          map('n', 'K',          vim.lsp.buf.hover,          opts)
          map('n', '<leader>rn', vim.lsp.buf.rename,         opts)
          map('n', '<leader>ca', vim.lsp.buf.code_action,    opts)
          map('n', '[d',         vim.diagnostic.goto_prev,   opts)
          map('n', ']d',         vim.diagnostic.goto_next,   opts)
        end,
      })
    end,
  },
}

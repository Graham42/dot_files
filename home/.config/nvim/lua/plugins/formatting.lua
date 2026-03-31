local js_formatters = function()
  if vim.fn.glob('.eslintrc*') ~= '' then
    return { 'eslint_d', 'prettier' }
  end
  return { 'prettier' }
end

return {
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    config = function()
      require('conform').setup({
        formatters_by_ft = {
          javascript      = js_formatters,
          javascriptreact = js_formatters,
          typescript      = js_formatters,
          typescriptreact = js_formatters,
          ['_']           = { 'trim_whitespace' },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })
    end,
  },
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufWritePost' },
    config = function()
      local lint = require('lint')

      -- Only set eslint_d on JS/TS when .eslintrc* is present
      vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufWritePost' }, {
        pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
        callback = function()
          if vim.fn.glob('.eslintrc*') ~= '' then
            lint.try_lint('eslint_d')
          end
        end,
      })
    end,
  },
  {
    -- Auto-install formatters/linters via Mason
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require('mason-tool-installer').setup({
        ensure_installed = {
          -- formatters / linters
          'eslint_d', 'prettier', 'stylua',
          -- LSP servers (mason names differ from lspconfig names)
          'typescript-language-server', 'lua-language-server', 'pyright',
          'bash-language-server', 'json-lsp', 'yaml-language-server',
          'css-lsp', 'html-lsp',
          'gopls',
          -- ruby-lsp intentionally omitted — install via `gem install ruby-lsp`
          -- in your Ruby environment to avoid C extension version mismatches
          'sorbet',
        },
        auto_update = false,
        run_on_start = true,
      })
    end,
  },
}

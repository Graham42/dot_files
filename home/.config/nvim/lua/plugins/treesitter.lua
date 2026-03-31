return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { 'BufReadPost', 'BufNewFile' },
  config = function()
    require('nvim-treesitter').setup({
      ensure_installed = {
        'bash', 'css', 'go', 'html', 'javascript', 'json', 'lua',
        'markdown', 'python', 'ruby', 'typescript', 'yaml',
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}

return {
  {
    'kylechui/nvim-surround',
    event = 'VeryLazy',
    config = function()
      require('nvim-surround').setup()
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local opts = { buffer = bufnr, silent = true }
          vim.keymap.set('n', ']h', gs.next_hunk,    opts)
          vim.keymap.set('n', '[h', gs.prev_hunk,    opts)
          vim.keymap.set('n', '<leader>hp', gs.preview_hunk, opts)
        end,
      })
    end,
  },
  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    keys = {
      { '<leader>z', ':ZenMode<CR>', desc = 'Toggle zen mode', silent = true },
    },
    config = function()
      require('zen-mode').setup({
        window = { width = 110 },
      })
    end,
  },
}

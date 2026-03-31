return {
  'nvim-telescope/telescope.nvim',
  cmd = 'Telescope',
  keys = {
    { '<C-p>', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
  },
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    require('telescope').setup({
      defaults = {
        vimgrep_arguments = {
          'rg', '--color=never', '--no-heading', '--with-filename',
          '--line-number', '--column', '--smart-case',
        },
      },
      pickers = {
        find_files = {
          find_command = { 'fd', '--type', 'f', '--hidden', '--follow', '--exclude', '.git' },
        },
      },
    })
  end,
}

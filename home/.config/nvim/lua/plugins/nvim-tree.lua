-- Disable netrw before nvim-tree loads (required by nvim-tree)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

return {
  'nvim-tree/nvim-tree.lua',
  cmd = 'NvimTreeToggle',
  keys = {
    { '<C-n>', ':NvimTreeToggle<CR>', desc = 'Toggle file tree', silent = true },
  },
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('nvim-tree').setup({
      filters = {
        custom = { '\\.pyc$', '^__pycache__$' },
      },
    })
  end,
}

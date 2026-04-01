local opt = vim.opt

-- Encoding
opt.encoding = 'utf-8'

-- UI
opt.number = true
opt.signcolumn = 'yes'
opt.laststatus = 3       -- global statusline (Neovim 0.7+)
opt.termguicolors = true

-- Indentation
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.copyindent = true

-- Searching
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Scrolling / wrapping
opt.wrap = false
opt.sidescroll = 2
opt.scrolloff = 10
opt.sidescrolloff = 4

-- Modelines
opt.modeline = true
opt.modelines = 5

-- Swap / undo — use Neovim-specific dirs to avoid incompatibility with Vim's
-- undo file format (E824: Incompatible undo file)
local data = vim.fn.stdpath('data')
opt.dir     = data .. '/swap'
opt.undodir = data .. '/undo'
opt.undofile = true

-- Clipboard
-- OSC 52 over SSH (Neovim 0.10+ built-in)
if vim.env.SSH_CONNECTION ~= nil then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
else
  opt.clipboard = 'unnamedplus'
end

-- Filetype autocommands
local autocmd = vim.api.nvim_create_autocmd

autocmd('FileType', { pattern = 'make',      callback = function() vim.opt_local.expandtab = false end })
autocmd('FileType', { pattern = 'gitconfig', callback = function() vim.opt_local.expandtab = false end })
autocmd('FileType', { pattern = 'gitcommit', callback = function() vim.opt_local.textwidth = 72 end })
autocmd('FileType', { pattern = 'markdown',  callback = function()
  vim.opt_local.textwidth = 0
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
  vim.opt_local.breakindent = true
end })
autocmd('FileType', { pattern = 'text', callback = function()
  vim.opt_local.textwidth = 110
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true
end })

autocmd({ 'BufRead', 'BufNewFile' }, { pattern = 'Jenkinsfile', command = 'setfiletype groovy' })

local map = vim.keymap.set

-- Clear search highlighting
map('n', '<C-L>', ':nohlsearch<CR><C-L>', { silent = true })

-- Search for visually selected text (like * in normal mode)
map('v', '*', [[:<C-U>let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>gvy/<C-R><C-R>=substitute(escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>gV:call setreg('"', old_reg, old_regtype)<CR>]], { silent = true })

-- Replace highlighted text from cursor to EOF, then wrap
map('v', '<C-r>', [["hy:,$s/<C-r>h//gc\|1,''-&&]], {})

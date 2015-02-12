execute pathogen#infect()

" Misc
set encoding=utf-8
set termencoding=utf-8
set laststatus=2
set nocompatible
set nowrap
set scrolloff=10
set backspace=2
color delek
syntax on
set splitright

" Store swap and undo files in the .vim/tmp directory
set dir=~/.vim/tmp//
set undofile
set undodir=~/.vim/undo//

" Indentation
set smartindent
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set autoindent

" Searching
set incsearch
set ignorecase
set smartcase
set hlsearch
nnoremap <C-L> :nohlsearch<CR><C-L>

" Search for selected text ('*' in visual mode) instead of just single word
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" Shortcut to replace highlighted text
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>

" Highlight only the bracket we're at, underline the matching one
highlight clear MatchParen
highlight MatchParen gui=underline cterm=underline

" Force saving files that require root permission
command Sudow w !sudo tee >/dev/null '%'

" Filetype customizations
autocmd filetype python setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd filetype css,less setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd filetype html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd filetype javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd filetype make setlocal noexpandtab

" trailing whitespace is bad
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" Fugitive - https://github.com/tpope/vim-fugitive

" Syntastic - https://github.com/scrooloose/syntastic
let g:syntastic_python_python_exec = '/usr/bin/python3'

" NERDTree - https://github.com/scrooloose/nerdtree
nnoremap <F6> :NERDTreeToggle<CR>

" Ctrl-P - https://github.com/kien/ctrlp.vim
let g:ctrlp_working_path_mode = 'ra'
nmap <leader>p :CtrlP<cr>
set wildignore+=*/node_modules/*

" Graphical undo - https://github.com/sjl/gundo.vim
nnoremap <F7> :GundoToggle<CR>
let g:gundo_preview_bottom=1
let g:gundo_close_on_revert=1

" Airline - https://github.com/bling/vim-airline
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
"let g:airline#extensions#tmuxline#enabled = 0
"let g:airline#extensions#virtualenv#enabled = 0

" be iMproved
set nocompatible

set encoding=utf-8
set termencoding=utf-8

" Color settings
syntax on
set t_Co=256
color delek
if has('gui_running')
    color molokai
endif

" Store swap and undo files in the .vim/tmp directory
set dir=~/.vim/tmp/
set undofile
set undodir=~/.vim/undo/

" Use X clipboard if available
if has('xterm_clipboard') && v:version >= 703
    set clipboard=unnamedplus
endif

" Indentation
set smartindent
set shiftwidth=4
set tabstop=4
set softtabstop=4
" spaces instead of tabs
set expandtab
set autoindent

" Searching
set incsearch
set ignorecase
set smartcase
set hlsearch
" Clear search highlighting
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
command! Sudow w !sudo tee >/dev/null '%'

" Filetype customizations
autocmd filetype python setlocal shiftwidth=4 tabstop=4 softtabstop=4
autocmd filetype css,less setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd filetype html,htmldjango,php setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd filetype javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd filetype yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd filetype make setlocal noexpandtab
autocmd filetype markdown setlocal tw=99

" associate filetypes
au BufRead,BufNewFile *.jshintrc setfiletype javascript

" Highlight trailing whitespace in red
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" allow files to use modelines
set modeline
set modelines=5

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Line Wrapping / Scrolling
set nowrap
" Make scrolling horizontally not so jumpy
set sidescroll=2
" Space keep around the cursor, gives context when scrolling up/down
set scrolloff=10
" Terminal width on 1920x1080 split side-by-side is 104 characters. So a side
" offset of 4 allows cursor to go to 100 without scrolling. Most things
" /should/ fit in 100 character width
set sidescrolloff=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Plugins

" require for Vundle
filetype off
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'
" Fugitive - A Git wrapper
Plugin 'tpope/vim-fugitive'
" Syntastic - Syntax checking
Plugin 'scrooloose/syntastic'
" NerdTree - Sidebar directory browser
Plugin 'scrooloose/nerdtree'
" Ctrl-P - Fuzzy filename search
Plugin 'kien/ctrlp.vim'
" Gundo - Graphical undo
Plugin 'sjl/gundo.vim'
" Airline - Status bar
Plugin 'bling/vim-airline'
" Colorscheme like Sublime
Plugin 'tomasr/molokai'
" Interact with tmux from vim
Plugin 'benmills/vimux'
" Autocompletion without hotkeys + more awesomeness
" Note that installing this takes a while and also requires compiling manually
" Plugin 'Valloric/YouCompleteMe'

" NuSMV highlighting (CISC 422)
Plugin 'wannesm/wmnusmv.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Plugin Config

" Syntastic - Syntax checking
let g:syntastic_python_python_exec = '/usr/bin/python3'

" NerdTree - Sidebar directory browser
noremap <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.pyc$', '^__pycache__$']

" Ctrl-P - Fuzzy filename search
let g:ctrlp_working_path_mode = 'ra'
nnoremap <leader>p :CtrlP<cr>
set wildignore+=*/node_modules/*

" Gundo - Graphical undo
nnoremap <F7> :GundoToggle<CR>
let g:gundo_preview_bottom=1
let g:gundo_close_on_revert=1

" Airline - Status bar
" Better than Powerline in the sense that it's all vimscript so doesn't
" have any system dependencies other than vim itself
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#syntastic#enabled = 1
" Use powerline fonts if they're installed
let g:airline_powerline_fonts = 1
" Always show the status line
set laststatus=2

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

" Search for selected text ('*' in visual mode) instead of just single word
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" Highlight only the bracket we're at, underline the matching one
highlight clear MatchParen
highlight MatchParen gui=underline cterm=underline

" Highlight trailing whitespace in red
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/

" allow files to use modelines
set modeline
set modelines=5

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Macros / Custom commands

" Force saving files that require root permission
command! Sudow w !sudo tee >/dev/null '%'

" Insert line below
let @o='mmo0d$`m'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Keybindings

" Clear search highlighting
nnoremap <C-L> :nohlsearch<CR><C-L>
" Shortcut to replace highlighted text, starting at the cursor to the end of
" the file, then from the start of the file to the cursors original place
vnoremap <C-r> "hy:,$s/<C-r>h//gc\|1,''-&&<left><left><left><left><left><left>
  \<left><left><left><left><left>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Filetype customizations

autocmd filetype html,htmldjango,php setlocal tw=120
autocmd filetype html,htmldjango,php,js setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd filetype make setlocal noexpandtab
autocmd filetype gitconfig setlocal noexpandtab
autocmd filetype gitcommit setlocal tw=72
autocmd filetype markdown,text setlocal tw=100

" associate filetypes
au BufRead,BufNewFile *.jshintrc setfiletype javascript
au BufRead,BufNewFile *.{frag,vert} setfiletype cpp

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
"" Plugin Config

" Syntastic - Syntax checking
let g:syntastic_python_python_exec = '/usr/bin/python3'

" NerdTree - Sidebar directory browser
noremap <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.pyc$', '^__pycache__$']

" Ctrl-P - Fuzzy filename search
" set current working directory root to be a git/other repo
let g:ctrlp_working_path_mode = 'ra'
" ignore files in .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
nnoremap <leader>p :CtrlP<cr>

" Airline - Status bar
" Better than Powerline in the sense that it's all vimscript so doesn't
" have any system dependencies other than vim itself
let g:airline#extensions#syntastic#enabled = 1
let g:airline_left_sep=' '
let g:airline_right_sep=' '
" Always show the status line
set laststatus=2

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Plugins

call plug#begin()

" Syntastic - Syntax checking
Plug 'scrooloose/syntastic'
" NerdTree - Sidebar directory browser
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Ctrl-P - Fuzzy filename search
Plug 'kien/ctrlp.vim', { 'on':  'CtrlP' }
" Airline - Status bar
Plug 'bling/vim-airline'
" Colorscheme like Sublime
Plug 'tomasr/molokai'
" Interact with tmux from vim
Plug 'benmills/vimux'


"""""""""""""""""""""""
"" Autocomplete Plugin
"
" Note that this requires compiling so need some things installed
" see http://vimawesome.com/plugin/youcompleteme#installation
"
"function! BuildYCM(info)
"  " info is a dictionary with 3 fields
"  " - name:   name of the plugin
"  " - status: 'installed', 'updated', or 'unchanged'
"  " - force:  set on PlugInstall! or PlugUpdate!
"  if a:info.status == 'installed' || a:info.force
"    !./install.py --tern-completer
"  endif
"endfunction
"
"Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }

call plug#end()

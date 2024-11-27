" be iMproved
set nocompatible

set encoding=utf-8
set termencoding=utf-8

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Plugin Config

" Always show gutter so editor doesn't jump on error detection
set signcolumn=yes

" NerdTree - Sidebar directory browser
noremap <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.pyc$', '^__pycache__$']

" Ctrl-P - Fuzzy filename search
" set current working directory root to be a git/other repo
let g:ctrlp_working_path_mode = 'ra'
" ignore files in .gitignore
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
nnoremap <C-p> :CtrlP<cr>

" Airline - Status bar
" Better than Powerline in the sense that it's all vimscript so doesn't
" have any system dependencies other than vim itself
let g:airline#extensions#syntastic#enabled = 1
let g:airline_left_sep=' '
let g:airline_right_sep=' '
" Always show the status line
set laststatus=2

" Ale settings
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}

autocmd FileType javascript let g:ale_linters = {
\  'javascript': glob('.eslintrc*', '.;') != '' ? [ 'eslint' ] : [ ],
\}
autocmd FileType javascript let g:ale_fixers = {
\  'javascript': glob('.eslintrc*', '.;') != '' ? [ 'eslint', 'prettier' ] : [ 'prettier' ],
\}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Plugins
" See searchable index of plugins at https://vimawesome.com/

call plug#begin()

" Async syntax checker - https://github.com/dense-analysis/ale
Plug 'dense-analysis/ale'
" All languages!
Plug 'sheerun/vim-polyglot'
" NerdTree - Sidebar directory browser
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
" Ctrl-P - Fuzzy filename search
Plug 'kien/ctrlp.vim', { 'on':  'CtrlP' }
" Airline - Status bar
Plug 'bling/vim-airline'
" Color Theme
Plug 'haishanh/night-owl.vim'
" Light variation if you want
Plug 'macguirerintoul/night_owl_light.vim'
" Easy to add quotes/brackets around text
Plug 'tpope/vim-surround'

call plug#end()
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Store swap and undo files in the .vim/tmp directory
set dir=~/.vim/tmp/
set undodir=~/.vim/undo/
" Persist undo between sessions
set undofile

" Use X clipboard if available
if has('xterm_clipboard') && v:version >= 703
    set clipboard=unnamedplus
elseif has('clipboard')
    set clipboard=unnamed
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Searching
" Show search matches as you type.
set incsearch
" Ignore case when searching.
set ignorecase
" Ignore case if search pattern is all lowercase, case-sensitive otherwise.
set smartcase
" Highlight search terms.
set hlsearch

" Search for selected text ('*' in visual mode) instead of just single word
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

" Clear search highlighting
nnoremap <C-L> :nohlsearch<CR><C-L>
" Shortcut to replace highlighted text, starting at the cursor to the end of
" the file, then from the start of the file to the cursors original place
vnoremap <C-r> "hy:,$s/<C-r>h//gc\|1,''-&&<left><left><left><left><left><left>
  \<left><left><left><left><left>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Always show line numbers
set number

" Highlight only the bracket we're at, underline the matching one
highlight clear MatchParen
highlight MatchParen gui=underline cterm=underline

" allow files to use modelines
set modeline
set modelines=5

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Indentation
" Tab width
set tabstop=2
set softtabstop=2
set shiftwidth=2
" spaces instead of tabs
set expandtab
set autoindent
set smartindent
" Copy the previous indentation when autoindenting.
set copyindent

"" Filetype customizations
autocmd filetype make setlocal noexpandtab
autocmd filetype gitconfig setlocal noexpandtab

au BufRead,BufNewFile Jenkinsfile setfiletype groovy

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

autocmd filetype gitcommit setlocal tw=72
autocmd filetype markdown,text setlocal tw=80

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Color settings
syntax on
set t_Co=256
if has('gui_running')
    color molokai
    set lines=60 columns=181
    winpos 560 200
endif

""""" enable 24bit true color
" If you have vim >=8.0 or Neovim >= 0.1.5
if (has("termguicolors"))
 set termguicolors
endif

colorscheme night-owl

set nocompatible              " be iMproved, required
filetype off                  " required

" ==================================================================================================
" Env management
" ==================================================================================================
" Resolve the dotfiles repo root from this symlinked .vimrc, so rtp works
" regardless of where the repo is cloned.
let s:dotfiles_dir = fnamemodify(resolve(expand('<sfile>')), ':h')

set rtp+=~/.fzf

" SkyRG — personal grep/search plugin
" Cloned to skyrg-plugin/ by setup.sh; always tracks main.
let &rtp .= ',' . s:dotfiles_dir . '/skyrg-plugin'

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

" ==================================================================================================
" Plugin management
" ==================================================================================================
" Completion engine: 'coc' (default) or 'ycm'
" Override in ~/.vimrc_local:
"   let g:completion_engine = 'ycm'
let g:completion_engine = get(g:, 'completion_engine', 'coc')

call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Fuzzy search
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'

" Autocompletion / LSP (controlled by g:completion_engine)
if g:completion_engine ==# 'ycm'
  Plugin 'Valloric/YouCompleteMe'
endif
if g:completion_engine ==# 'coc'
  Plugin 'neoclide/coc.nvim', {'branch': 'release'}
endif

" Switch between header and implementation
Bundle 'vim-scripts/a.vim'

" Toggle comments
Bundle 'scrooloose/nerdcommenter'

" File directory pane
Bundle 'scrooloose/nerdtree'

" Airline (status/tabline)
Plugin 'vim-airline/vim-airline'

" Git
Plugin 'tpope/vim-fugitive'

" Indicate current VCS diff in gutter
Plugin 'mhinz/vim-signify'

" Color schemes
Plugin 'morhetz/gruvbox'
Plugin 'chriskempson/base16-vim'
Plugin 'pR0Ps/molokai-dark'
Plugin 'altercation/vim-colors-solarized'

" Broad language support
Plugin 'sheerun/vim-polyglot'

" Claude Code integration
Plugin 'rishi-opensource/vim-claude-code'

" All plugins must be added before this line
" Machine-local extra plugins (work-specific Vundle plugins go here)
" This file is sourced INSIDE the vundle#begin/end block, so Plugin declarations work.
silent! source ~/.vimrc_plugins_local

call vundle#end()
filetype plugin indent on

" ==================================================================================================
" General text editor behavior
" ==================================================================================================

set noswapfile

" Jump to last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
      \| exe "normal! g'\"zz" | endif
  au BufReadPost COMMIT_EDITMSG
    \ exe "normal! gg"
endif

" Persist undo history across sessions
set undofile
set undodir=~/.vim/undodir

set number
set expandtab
set smarttab

set shiftwidth=4
set softtabstop=4
set tabstop=4

" Don't auto-wrap text
set fo-=t

" Completion menu
set completeopt=menu,menuone

" Indentation
set autoindent
set nosmartindent
set nocindent

" Searching
set ignorecase
set smartcase
set incsearch
set hlsearch

set backspace=indent,eol,start

" ==================================================================================================
" Clipboard
" ==================================================================================================
" On Linux: * = PRIMARY (mouse selection), + = CLIPBOARD (ctrl+c/v)
nnoremap <leader>y "+y
nnoremap <leader>p "+p

" ==================================================================================================
" Navigation
" ==================================================================================================

" Tab navigation
map <C-t><up>    :tabr<cr>
map <C-t><down>  :tabl<cr>
map <C-t><left>  :tabp<cr>
map <C-t><right> :tabn<cr>

" FZF shortcuts
nnoremap <c-@> :Files<cr>
nnoremap <c-p> :GFiles<cr>

" Search helpers
nnoremap <expr> <c-?> ':RG '.expand('<cword>')
nnoremap <expr> <leader>? ':RG '.expand('<c-r>"')

nnoremap <leader><bar> :vsp<cr>

" ==================================================================================================
" LSP / completion key bindings
" ==================================================================================================
if g:completion_engine ==# 'coc'
  nnoremap <silent> <F1>  :call CocActionAsync('doHover')<cr>
  nmap     <silent> <F2>  <Plug>(coc-declaration)
  nmap     <silent> <F3>  <Plug>(coc-definition)
  nnoremap <silent> <F4>  :<C-u>CocList symbols<cr>
  nnoremap <silent> <F5>  :CocRestart<cr>
  nnoremap <silent> <F6>  :CocDiagnostics<cr>
  nmap     <silent> <F7>  <Plug>(coc-diagnostic-info)
  nmap     <silent> <F8>  <Plug>(coc-fix-current)
  nmap              <F9>  <Plug>(coc-rename)
  nnoremap <silent> <F10> :CocRefs<cr>
elseif g:completion_engine ==# 'ycm'
  nnoremap <F1>  :YcmCompleter GetDoc<cr>
  nnoremap <F2>  :YcmCompleter GetType<cr>
  nnoremap <F3>  :YcmCompleter GoTo<cr>
  nnoremap <F4>  :YcmCompleter GoToSymbol
  nnoremap <F5>  :YcmForceCompileAndDiagnostics<cr>
  nnoremap <F6>  :YcmDiags<cr>
  nnoremap <F7>  :YcmShowDetailedDiagnostic<cr>
  nnoremap <F8>  :YcmCompleter FixIt<cr>
  nnoremap <F9>  :YcmCompleter RefactorRename
  nnoremap <F10> :YRefs<cr>
endif

" ==================================================================================================
" Color scheme
" ==================================================================================================
syntax on
set background=dark
silent! colorscheme gruvbox

" ==================================================================================================
" Machine-local overrides
" Loaded last so ~/.vimrc_local can add plugins via rtp, override settings,
" load work-specific plugins (skyrg, vim-lcm), etc.
" ==================================================================================================
" Source personal SkyRG config files
for s:f in glob(s:dotfiles_dir . '/skyrg/*.vim', 0, 1)
  execute 'source' s:f
endfor

" Machine-local overrides (sourced last)
silent! source ~/.vimrc_local

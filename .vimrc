" Clear messages buffer
let g:messages=[]

set nocompatible              " be iMproved, required
filetype off                  " required

function! g:GetIgnoredTypesGlob(ignored_exts)
  let ignore_globs = ""
  for ext in a:ignored_exts
    let ignore_globs = ignore_globs . " \':!:*\." . ext . "\'"
  endfor
  return ignore_globs
endfunction

" ==================================================================================================
" Unity stuff 
" ==================================================================================================
" TODO: Feels like we should be able to autodetect the type of project
let s:unity_projs = ['Zeldalike', 'schmoovement']
let s:unity_include_extensions=[
    \ 'cs',
    \ 'txt',
    \]
let s:unity_ignore_extensions=[
    \ 'meta',
    \ 'asset',
    \ 'scenetemplate',
    \ 'dwlt',
    \]
let s:unity_include_directories=[
    \]
let s:unity_ignore_directories=[
    \ 'Library',
    \ 'Logs',
    \ 'Packages',
    \ 'ProjectSettings',
    \ 'UserSettings',
    \]
let s:unity_pkg_ignore_directories=[
    \ 'Library',
    \ 'Logs',
    \ 'ProjectSettings',
    \ 'UserSettings',
    \]
let g:unity_ignore_glob = g:GetIgnoredTypesGlob(s:unity_ignore_extensions)
function! g:UnityProjSetup()
    echom "Setting RG filter to default to unity!"
    call g:SkyFilter.new("unity")
          \ .include_exts(s:unity_include_extensions)
          \ .include_dirs(s:unity_include_directories)
          \ .ignore_exts(s:unity_ignore_extensions)
          \ .ignore_dirs(s:unity_ignore_directories)

    call g:SkyFilter.new("pkg")
          \ .include_exts(s:unity_include_extensions)
          \ .include_dirs(s:unity_include_directories)
          \ .ignore_exts(s:unity_ignore_extensions)
          \ .ignore_dirs(s:unity_pkg_ignore_directories)

    let g:SkyFilter.default = 'unity'
    nnoremap <c-p> :call fzf#vim#gitfiles(g:unity_ignore_glob)<cr>
endfunction

" ==================================================================================================
" Project context
" ==================================================================================================
let g:jerdo_context='DEFAULT'

function! g:SetProjectContext(directory)
  for project_name in s:unity_projs
    if (stridx(a:directory, project_name) != -1)
      let g:jerdo_context='UNITY'
    endif
  endfor
endfunction

function! g:SetUpUserSkyrgFilters()
  if g:jerdo_context == "UNITY"
    call UnityProjSetup()
  endif
endfunction

call SetProjectContext(getcwd())
" ==================================================================================================
" Env management
" ==================================================================================================
set rtp+=~/.fzf

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

" ==================================================================================================
" Plugin management
" ==================================================================================================
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Fuzzy search
" Plugin 'kien/ctrlp.vim'
Plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plugin 'junegunn/fzf.vim'

" Switch between header and cc file
Bundle 'vim-scripts/a.vim'

" Toggle comments
Bundle 'scrooloose/nerdcommenter'

" File directory pane
Bundle 'scrooloose/nerdtree'

" Airline (status/tabline)
Plugin 'vim-airline/vim-airline'

" Git
Plugin 'tpope/vim-fugitive'

" Indicate current version control diff
Plugin 'mhinz/vim-signify'

" Color schemes
Plugin 'morhetz/gruvbox'
Plugin 'chriskempson/base16-vim'
Plugin 'pR0Ps/molokai-dark'
Plugin 'altercation/solarized'
Plugin 'altercation/vim-colors-solarized'

" djinni syntax highlighting
Plugin 'r0mai/vim-djinni'

" kotlin syntax highlighting
Plugin 'udalov/kotlin-vim'

" swift syntax highlighting
Plugin 'keith/swift.vim'

Plugin 'sheerun/vim-polyglot'

Plugin 'jfeng94/skyrg'

Plugin 'github/copilot.vim'

" CSharp/unity stuff
Bundle 'OmniSharp/omnisharp-vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" ==================================================================================================
" Imports
" ==================================================================================================
" let g:vim_config_root = '~/.dotfiles'
" let g:config_file_list = [
    " \ 'skyrg.vim',
    " \ ]

" for f in g:config_file_list
    " execute 'source ' . g:vim_config_root . '/' . f
" endfor

" ==================================================================================================
" General text editor behavior
" ==================================================================================================
" Do not create swap file
set noswapfile

" Have Vim jump to the last position when reopening a file
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
      \| exe "normal! g'\"zz" | endif
  au BufReadPost COMMIT_EDITMSG
    \ exe "normal! gg"
endif

" Have Vim maintain undo history between sessions
set undofile "
set undodir=~/.vim/undodir

set number    " turn on line numbers
set expandtab " convert tabs to spaces
set smarttab  " insert and delete indent correctly

set shiftwidth=4  " tab size
set softtabstop=4 " tab size
set tabstop=4     " tab size

" set format options (default tcq) see http://vimdoc.sourceforge.net/htmldoc/change.html#fo-table
set fo-=t " don't auto-wrap text

" Change completion menu behavior
set completeopt=menu,menuone

" Indentation
set autoindent
set nosmartindent
set nocindent

" Better searching
set ignorecase
set smartcase
set incsearch
set hlsearch

" Backspace
set backspace=indent,eol,start

" yank selection to system clipboard (from http://stackoverflow.com/a/11489440/53997)
" Note that on linux:
"  - register "* maps to XA_PRIMARY (e.g. mouse selection buffer clipboard)
"  - register "+ maps to XA_SECONDARY (e.g. ctrl+c/ctrl+v clipboard)
nnoremap <leader>y "+y
nnoremap <leader>p "+p

" Toggle between paste and no-paste modes

" Tab navigation
map <C-t><up> :tabr<cr>
map <C-t><down> :tabl<cr>
map <C-t><left> :tabp<cr>
map <C-t><right> :tabn<cr>

" FZF shortcuts
nnoremap <c-@> :Files<cr>
nnoremap <c-p> :GFiles<cr>

" Search helpers
" Search for word under cursor
nnoremap <expr> <c-?> ':RG '.expand('<cword>')
" Search for yanked text
nnoremap <expr> <leader>? ':RG '.expand('<c-r>"')

nnoremap <leader><bar> :vsp<cr>
" Function Keys ---------------------------------------------------------------
nnoremap <F1> :YcmCompleter GetDoc<cr>
nnoremap <F2> :YcmCompleter GetType<cr>
nnoremap <F3> :YcmCompleter GoTo<cr>
nnoremap <F4> :YcmCompleter GoToSymbol

nnoremap <F5> :YcmForceCompileAndDiagnostics<cr>
nnoremap <F6> :YcmDiags<cr>
nnoremap <F7> :YcmShowDetailedDiagnostic<cr>
nnoremap <F8> :YcmCompleter FixIt<cr>

nnoremap <F9> :YcmCompleter RefactorRename
" nnoremap <F10>
" F11 is full screen
" nnoremap <F12>

" <LEADER> + Function keys ---------------------------------------------------
nnoremap <leader><F1> :Buffers<cr>
set pastetoggle=<leader><F2>
nnoremap <leader><F3> :set number!<cr> :SignifyToggle<cr>
" nnoremap <leader><F4> :!./skyrun export code_format<cr> :silent! bufdo e<cr> 
nnoremap <leader><F5> :source $MYVIMRC<cr> :e!<cr>
" nnoremap <leader><F6>
" nnoremap <leader><F7>
" nnoremap <leader><F8>
" nnoremap <leader><F9>
" nnoremap <leader><F10>
" F11 is full screen
" nnoremap <leader><F12>


" call skydio formatter on filewrite
" TODO: Do not call if not aircam directory
" augroup setup_code_formatter
  " autocmd!
  " autocmd BufWritePost * call SkydioCodeFormat()
" augroup end
" ==================================================================================================
" Syntax highlighting
" ==================================================================================================
syntax enable

augroup setup_filetypes
  autocmd!
  autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
  autocmd BufNewFile,BufFilePre,BufRead *.cc set filetype=cpp
  autocmd BufNewFile,BufFilePre,BufRead *.cs set filetype=cs
  autocmd BufNewFile,BufFilePre,BufRead *.java set filetype=java
  autocmd BufNewFile,BufFilePre,BufRead *.py set filetype=python
  autocmd BufNewFile,BufFilePre,BufRead *.djinni set filetype=djinni
  autocmd BufNewFile,BufFilePre,BufRead *.kt set filetype=kotlin
  autocmd BufNewFile,BufFilePre,BufRead *.swift set filetype=swift
  autocmd BufNewFile,BufFilePre,BufRead *.vimrc,*.vim set filetype=vim
  autocmd BufNewFile,BufFilePre,BufRead */COMMIT_EDITMSG set filetype=gitcommit
  autocmd BufNewFile,BufFilePre,BufRead *.proto set filetype=proto
augroup end

" ==================================================================================================
" Language specific editor behavior
" ==================================================================================================
function! s:SetupEditor(tabwidth, textwidth)
    execute "setlocal shiftwidth=".a:tabwidth
    execute "setlocal softtabstop=".a:tabwidth
    execute "setlocal tabstop=".a:tabwidth
    execute "setlocal textwidth=".a:textwidth
    execute "setlocal colorcolumn=".(a:textwidth+1)
endfunction

augroup setup_filetype_editors
  autocmd!
  autocmd FileType cpp call s:SetupEditor(2, 100)
  autocmd FileType djinni call s:SetupEditor(4, 100)
  autocmd FileType tex call s:SetupEditor(2, 120)
  autocmd FileType java call s:SetupEditor(2, 100)
  autocmd FileType python call s:SetupEditor(4, 100)
  autocmd FileType vim call s:SetupEditor(2, 100)
  autocmd FileType gitcommit call s:SetupEditor(2, 80)
  autocmd FileType proto call s:SetupEditor(2, 100)
  autocmd FileType c,cc,cpp,objc,*.mm,cs call SetupForCLang()

  " Sets up vim help docs to vsplit right
  autocmd FileType help wincmd L
augroup end
  

" ==================================================================================================
" Visual Bell
" ==================================================================================================
set visualbell t_vb= " turn off error beep/flash
set novisualbell " turn off visual bell

" ==================================================================================================
" Mouse
" ==================================================================================================
" " Screen/tmux can also handle xterm mousiness, but Vim doesn't
" " detect it by default.
" if &term == "screen"
" set ttymouse=xterm2
" endif
" 
" if v:version >= 704 && &term =~ "^screen"
" " Odds are good that this is a modern tmux, so let's pick the
" " best mouse-handling mode.
" set ttymouse=sgr
" endif
" Enable mouse control
set ttymouse=sgr
set mouse=a

" ==================================================================================================
" FZF Configuration
" ==================================================================================================

" NOTE: Skyrg's filter class is not available until the plugins are loaded *after* the vimrc is
" executed. Best way to set this up is to call this function on VimEnter, which happens "after  
" all the startup stuff, executing the -c cmd arguments, creating all windows, and loading the
" buffers in them."
function! SetUpSkyrg()

  call g:SkyFilter.new("none")
        \ .include_exts([])
        \ .include_dirs([])
        \ .ignore_exts([])
        \ .ignore_dirs([])
  let g:SkyFilter.default = 'none'

  call g:SetUpUserSkyrgFilters()

endfunction

augroup create_skyrg_filters 
  autocmd!
  autocmd VimEnter * call SetUpSkyrg() 
augroup end

command! -nargs=* -bang RG call SkyRG(<f-args>)
command! -nargs=* -bang RGN call SkyRG('--', <f-args>)

" ==================================================================================================
" Signify Configuration
" ==================================================================================================
let g:signify_vcs_list = ['git', 'svn', 'hg']
let g:signify_sign_change = '~'
let g:signify_sign_delete = '-'
let g:signify_update_on_focusgained = 1

" ==================================================================================================
" ==================================================================================================
" NERD* Configuration
" ==================================================================================================
let g:NERDSpaceDelims=1

" ==================================================================================================
" Omnisharp
" ==================================================================================================
let g:OmniSharp_translate_cygwin_wsl = 1

" ==================================================================================================
" CPP Functions
" ==================================================================================================
" Configuration for C-like languages.
function! SetupForCLang()
    " Use 2 spaces for indentation.
    setlocal shiftwidth=2
    setlocal tabstop=2
    setlocal softtabstop=2
    setlocal expandtab

    " Configure auto-indentation formatting.
    setlocal cindent
    setlocal cinoptions=h1,l1,g1,t0,i4,+4,(0,w1,W4
    setlocal indentexpr=GoogleCppIndent()
    let b:undo_indent = "setl sw< ts< sts< et< tw< wrap< cin< cino< inde<"

    " Uncomment these lines to map F5 to the CEF style checker. Change the path to match your system.
    " map! <F5> <Esc>:!python ~/code/chromium/src/cef/tools/check_style.py %:p 2> lint.out<CR>:cfile lint.out<CR>:silent !rm lint.out<CR>:redraw!<CR>:cc<CR>
    " map  <F5> <Esc>:!python ~/code/chromium/src/cef/tools/check_style.py %:p 2> lint.out<CR>:cfile lint.out<CR>:silent !rm lint.out<CR>:redraw!<CR>:cc<CR>
endfunction


" From https://github.com/vim-scripts/google.vim/blob/master/indent/google.vim
function! GoogleCppIndent()
    let l:cline_num = line('.')

    let l:orig_indent = cindent(l:cline_num)

    if l:orig_indent == 0 | return 0 | endif
" ==================================================================================================

    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    if l:pline =~# '^\s*template' | return l:pline_indent | endif

    " TODO: I don't know to correct it:
    " namespace test {
    " void
    " ....<-- invalid cindent pos
    "
    " void test() {
    " }
    "
    " void
    " <-- cindent pos
    if l:orig_indent != &shiftwidth | return l:orig_indent | endif

    let l:in_comment = 0
    let l:pline_num = prevnonblank(l:cline_num - 1)
    while l:pline_num > -1
        let l:pline = getline(l:pline_num)
        let l:pline_indent = indent(l:pline_num)

        if l:in_comment == 0 && l:pline =~ '^.\{-}\(/\*.\{-}\)\@<!\*/'
            let l:in_comment = 1
        elseif l:in_comment == 1
            if l:pline =~ '/\*\(.\{-}\*/\)\@!'
                let l:in_comment = 0
            endif
        elseif l:pline_indent == 0
            if l:pline !~# '\(#define\)\|\(^\s*//\)\|\(^\s*{\)'
                if l:pline =~# '^\s*namespace.*'
                    return 0
                else
                    return l:orig_indent
                endif
            elseif l:pline =~# '\\$'
                return l:orig_indent
            endif
        else
            return l:orig_indent
        endif

        let l:pline_num = prevnonblank(l:pline_num - 1)
    endwhile

    return l:orig_indent
" ==================================================================================================
endfunction


" ==================================================================================================
" Visual appearance
" NOTE: needs to come at the end to override any previous options that sneakily made it in.
" TODO: Why isn't my python syntax highlighting working...?
" ==================================================================================================
let g:airline_powerline_fonts = 1

" Enable terminal gui colors for wider color selection options
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

function! SetHighlightingOptions()
  " let l:width = execute echo &textwidth
  " let l:overlength_expr = printf("match OverLength /\%" . l:width . "v.\+/")
  " echom l:overlength_expr
  " highlight OverLength guibg=#410000
  " match OverLength /\%..\+/
  " execute l:overlength_expr
  " highlight ColorColumn guibg=#000040
  " highlight CursorLine guibg=#000010
  " highlight YcmErrorLine guibg=#260000
  " highlight YcmErrorSection guibg=#760000
endfunction

" augroup set_colorscheme
  " autocmd!
  " autocmd vimenter * ++nested colorscheme base16-gruvbox-dark-hard
  " autocmd vimenter * ++nested colorscheme olarized
  " autocmd VimEnter,BufEnter,WinEnter * call SetHighlightingOptions()
  " autocmd BufEnter * highlight OverLength guibg=#410000
  " autocmd BufEnter * match OverLength "/\%11v.\+/"
  " autocmd BufEnter * highlight ColorColumn guibg=#000040
  " autocmd BufEnter * highlight CursorLine guibg=#000040
" augroup end

let g:solarized_termcolors = 256
let g:solarized_termtrans = 1
let g:solarized_degrade = 0 
let g:solarized_bold = 1
let g:solarized_underline = 1 
let g:solarized_italic = 1 
let g:solarized_contrast = "normal"
let g:solarized_visibility= "normal"
colorscheme base16-solarized-dark

" Ruler and margins
set cursorline

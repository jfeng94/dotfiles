" skyrg/global.vim — Personal SkyRG settings (sourced by .vimrc)

" Context popup trigger
let g:skyrg_context_key = '<Leader>a'

" Context popup pages (work overlay adds Device page)
let g:skyrg_pages = {
  \ 1: {'name': 'Search'},
  \ 2: {'name': 'Workflows'},
  \ 0: {'name': 'SkyRG'},
  \ 9: {'name': 'Buffer', 'auto': 1,
  \     'predicate': {-> skyrg#ui#live_split#is_live_split(bufnr('%'))}},
  \ }

" Map action groups to pages (work overlay adds 'device': 3)
let g:skyrg_group_pages = {
  \ 'search':     1,
  \ 'open':       1,
  \ 'revup':      1,
  \ 'workflows':  2,
  \ 'debug':      0,
  \ 'live_split': 9,
  \ }

" Logging
let g:skyrg_log_level = 'DEBUG'

" Keybindings
nnoremap <silent> <Leader>t :SkyRGTasks<CR>
nnoremap <silent> <Leader>f :SkyRGFollowup<CR>

" Ensure action list exists for append pattern
if !exists('g:skyrg_context_actions')
  let g:skyrg_context_actions = []
endif

" Workflows directory
let g:skyrg_workflows_dir = expand('~/.windsurf/workflows')

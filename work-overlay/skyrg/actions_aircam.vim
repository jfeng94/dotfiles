" ~/.dotfiles/skyrg/actions/aircam.vim — Aircam-specific context actions

if !exists('g:skyrg_context_actions')
  let g:skyrg_context_actions = []
endif

function! s:in_aircam(ctx) abort
  return a:ctx.file =~# '/aircam/' || getcwd() =~# '/aircam'
endfunction

call add(g:skyrg_context_actions, {
  \ 'name':      'Generate compile_commands.json',
  \ 'key':       'C',
  \ 'group':     'aircam',
  \ 'priority':  150,
  \ 'predicate': function('s:in_aircam'),
  \ 'job':       {ctx -> './skybuild CompileCommands'},
  \ 'job_opts':  {
  \   'title': 'CompileCommands',
  \   'cwd': {ctx -> s:aircam_root(ctx)},
  \   'monitor': 1,
  \   'monitor_on_success': 'close',
  \   'on_success': [
  \     {
  \       'name': 'Restart CoC',
  \       'key':  'r',
  \       'execute': {ctx -> execute('CocRestart')},
  \       'auto': 1,
  \     },
  \   ],
  \ },
  \ })

function! s:aircam_root(ctx) abort
  let l:f = a:ctx.file
  let l:idx = stridx(l:f, '/aircam/')
  if l:idx >= 0
    return l:f[:l:idx + len('/aircam') - 1]
  endif
  " Fallback: check cwd
  let l:cwd = getcwd()
  if l:cwd =~# '/aircam'
    return matchstr(l:cwd, '.\{-}/aircam')
  endif
  return l:cwd
endfunction

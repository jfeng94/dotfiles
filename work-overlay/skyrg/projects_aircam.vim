" ~/.dotfiles/skyrg/projects/aircam.vim — Aircam filter presets

let s:ac_types = ['py', 'cc', 'h', 'lcm', 'proto', 'djinni', 'mm', 'm', 'swift', 'java', 'kt', 'cmake', 'tsx', 'bazel']
let s:ac_ignore_types = []
let s:ac_search_dirs = []
let s:ac_ignore_dirs = [
    \ 'build',
    \ 'third_party_modules',
    \ 'third_party',
    \ 'bazel-out',
    \ '**/node_modules',
    \ ]

function! s:setup_aircam() abort
  if getcwd() !~# 'aircam' | return | endif
  echom "Setting RG filter to default to aircam!"

  call g:SkyFilter.new("aircam")
        \ .include_filetypes(s:ac_types)
        \ .include_dirs(s:ac_search_dirs)
        \ .ignore_filetypes(s:ac_ignore_types)
        \ .ignore_dirs(s:ac_ignore_dirs)

  call g:SkyFilter.new("ios")
        \ .include_filetypes(['djinni', 'mm', 'm', 'swift'])
        \ .include_dirs(['mobile'])
        \ .ignore_filetypes(s:ac_ignore_types)
        \ .ignore_dirs(s:ac_ignore_dirs)

  call g:SkyFilter.new("android")
        \ .include_filetypes(['djinni', 'java', 'kt'])
        \ .include_dirs(['mobile'])
        \ .ignore_filetypes(s:ac_ignore_types)
        \ .ignore_dirs(s:ac_ignore_dirs)

  call g:SkyFilter.new("mcore")
        \ .include_filetypes(['djinni', 'cc', 'h'])
        \ .include_dirs(['mobile/shared'])
        \ .ignore_filetypes(s:ac_ignore_types)
        \ .ignore_dirs(s:ac_ignore_dirs)

  call g:SkyFilter.new("lcm")
        \ .include_filetypes(['lcm', 'proto'])
        \ .include_dirs(s:ac_search_dirs)
        \ .ignore_filetypes(s:ac_ignore_types)
        \ .ignore_dirs(s:ac_ignore_dirs)

  call g:SkyFilter.new("bazel")
        \ .include_filetypes(['bazel'])
        \ .include_dirs(s:ac_search_dirs)
        \ .ignore_filetypes(s:ac_ignore_types)
        \ .ignore_dirs(s:ac_ignore_dirs)

  call g:SkyFilter.new("gen")
        \ .include_filetypes(['py', 'cc', 'h'])
        \ .include_dirs(['build'])
        \ .ignore_filetypes(s:ac_ignore_types)
        \ .ignore_dirs([])

  call g:SkyFilter.new("web")
        \ .include_filetypes(s:ac_types)
        \ .include_dirs(s:ac_search_dirs)
        \ .ignore_filetypes(s:ac_ignore_types)
        \ .ignore_dirs(s:ac_ignore_dirs)

  call g:SkyFilter.new("none")
        \ .include_filetypes([])
        \ .include_dirs([])
        \ .ignore_filetypes([])
        \ .ignore_dirs([])

  let g:SkyFilter.default = 'aircam'
endfunction

augroup skyrg_aircam
  autocmd!
  autocmd VimEnter * call s:setup_aircam()
augroup end

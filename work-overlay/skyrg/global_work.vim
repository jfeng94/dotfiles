" skyrg/global_work.vim — Work-specific SkyRG additions (drone/device)

" Add Device page and group mapping
let g:skyrg_pages[3]          = {'name': 'Device'}
let g:skyrg_group_pages['device'] = 3

" Auto-detect devices on USB plug/unplug
call skyrg#backend#device#watch_usb()

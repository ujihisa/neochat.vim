let s:save_cpo = &cpo
set cpo&vim

function! s:render(messages) dict abort
  echomsg string(['messages', a:messages])
  " echo a:messages
endfunction

let s:ui_vanilla = {
      \ 'name': 'vanilla',
      \ 'render': function('s:render')}

function! neochat#ui#vanilla#open() abort
  let m = g:neochat#BM.new()
  call m.open('ui/vanilla')
  call m.do('call append(0, ''## neochat'')')

  let ui = copy(s:ui_vanilla)
  let ui.m = m
  return ui
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('neochat')
let s:CP = s:V.import('ConcurrentProcess')

function! neochat#is_available() abort
  return s:CP.is_available()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let s:save_cpo = &cpo
set cpo&vim

function! neochat#ui#vanila#open() abort
  " TODO
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

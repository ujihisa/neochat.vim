let s:save_cpo = &cpo
set cpo&vim

let g:neochat#V = vital#of('neochat')
let g:neochat#CP = g:neochat#V.import('ConcurrentProcess')
let g:neochat#BM = g:neochat#V.import('Vim.BufferManager')

function! neochat#is_available() abort
  return g:neochat#CP.is_available()
endfunction

" function! neochat#establish(protocol) abort
"   let connection = {'protocol': a:protocol}
"   " TODO
"   return connection
"   return 
" endfunction

" function! neochat#hear(connection) abort
"   let messages = neochat#protocol#{a:connection.protocol}#hear(a:connection)
"   " TODO
"   echo messages
" endfunction

function! neochat#say(connection, message) abort
  return neochat#protocol#{a:connection.protocol}#say(a:connection, a:message)
endfunction

" for debugging
function! neochat#test() abort
  let ui = neochat#ui#vanilla#open()
  let connection = neochat#protocol#echo#establish()
  let messages = neochat#protocol#echo#hear(connection)
  call ui.render(messages)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

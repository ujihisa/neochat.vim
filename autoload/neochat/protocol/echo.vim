let s:save_cpo = &cpo
set cpo&vim

let s:protocol = {}

function! neochat#protocol#echo#say(connection, message) abort
  let a:connection.buffer = get(a:connection, 'buffer', []) + [a:message]
  return 1
endfunction

function! neochat#protocol#echo#hear(connection) abort
  let messages = a:connection.buffer
  let a:connection.buffer = []
  return messages
endfunction

" function! neochat#procotol#echo#define() abort
"   echo 'Hello! Let us echo!'
"   return s:protocol
" endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

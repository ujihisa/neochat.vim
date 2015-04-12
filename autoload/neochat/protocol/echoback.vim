let s:save_cpo = &cpo
set cpo&vim

let s:protocol = {}

function! neochat#protocol#echoback#establish() abort
  return {'buffer': []}
endfunction

function! neochat#protocol#echoback#say(connection, message) abort
  let a:connection.buffer = a:connection + [a:message]
  return 1
endfunction

function! neochat#protocol#echoback#hear(connection) abort
  let messages = a:connection.buffer
  let a:connection.buffer = []
  return messages
endfunction

" function! neochat#procotol#echoback#define() abort
"   echo 'Hello! Let us echo!'
"   return s:protocol
" endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

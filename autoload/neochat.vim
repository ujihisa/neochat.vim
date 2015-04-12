let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#of('neochat')
let s:CP = s:V.import('ConcurrentProcess')

function! neochat#is_available() abort
  return s:CP.is_available()
endfunction

function! neochat#establish(protocol) abort
  let connection = {'protocol': a:protocol}
  " TODO
  return connection
endfunction

function! neochat#hear(connection) abort
  let messages = neochat#protocol#{a:connection.protocol}#hear(a:connection)
  " TODO
  echo messages
endfunction

function! neochat#say(connection, message) abort
  return neochat#protocol#{a:connection.protocol}#say(a:connection, a:message)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

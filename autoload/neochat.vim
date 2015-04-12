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

let s:current = []

function! neochat#start(name_protocol, name_ui) abort
  let connection = neochat#protocol#{a:name_protocol}#establish()
  let ui = neochat#ui#{a:name_ui}#open(connection)
  let messages = neochat#protocol#{a:name_protocol}#hear(connection)
  call ui.render(messages)

  let s:current += [[connection, ui]]
  augroup neochat-autoupdate
    execute 'autocmd! CursorHold,CursorHoldI * call'
    \       's:autoupdate()'
  augroup END
endfunction

function! s:autoupdate() abort
  for [connection, ui] in s:current
    let messages = neochat#protocol#{connection.protoname}#hear(connection)
    call ui.render(messages)
  endfor
endfunction

function! neochat#test() abort
  return neochat#start('echoback', 'vanilla')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

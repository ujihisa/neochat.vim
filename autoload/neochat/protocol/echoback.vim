let s:save_cpo = &cpo
set cpo&vim

let s:protocol = {}

function! s:cp_of() abort
  return g:neochat#CP.of('irb --noinspect --noreadline --prompt default -r~/.vimbundles/neochat.vim/a.rb', '', [
        \ ['*read*', '_', 'irb(main):\d\+:\d\+> ']])
endfunction

function! neochat#protocol#echoback#establish() abort
  return {'protoname': 'echoback'}
endfunction

function! neochat#protocol#echoback#say(connection, message) abort
  let label = s:cp_of()
  let name = 'vim'
  call g:neochat#CP.queue(label, [
        \ ['*writeln*', printf("rbsay('%s', '%s')", escape(name, "'"), escape(a:message, "'"))],
        \ ['*read*', 'say', 'irb(main):\d\+:\d\+> ']])
  " TODO make it non-blocking
  let [out, err, timeout_p] = g:neochat#CP.consume_all_blocking(label, 'say', 2)
  if err !=# ''
    throw printf('say() Failed. stderr: %s', err)
  elseif timeout_p
    throw 'say() timed out.'
  endif
  return 1
endfunction

function! neochat#protocol#echoback#hear(connection) abort
  let label = s:cp_of()
  call g:neochat#CP.queue(label, [
        \ ['*writeln*', 'rbhear()'],
        \ ['*read*', 'hear', 'irb(main):\d\+:\d\+> ']])
  let [out, err, timeout_p] = g:neochat#CP.consume_all_blocking(label, 'hear', 2)
  if err !=# ''
    throw printf('hear() Failed. stderr: %s', err)
  elseif timeout_p
    throw 'hear() timed out.'
  endif

  " it'll be like [{'name': 'ujihisa', 'body': 'hi'}]
  let out = substitute(out, '.*=> \(.*\)\n', '\1', '')
  " echomsg string(['out', out, eval(out)])
  return eval(out)
endfunction

" function! neochat#procotol#echoback#define() abort
"   echo 'Hello! Let us echo!'
"   return s:protocol
" endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

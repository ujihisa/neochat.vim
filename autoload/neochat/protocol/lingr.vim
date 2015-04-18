let s:save_cpo = &cpo
set cpo&vim

let s:plugin_dir = expand('<sfile>:h:h:h:h')
let s:line_separator = '---<gyoniku>---'
let s:room_id = ''
let s:config_path = s:plugin_dir . '/secret.json'

function! s:find_executable() abort
    let files = split(globpath(&runtimepath, 'lingr'), "\n")
    if empty(files)
        throw "Missing executable."
    endif
    return files[0]
endfunction
let s:go_backend = s:find_executable()

function! s:cp_of() abort
  return g:neochat#CP.of([s:go_backend, '--config', s:config_path], '.', [])
        " \ ['*writeln*', 'rooms'],
        " \ ['*read*', '_', s:line_separator]])
endfunction

function! neochat#protocol#lingr#establish() abort
  return {'protoname': 'lingr'}
endfunction

function! neochat#protocol#lingr#say(connection, message) abort
  let label = s:cp_of()
  call g:neochat#CP.queue(label, [
        \ ['*writeln*', printf('say:%s:%s', s:room_id, substitute(a:message, "\n", '\n', 'g'))],
        \ ['*read*', '[say]', s:line_separator]])
  " TODO make it non-blocking
  let [out, err, timeout_p] = g:neochat#CP.consume_all_blocking(label, '[say]', 2)
  if err !=# ''
    throw printf('say() Failed. stderr: %s', err)
  elseif timeout_p
    throw 'say() timed out.'
  endif
  return 1
endfunction

function! neochat#protocol#lingr#hear(connection) abort
  let label = s:cp_of()
  call g:neochat#CP.queue(label, [
        \ ['*writeln*', printf('fetch:%s', s:room_id)],
        \ ['*read*', '[fetch]', s:line_separator]])
  let [out, err, timeout_p] = g:neochat#CP.consume_all_blocking(label, '[fetch]', 2)
  if err !=# ''
    throw printf('hear() Failed. stderr: %s', err)
  elseif timeout_p
    throw 'hear() timed out.'
  endif

  " it'll be like [{'name': 'ujihisa', 'body': 'hi'}]
  let messages = map(split(out, "\n"), 'eval(v:val)')
  " echomsg string(['out', out, eval(out)])
  return map(messages, '{"name": v:val.nickname, "body": v:val.text}')
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let s:save_cpo = &cpo
set cpo&vim

function! s:render(messages) dict abort
  call self.m_history.open('history')
  call append(line('$'), a:messages)
endfunction

let s:ui_vanilla = {
      \ 'name': 'vanilla',
      \ 'render': function('s:render')}

" function! s:append(m, text) abort
"   let winnr = winnr()
"   call a:m.do('wincmd %s')
"   try
"     call append(0, a:text)
"   finally
"     execute 'wincmd' winnr
"   endtry
" endfunction

function! s:focus_say(ui) abort
  call a:ui.m_say.open('say')
  startinsert!
endfunction

function! s:update(ui) abort
  let connection = a:ui.connection
  let messages = neochat#protocol#{connection.protoname}#hear(connection)
  call a:ui.m_history.open('history')
  call append(line('$'), messages)
endfunction

function! s:say(ui) abort
  let connection = a:ui.connection
  let message = 'hello hello'

  let result = neochat#protocol#{connection.protoname}#say(connection, message)
  if result
    execute 'normal! \<Esc>'
    call a:ui.m_say.do('bwipeout')
  else
    echoerr 'Failed to say'
  endif
endfunction

function! neochat#ui#vanilla#open(connection) abort
  let m_history = g:neochat#BM.new()
  call m_history.open('history')
  call append(0, '## neochat ##')
  setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  " TODO <Plug>
  nnoremap <buffer><nowait><silent> i :<C-u>call <SID>focus_say(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer><nowait><silent> a :<C-u>call <SID>focus_say(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer><nowait><silent> I :<C-u>call <SID>focus_say(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer><nowait><silent> A :<C-u>call <SID>focus_say(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer><nowait><silent> <C-l> :<C-u>call <SID>update(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer> q <C-w>c

  let m_say = g:neochat#BM.new()
  call m_say.open('say')
  setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  nnoremap <buffer> q <C-w>c
  inoremap <buffer> <S-Cr> <C-o>:call <SID>say(b:neochat_ui_vanilla_ui)<Cr>

  let ui = copy(s:ui_vanilla)
  let ui.m_history = m_history
  let ui.m_say = m_say
  let ui.connection = a:connection
  let b:neochat_ui_vanilla_ui = ui

  call m_say.close()
  call m_history.open('history')
  let b:neochat_ui_vanilla_ui = ui

  return ui
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let s:save_cpo = &cpo
set cpo&vim

function! s:render(messages) dict abort
  call s:append(self.m_history, map(copy(a:messages), 'v:val["name"] . ": " . v:val["body"]'))
endfunction

let s:ui_vanilla = {
      \ 'name': 'vanilla',
      \ 'render': function('s:render')}

function! s:append(m, text) abort
  let winnr = winnr()
  call a:m.do('wincmd %s')
  try
    call append(line('$'), a:text)
    $
  finally
    execute 'wincmd' winnr
  endtry
endfunction

function! s:focus_say(ui) abort
  call a:ui.m_say.open('say')
  setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  nnoremap <buffer> q <C-w>c
  inoremap <buffer> <S-Cr> <Esc>:call <SID>say(b:neochat_ui_vanilla_ui, join(getline(0, '$'), "\n"))<Cr>
  nnoremap <buffer> <S-Cr> :<C-u>call <SID>say(b:neochat_ui_vanilla_ui, join(getline(0, '$'), "\n"))<Cr>
  let b:neochat_ui_vanilla_ui = a:ui

  startinsert!
endfunction

function! s:say(ui, message) abort
  let connection = a:ui.connection

  let result = neochat#protocol#{connection.protoname}#say(connection, a:message)
  if result
    normal! gg"_dG
    call a:ui.m_say.close()
  else
    echoerr 'Failed to say'
  endif
endfunction

function! neochat#ui#vanilla#open(connection) abort
  let m_history = g:neochat#BM.new()
  call m_history.open('history')
  setlocal bufhidden=hide buftype=nofile noswapfile nobuflisted
  call append(0, ['## neochat ##', '* Press i to start saying', '* Press <S-Cr> to post.'])
  " TODO <Plug>
  nnoremap <buffer><nowait><silent> i :<C-u>call <SID>focus_say(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer><nowait><silent> a :<C-u>call <SID>focus_say(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer><nowait><silent> I :<C-u>call <SID>focus_say(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer><nowait><silent> A :<C-u>call <SID>focus_say(b:neochat_ui_vanilla_ui)<Cr>
  nnoremap <buffer> q <C-w>c

  let m_say = g:neochat#BM.new()

  let ui = copy(s:ui_vanilla)
  let ui.m_history = m_history
  let ui.m_say = m_say
  let ui.connection = a:connection
  let b:neochat_ui_vanilla_ui = ui

  call m_say.close()
  let b:neochat_ui_vanilla_ui = ui

  return ui
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let s:patterns = {
    \ 'char': ['\%#\S', '\S\%#'],
    \ 'word': ['\S*\%#\s\@!\S*', '\S*\%#\S*'],
    \ 'line': ['.*\%#.*', '.*\%#.*'],
    \ 'none': ['\_.\@!', '\_.\@!'] }

function! s:pattern(name, mode)
    if index(['char', 'word', 'line', 'none'], a:name) == -1
        throw a:name
    endif
    return s:patterns[a:name][a:mode]
endfunction

" Clear augroup secret-WINID-BUFNR and remove BUFNR from w:secret_state
function! s:clear(w, b)
    execute 'augroup secret-' . a:w . '-' . a:b
        autocmd!
    augroup END
    execute 'augroup! secret-' . a:w . '-' . a:b

    let active = win_getid()
    if getwininfo(a:w) != []
        call win_gotoid(a:w)
        unlet w:secret_state[a:b]
        if w:secret_state == {}
            unlet w:secret_state
        endif
    endif
    call win_gotoid(active)
endfunction

function! s:enable_mappings()
    if exists('g:secret_quickhide')
        execute 'nnoremap <buffer> <silent>'
            \ g:secret_quickhide ':syntax clear SecretVisible<CR>'
    endif
endfunction

function! s:disable_mappings()
    if exists('g:secret_quickhide')
        execute 'nunmap <buffer>' g:secret_quickhide
    endif
endfunction

function! s:buf_win_autocmd(group, ...)
    return 'autocmd ' . a:group . ' <buffer> if win_getid() == ' . win_getid()
        \ . ' | ' . join(a:000, ' | ') . ' | endif'
endfunction

" Enable secret view
function! s:enable(npat, ipat, cchar)
    if !exists('w:secret_state')
        let w:secret_state = {}
    endif

    if !has_key(w:secret_state, bufnr())
        let w:secret_state[bufnr()] = {}
        let w:secret_state[bufnr()].syntax = &syntax
        let w:secret_state[bufnr()].concealcursor = &concealcursor
        let w:secret_state[bufnr()].conceallevel = &conceallevel
        ownsyntax
        setlocal concealcursor =nvic
        setlocal conceallevel =2
    endif

    call s:enable_mappings()

    syntax clear
    execute 'syntax match SecretHidden ''\S'' conceal cchar=' . a:cchar . ' containedin=ALLBUT,SecretVisible'
    execute 'syntax match SecretVisible ''' . a:npat . ''''

    execute 'augroup secret-' . win_getid() . '-' . bufnr()
        autocmd!

        " Normal mode
        execute (s:buf_win_autocmd('InsertLeave,CursorMoved',
            \ 'syntax clear SecretVisible',
            \ 'syntax match SecretVisible ''' . a:npat . ''''))

        if g:secret_timeout_normal
            execute (s:buf_win_autocmd('CursorHold', 'syntax clear SecretVisible'))
        endif

        " Insert mode
        execute (s:buf_win_autocmd('InsertEnter,CursorMovedI',
            \ 'syntax clear SecretVisible',
            \ 'syntax match SecretVisible ''' . a:ipat . ''''))

        if g:secret_timeout_insert
            execute (s:buf_win_autocmd('CursorHoldI', 'syntax clear SecretVisible'))
        endif

        " Window left
        execute (s:buf_win_autocmd('WinLeave',
            \ 'syntax clear SecretVisible',
            \ 'call s:disable_mappings()'))

        " Window entered
        execute (s:buf_win_autocmd('WinEnter', 'call s:enable_mappings()'))

        " Window or buffer closed
        execute 'autocmd WinEnter * if getwininfo(' . win_getid() . ') == []'
            \ '| call s:clear(' . win_getid() . ', ' . bufnr() . ')'
            \ '| call s:disable_mappings()'
            \ '| endif'
        execute 'autocmd BufDelete <buffer>'
            \ ' call s:clear(' . win_getid() . ', ' . bufnr() . ')'

        " Hidden buffer displayed
        execute (s:buf_win_autocmd('BufWinEnter',
            \ 'execute ''ownsyntax''',
            \ 'syntax clear',
            \ 'syntax match SecretHidden ''\S'' conceal cchar=' . a:cchar . ' containedin=ALLBUT,SecretVisible',
            \ 'syntax match SecretVisible ''' . a:npat . ''''))
    augroup END
endfunction

" Disable secret view
function! s:disable()
    " If secret view not enabled for the current (window, buffer)
    if !exists('w:secret_state') || !has_key(w:secret_state, bufnr())
        return
    endif

    " Restore saved buffer state
    syntax clear
    execute 'set syntax =' . w:secret_state[bufnr()].syntax
    execute 'setlocal concealcursor =' . w:secret_state[bufnr()].concealcursor
    execute 'setlocal conceallevel =' . w:secret_state[bufnr()].conceallevel

    " Clear autocommands and saved state
    call s:clear(win_getid(), bufnr())

    " Clear mappings
    call s:disable_mappings()
endfunction

" Entry point for Secret command
function! secret#secret(enable, ...)
    if a:enable
        try
            if a:0 == 0
                call s:enable(
                    \ s:pattern(exists('g:secret_visibility_normal') ?
                        \ g:secret_visibility_normal : g:secret_visibility, 0),
                    \ s:pattern(exists('g:secret_visibility_insert') ?
                        \ g:secret_visibility_insert : g:secret_visibility, 1),
                    \ g:secret_cchar)
            elseif a:0 == 1
                call s:enable(s:pattern(a:1, 0), s:pattern(a:1, 1), g:secret_cchar)
            elseif a:0 == 2
                call s:enable(s:pattern(a:1, 0), s:pattern(a:2, 1), g:secret_cchar)
            else
                echohl WarningMsg
                echo 'Secret: Too many arguments'
                echohl None
            endif
        catch
            echohl WarningMsg
            echo 'Secret: Invalid argument "' . v:exception . '"'
            echohl None
        endtry
    else
        call s:disable()
    endif
endfunction

function! secret#toggle()
    if !exists('w:secret_state') || !has_key(w:secret_state, bufnr())
        call secret#secret(1)
    else
        call secret#secret(0)
    endif
endfunction

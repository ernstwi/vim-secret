command! -bang -nargs=* Secret call secret#secret(<bang>1, <f-args>)

if !exists('g:secret_cchar')
    let g:secret_cchar = '•'
endif

if !exists('g:secret_visibility')
    let g:secret_visibility = 'word'
endif

if !exists('g:secret_timeout_normal')
    let g:secret_timeout_normal = 1
endif

if !exists('g:secret_timeout_insert')
    let g:secret_timeout_insert = 0
endif

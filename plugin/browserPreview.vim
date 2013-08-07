if exists('g:pandocPreview')
    finish
endif

" varables setting start                {{{
if exists('g:pandocPreview_browser')
    let s:browser = g:pandocPreview_browser
else
    if has('unix')
        let s:browser = 'arora'
        "let s:browser = 'xdg-open'
    elseif has('win32') || has('win64')
        " code
    endif
endif
"need to add some codes to hand out the situation without commands

if exists('g:pandocPreview_interpreter')
    let s:interpreter = g:pandocPreview_interpreter
else
    let s:interpreter = 'pandoc -Ss -m -t html'
endif
"need to add some codes to hand out the situation without commands

if exists('g:pandocPreview_outputArgs')
    let s:outputArgs = g:pandocPreview_outputArgs
else
    let s:outputArgs = '-o'
endif

if exists('g:pandocPreview_tmpdir')
    let s:tmpdir = g:pandocPreview_tmpdir
else
    if has('unix')
        let s:tmpdir = '/tmp/browserPreview/'
    elseif has('win32') || has('win64')
        " code
    endif
endif

function! s:Prebuild()
    if !filewritable(s:tmpdir) && !isdirectory(s:tmpdir)
        call mkdir(s:tmpdir, 'p')
    endif
endfunction

function! s:Build()
    call s:Prebuild()
    let l:fileName   = expand('%')
    if has('unix')
        let l:tmpFile    = s:tmpdir .'/' .l:fileName
    elseif has('win32') || has('win64')
        let l:tmpFile    = s:tmpdir .'\' .l:fileName
    endif
    let l:tmpFileOut = l:tmpFile .'.html'
    let l:line = getline(0,'$')
    call writefile(l:line, l:tmpFile)
    if has('unix')
        silent exe '!'. s:interpreter .' ' .l:tmpFile .' ' .s:outputArgs .' ' .l:tmpFileOut .'&'
    elseif has('win32') || has('win64')
    endif
    "if you need to debug your interpreter args, just remove the silent word.
    return l:tmpFileOut
endfunction

function! s:Preview()
    if has('unix')
        silent exe '!'. s:browser .' ' .s:Build() .'&' | redraw!
    elseif has('win32') || has('win64')
    endif
endfunction

command! BrowserPreviewSave call <SID>Build()
command! BrowserPreviewView call <SID>Preview()

function! s:cmdTest(command)    "Return 0 if command not found.
    if has('unix')
        let l:cmdTestReturn = system('which ' .a:command)
        if match(l:cmdTestReturn, 'which') >=0 || match(l:cmdTestReturn, ':') >= 0
            return 0
        else
            return 1
        endif
    elseif has('win32') || has('win64')
    endif
endfunction

if !s:cmdTest(s:browser) ||
\   !s:cmdTest(strpart(s:interpreter, 0, match(s:interpreter, ' ')))
    finish
endif

let g:browserPreview = 1

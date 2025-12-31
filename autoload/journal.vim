" ----------------------------------------------------------------------
" vim-journal   filetype plugin / journal for Vim
" Maintainer:   John Davis <jdavcs@gmail.com>
" File:         autoload/journal.vim
" Source:       https://github.com/jdavcs/vim-journal
" License:      MIT
" Last Updated: 2025 Dec 30 10:52:49 PM EST
" ----------------------------------------------------------------------


" Attempts to switch to writing mode (vim-write must be installed)
function! journal#set_writingmode()
    "check if write.vim exists >> check current mode >> switch to writing mode
    if exists("g:write_loaded")
        if g:write_writingmode == 0
            :WriteToggleWritingMode
        endif
    endif
endfunction


" Insert new date + separator
function! journal#insert_date()
    let l:sep = repeat("=", 78) "  separator (horizontal '=' line)
    " 2 lines down + separator + date + separator + 2 lines down
    let l:cmd = "normal! Go\<CR>" . l:sep . "\<CR>" .
                \ strftime("%m/%d/%Y") . "\<CR>\<CR>"
    execute l:cmd
endfunction



" Inserts a todo item
function! journal#insert_todo()
    execute "normal! o" . g:journal_options.todo
endfunction


" Called by end-user code (most likely from .vimrc)
" arguments: 
"   term:    name of term (no spaces or special characters)
"   mapping: shortcut used to insert the term into the text
"   hlgroup: highlight group to highlight the term
function! journal#addterm(term, mapping, hlgroup)
    "add term to term list
    call add(g:journal_terms, a:term)

    "add mapping for inserting term
    let l:cmd = "nnoremap <buffer> <silent> " . 
        \ a:mapping . " :call journal#insert_term('" . a:term . "')<CR>a"
    exe l:cmd
    
    "add syntax info
    let l:syntaxgroup = "journal" . a:term
    let l:cmd = "syntax match " . l:syntaxgroup . " /" . 
        \ g:journal_options.regex_prefix . a:term . "/"
    exe l:cmd

    let l:cmd = "highlight link " . l:syntaxgroup . " " . a:hlgroup
    exe l:cmd

endfunction


" Called from mapping created by journal#addterm()
function! journal#insert_term(term)
    execute "normal! o" . a:term . g:journal_options.suffix
endfunction


" Locates todo + custom term paragraphs;
" copies their content to the top of the file,
" separating them by fold markers
function! journal#make_summaries()
    call cursor(1,1) " move cursor to top of file
    " mark first spot for summary block
    normal! mn

    " process todo paragraphs
    call s:find_paragraphs('TODO', '^\[ ]TODO')

    " process custom term paragraphs
    for term in g:journal_terms
        let pattern = g:journal_options.regex_prefix . term
        call s:find_paragraphs(term, pattern)
    endfor

    " close all folds
    normal! zM
endfunction


" finds all pragraphs based on pattern
function! s:find_paragraphs(term, pattern)
    " move to target
    normal `n

    " add opening folding marker 
    execute 'normal! i{{{ ' . a:term . "\<cr>\<cr>"

    "set mark for target location inside summary block
    normal! mt

    " add closing folding marker 
    execute 'normal! o}}}' . a:term . "\<cr>\<cr>"

    " mark spot for next summary block below prev block
    normal! mn

    " process located paragraphs
    let l:line = search(a:pattern, 'W')
    while l:line > 0
        call s:copy_paragraph()
        let l:line = search(a:pattern, 'W')
    endwhile

    " move cursor back to the top of the file
    normal! gg
endfunction


" copies current paragraph to summary block 
function! s:copy_paragraph()
    " set marker in text
    normal! mk 
    " yank a paragraph
    normal! yap
    " move cursor to target location in summary block
    normal! `t
    " put yanked paragraph BEFORE mark
    normal! P
    " move cursor back to mark in text
    normal! `k
endfunction

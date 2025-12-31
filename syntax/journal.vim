" ----------------------------------------------------------------------
" vim-journal   syntax file
" Maintainer:   John Davis <jdavcs@gmail.com>
" File:         syntax/journal.vim
" Source:       https://github.com/jdavcs/vim-journal
" License:      MIT
" Last Updated: 2025 Dec 30 10:51:06 PM EST
" ----------------------------------------------------------------------

if version < 600
    syntax clear
elseif exists("b:current_syntax")
  finish
endif

syntax case match

syntax region journalTodo start=/\[ ]TODO/ end=/\n\n/
syntax region journalDone start=/\[x]TODO/ end=/\n\n/

syntax match journalSeparator /^=\+$/
syntax match journalDate /^[0-1][0-9]\/[0-3][0-9]\/[0-9][0-9][0-9][0-9]$/

" markup: **abc** displays abc highlighted, concealing the markup (**)
syntax region journalMarkupStrong matchgroup=strong start="\*\*" end="\*\*" concealends


" link to predefined highlight groups
highlight link journalTodo PreProc
highlight link journalDone Comment
highlight link journalSeparator Type
highlight link journalDate Type

highlight link journalMarkupStrong Identifier

let b:current_syntax = "journal"

" hide markup characters
set conceallevel=2

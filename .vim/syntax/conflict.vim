" Vim syntax file
" Language: CVS conflict file
" Maintainer: Alex Jakushev (Alex.Jakushev@kemek.lt)
" Last Change:  2002.12.30

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match cvsStart "<<<*"
syn match cvsStartLineErr "^<<<<<<< .*" contained
syn match cvsStartLine "^<<<<<<< .*" contains=cvsStart contained

syn match cvsEnd ">>>*"
syn match cvsEndLineErr "^>>>>>>> .*"
syn match cvsEndLine "^>>>>>>> .*" contains=cvsEnd contained

syn match cvsMiddleErr "^=======$" contained
syn match cvsMiddle "^=======$" containedin=cvsSrvVer

syn region cvsThisVer start="^<<<<<<< " end="^=======$"me=s-2 contains=cvsStartLine,cvsEndLineErr
syn sync match SyncThisVer grouphere cvsThisVer "^<<<<<<< "

syn region cvsSrvVer start="^=======$" end="^>>>>>>> .*" contains=cvsMiddle,cvsEndLine,cvsStartLineErr keepend
syn sync match SyncThisVer grouphere cvsSrvVer "^=======$"

hi          cvsStartLine    guifg=LightGreen
hi          cvsEndLine      guifg=LightRed
hi          cvsStart        guifg=Orange
hi          cvsEnd          guifg=Orange
hi          cvsMiddle       guifg=Orange
hi          cvsThisVer      guibg=DarkGreen guifg=White
hi          cvsSrvVer       guibg=DarkRed   guifg=White
hi def link cvsEndLineErr   Error
hi def link cvsStartLineErr Error
hi def link cvsMiddleErr    Error

let b:current_syntax = "conflict"


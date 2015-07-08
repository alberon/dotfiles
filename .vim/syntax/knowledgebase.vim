if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Stars ***
syn match kbStars "\*\*\*"
hi kbStars guifg=Blue guibg=Yellow

" Project:
syn match kbProject "^[^ ].*:$" contains=kbProjectImportant,kbProjectSeparator,kbProjectColon
hi kbProject guifg=#80a0ff

syn match kbProjectColon ":$" contained
hi kbProjectColon guifg=#000000

" *** Project:
syn match kbProjectImportant "\*\*\*" contained
hi kbProjectImportant guifg=Black guibg=#80a0ff

" Project :: Subproject
syn match kbProjectSeparator " :: " contained
hi kbProjectSeparator guifg=#ff9900

" Separator
"--------------------------------------------------------------------------------
syn match kbSeparator "^-\{80}$"
hi kbSeparator guifg=#d47fff

"================================================================================
" Heading
"================================================================================
syn region kbHeading start="^=\{80}$" end="^=\{80}$"
hi kbHeading guifg=#d47fff

" * Green item
syn match kbItemNormal "^ \* .*$"he=s+3 contains=kbItemNormalText
hi kbItemNormal guifg=#99ff00

syn match kbItemNormalText ".*"hs=s+3 contains=kbItemNormalImportant contained
hi kbItemNormalText guifg=#ffffff

syn match kbItemNormalImportant "\*\*\*" contained
hi kbItemNormalImportant guifg=Black guibg=#a6f089

" * @Orange item
syn match kbItemAgenda "^ \* [\* ]*@.*$"he=s+3 contains=kbItemAgendaText
hi kbItemAgenda guifg=#ff9900

syn match kbItemAgendaText ".*"hs=s+3 contains=kbItemAgendaImportant contained
hi kbItemAgendaText guifg=#ffffff

syn match kbItemAgendaImportant "\*\*\*" contained
hi kbItemAgendaImportant guifg=Black guibg=#f0ca89

" * WF Red item
syn match kbItemWaitingFor "^ \* [\* ]*WF .*$"he=s+3 contains=kbItemWaitingForText
hi kbItemWaitingFor guifg=#8e0000

syn match kbItemWaitingForText ".*"hs=s+3 contains=kbItemWaitingForImportant contained
hi kbItemWaitingForText guifg=#ffffff

syn match kbItemWaitingForImportant "\*\*\*" contained
hi kbItemWaitingForImportant guifg=Black guibg=#f09389

" Comment (indented)
syn match kbComment "^   .*$"
hi kbComment guifg=#808080

" Vim modeline
syn match kbVimModeline "^ vim:.*$"
hi kbVimModeline guifg=#222222

let b:current_syntax = "knowledgebase"

" To make Vim ignore the modeline above:
" vim:

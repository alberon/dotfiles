if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Project
syn match todoProject "^[^ ].*" contains=todoProjectImportant,todoProjectSeparator
hi todoProject guifg=#80a0ff

syn match todoProjectImportant "\*\*\*" contained
hi todoProjectImportant guifg=Black guibg=#80a0ff

syn match todoProjectSeparator " :: " contained
hi todoProjectSeparator guifg=#ff9900

" Separator
syn match todoSeparator "^-\{80}$"
hi todoSeparator guifg=#d47fff

" Heading
syn region todoHeading start="^=\{80}$" end="^=\{80}$"
hi todoHeading guifg=#d47fff

" Green item
syn match todoItemNormal "^ \* .*$"he=s+3 contains=todoItemNormalText
hi todoItemNormal guifg=#99ff00

syn match todoItemNormalText ".*"hs=s+3 contains=todoItemNormalImportant contained
hi todoItemNormalText guifg=#ffffff

syn match todoItemNormalImportant "\*\*\*" contained
hi todoItemNormalImportant guifg=Black guibg=#a6f089

" Orange item
syn match todoItemAgenda "^ \* [\* ]*@.*$"he=s+3 contains=todoItemAgendaText
hi todoItemAgenda guifg=#ff9900

syn match todoItemAgendaText ".*"hs=s+3 contains=todoItemAgendaImportant contained
hi todoItemAgendaText guifg=#ffffff

syn match todoItemAgendaImportant "\*\*\*" contained
hi todoItemAgendaImportant guifg=Black guibg=#f0ca89

" Red item
syn match todoItemWaitingFor "^ \* [\* ]*WF .*$"he=s+3 contains=todoItemWaitingForText
hi todoItemWaitingFor guifg=#8e0000

syn match todoItemWaitingForText ".*"hs=s+3 contains=todoItemWaitingForImportant contained
hi todoItemWaitingForText guifg=#ffffff

syn match todoItemWaitingForImportant "\*\*\*" contained
hi todoItemWaitingForImportant guifg=Black guibg=#f09389

" Date item
syn match todoItemDate "^ # .*$"he=s+3 contains=todoItemDateText
hi todoItemDate guifg=#80a0ff

syn match todoItemDateText ".*"hs=s+3 contains=todoItemDateImportant contained
hi todoItemDateText guifg=#ffffff

syn match todoItemDateImportant "\*\*\*" contained
hi todoItemDateImportant guifg=Black guibg=#80a0ff

" Comment
syn match todoComment "^   .*$"
hi todoComment guifg=#808080

" Vim modeline
syn match todoVimModeline "^ vim:.*$"
hi todoVimModeline guifg=#222222

let b:current_syntax = "todolist"



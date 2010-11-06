if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Stars
syn match kbStars "\*\*\*"
hi kbStars guifg=Blue guibg=Yellow

" Separator
syn match kbSeparator "^-\{80}$"
hi kbSeparator guifg=#d47fff

" Heading
syn region kbHeading start="^=\{80}$" end="^=\{80}$"
hi kbHeading guifg=#d47fff

" Bullet
syn match kbBullet "^ \* .*$"he=s+3
hi kbBullet guifg=#99ff00

" Vim modeline
syn match todoVimModeline "^ vim:.*$"
hi todoVimModeline guifg=#222222

let b:current_syntax = "knowledgebase"



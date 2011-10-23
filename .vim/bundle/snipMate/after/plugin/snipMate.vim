" These are the mappings for snipMate.vim. Putting it here ensures that it
" will be mapped after other plugins such as supertab.vim.
if !exists('loaded_snips') || exists('s:did_snips_mappings')
    finish
endif
let s:did_snips_mappings = 1

ino <silent> <tab> <c-r>=TriggerSnippet(0)<cr>
snor <silent> <tab> <esc>i<right><c-r>=TriggerSnippet(1)<cr>
ino <silent> <s-tab> <c-r>=BackwardsSnippet(0)<cr>
snor <silent> <s-tab> <esc>i<right><c-r>=BackwardsSnippet(1)<cr>
ino <silent> <c-r><tab> <c-r>=ShowAvailableSnips()<cr>

" The default mappings for these are annoying & sometimes break snipMate.
" You can change them back if you want, I've put them here for convenience.

" DJM: This makes the cursor jump when backspacing highlighted text
"snor <bs> b<bs>
snor <bs> <bs>i

" DJM: This breaks Ctrl+X (Cut)
"snor <c-x> b<bs><c-x>
snor <c-x> <c-o>"+xi

" DJM: These make the cursor jump when text is highlighted from right to left
" But I like the way it works, so I've found a different way to do it...
" TODO: Is there a better way to deselect text than <left><right>?
"snor <right> <esc>a
"snor <left> <esc>bi
snor <left> <esc>g`<
snor <right> <esc>g`>

" DJM: These also cause problems when enabled, but removing them doesn't seem
" to break anything...
"snor ' b<bs>'
"snor ` b<bs>`
"snor % b<bs>%
"snor U b<bs>U
"snor ^ b<bs>^
"snor \ b<bs>\
"snor <c-x> b<bs><c-x>

" By default load snippets in snippets_dir
if empty(snippets_dir)
    finish
endif

call GetSnippets(snippets_dir, '_') " Get global snippets

au FileType * if &ft != 'help' | call GetSnippets(snippets_dir, &ft) | endif

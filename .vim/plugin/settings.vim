" Use UTF-8 for everything, but no byte-order mark because it breaks things
set encoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,utf-8,default,latin1
set nobomb

" Use 4 spaces to indent (use ":ret" to convert tabs to spaces)
set expandtab tabstop=4 softtabstop=4 shiftwidth=4

" Use visual mode instead of select mode (for both keyboard and mouse)
set selectmode=

" Allow pressing arrows (without shift) in visual mode
" This gives the best of both worlds - you can use shift+arrow in insert mode to
" quickly start visual mode (instead of <Esc>v<Arrow>), but still use the arrow
" keys in visual mode as normal (instead of having to hold shift)
" TODO: Learn to use hjkl instead of the arrow keys so this isn't an issue!
set keymodel-=stopsel

" Case-insensitive search unless there's a capital letter (then case-sensitive)
set ignorecase
set smartcase

" Highlight search results as you type
"set hlsearch
set incsearch

" Default to replacing all occurrences in :s (swaps the meaning of the /g flag)
set gdefault

" Wrap to the next line for all commands that move left/right
set whichwrap=b,s,h,l,<,>,~,[,]

" Show line numbers
set number

" Always show the status line
set laststatus=2

" Open split windows below/right instead of above/left by default
set splitbelow
set splitright

" Shorten some status messages, and don't show the intro splash screen
set shortmess=ilxtToOI

" Use dialogs to confirm things like quiting without saving, instead of failing
set confirm

" Don't put two spaces between sentences
set nojoinspaces

" Always write a separate backup, don't use renaming because it resets the
" executable flag when editing over Samba
set backupcopy=yes

" Don't hide the mouse when typing
set nomousehide

" Remember 50 history items instead of 20
set history=50

" Show position in the file in the status line
set ruler

" Show selection size
set showcmd

" Show list of matches when tab-completing commands
set wildmenu

" Don't redraw the screen while executing macros, etc.
set lazyredraw

" Enable modeline support, because Debian disables it (for security reasons)
set modeline

" Allow hidden buffers, so I can move between buffers without having to save first
set hidden

" Use existing window/tab if possible when switching buffers
set switchbuf=useopen,usetab

" Show the filename in the titlebar when using console vim
set title

" Keep 5 lines/columns of text on screen around the cursor
" Removed 2012-08-13 because it makes double-clicking near the edge of the
" screen impossible
"set scrolloff=5
"set sidescroll=1
"set sidescrolloff=5

" Enable mouse support in all modes
if has("mouse")
    set mouse=a
endif

" Automatically fold when markers are used
if has("folding")
    set foldmethod=marker
endif

" Remove all the ---s after a fold to make it easier to read
set fillchars=vert:\|,fold:\ 

" Keep an undo history after closing Vim (Vim 7.3+)
if version >= 703
    set undofile
endif

" In case I ever use encryption, Blowfish is more secure (but requires Vim 7.3+)
if version >= 703
    set cryptmethod=blowfish
endif

" Show tabs and trailing spaces...
set list
set listchars=tab:-\ ,trail:.

" Except in snippet files because they have to use tabs
au FileType snippet,snippets setl listchars+=tab:\ \ 

" Use the temp directory for all backups and swap files, instead of cluttering
" up the filesystem with .*.swp and *~ files
" Note the trailing // means include the full path of the current file so
" files with the same name in different folders don't conflict
set backupdir=~/tmp/vim//
set directory=~/tmp/vim//
if version >= 703
    set undodir=~/tmp/vim//
endif

" Remember mark positions
set viminfo+=f1

" Indenting
set autoindent
"set smartindent    " Removed because it prevent #comments being indented
"set cindent        " Removed because it indents things when it shouldn't
"set cinoptions-=0# " So #comments aren't unindented with cindent
set formatoptions+=ro " Duplicate comment lines when pressing enter

" No GUI toolbar - I never use it
set guioptions-=T

" Keep scrollbars on the right - the left scrollbar doesn't work with my
" gaming mouse software
set guioptions-=L

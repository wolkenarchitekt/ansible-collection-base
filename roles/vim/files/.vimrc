" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction

syntax on
"filetype indent plugin on

set softtabstop=2 expandtab tabstop=2

au FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4
"autocmd BufRead,BufNewFile   ruleis Makefile set noexpandtab
autocmd FileType make set noexpandtab

"autocmd FileType sls set nocompatible filetype plugin indent on

au FileType changelog       match ErrorMsg '\%>80v.\+' 
au FileType changelog       set colorcolumn=80
au FileType dch       set colorcolumn=80

au FileType sh setl sw=4 sts=4 et

au BufEnter,BufNew **/.git/config set noexpandtab

"Always show tab bar
set showtabline=2

"Ctrl+T=next tab, Ctrl+Shift+Tab=previous tab
map <C-S-T> :tabprevious<CR>
nmap <C-S-T> :tabprevious<CR>
imap <C-S-T> <Esc>:tabprevious<CR>i

map <C-T> :tabnext<CR>
nmap <C-T> :tabnext<CR>
imap <C-T> <Esc>:tabnext<CR>i



" disable for snippet plugin
set paste

" Disable ALL indention by pressing F2
nnoremap <F2> :setl noai nocin nosi inde=<CR>

" Save root file with W
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

highlight OverLength ctermbg=red ctermfg=white guibg=#592929 
"au FileType python match OverLength /\%81v.*/

"autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
"autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

noremap <silent> <c-s-up> :call <SID>swap_up()<CR>
noremap <silent> <c-s-down> :call <SID>swap_down()<CR>

" disable pyflakes
let b:did_pyflakes_plugin=1

"  will make /-style searches case-sensitive only if there is a capital letter in the search expression. *-style searches continue to be consistently case-sensitive
set ignorecase 
set smartcase

" Scroll when reaching 3 lines before margin
set scrolloff=3

" Run current script with R
command R !./%

" Show row/column on bottom
set ruler

" ================ Search Settings  =================

set incsearch        "Find the next match as we type the search
set hlsearch         "Hilight searches by default
set viminfo='100,f1  "Save up to 100 marks, enable capital marks

" ================ Turn Off Swap Files ==============

set noswapfile
set nobackup
set nowb

" ================ Persistent Undo ==================
" Keep undo history across sessions, by storing in file.
" Only works all the time.

set undodir=~/.vim/backups
set undofile

" Display tabs and trailing spaces visually
" set list listchars=tab:\ \ ,trail:·


""""""""""""""""""""""""""""""
" => Statusline
""""""""""""""""""""""""""""""
" Always hide the statusline
set laststatus=2

" Format the statusline
set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c


function! CurDir()
    let curdir = substitute(getcwd(), '/Users/amir/', "~/", "g")
    return curdir
endfunction

function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    else
        return ''
    endif
endfunction

" When vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~/.vim_runtime/vimrc


" If the current buffer has never been saved, it will have no name,
" call the file browser to save it, otherwise just save it.
command -nargs=0 -bar Update if &modified 
                           \|    if empty(bufname('%'))
                           \|        browse confirm write
                           \|    else
                           \|        confirm write
                           \|    endif
                           \|endif
nnoremap <silent> <C-S> :<C-u>Update<CR>

inoremap <c-s> <c-o>:Update<CR>

" Line number
"set number
"highlight LineNr ctermfg=darkgrey

" Completion files are Bash
au BufNewFile,BufRead *.completion set filetype=sh

" Run python
nnoremap <silent> <F9> :!clear;python %<CR>

silent !mkdir ~/.vim/backups > /dev/null 2>&1

set runtimepath^=~/.vim/bundle/node

" Pathogen
execute pathogen#infect()
syntax on
filetype plugin indent on

" Bash indent
filetype indent on
set smartindent

" JSON
autocmd Filetype json setlocal ts=2 sw=2 expandtab

" Disable mouse select
set mouse-=a

" Disable indent on paste
set nopaste

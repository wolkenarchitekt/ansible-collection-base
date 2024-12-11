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
filetype indent plugin on

set softtabstop=2 expandtab tabstop=2

au FileType python setlocal tabstop=8 expandtab shiftwidth=4 softtabstop=4

set paste

" Disable ALL indention by pressing F8
nnoremap <F2> :setl noai nocin nosi inde=<CR>

" Save root file with W
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!

highlight OverLength ctermbg=red ctermfg=white guibg=#592929 
au FileType python match OverLength /\%81v.*/

"autocmd BufRead *.py set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
"autocmd BufRead *.py set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

noremap <silent> <c-s-up> :call <SID>swap_up()<CR>
noremap <silent> <c-s-down> :call <SID>swap_down()<CR>

" disable pyflakes
let b:did_pyflakes_plugin=1

" set number

"  will make /-style searches case-sensitive only if there is a capital letter in the search expression. *-style searches continue to be consistently case-sensitive
set ignorecase 
set smartcase

" Scroll when reaching 3 lines before margin
set scrolloff=3

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
set list listchars=tab:\ \ ,trail:·

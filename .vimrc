set t_Co=16

let mapleader=" "

set showmode                    " always show what mode we're currently editing in
set expandtab                   " expand tabs by default (overloadable per file type later)
set tabstop=2                   " a tab is four spaces
set softtabstop=2               " when hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=2                " number of spaces to use for autoindenting
set bs=2
set paste
"set autoindent
"set copyindent
set ignorecase
set smartcase
execute pathogen#infect()
syntax on
filetype plugin indent on
set hlsearch
set incsearch

" Remaps Git Gutter hunk movement from ]h, [h to gh, gH
nmap gh <Plug>GitGutterNextHunk
nmap gH <Plug>GitGutterPrevHunk

" Vim-Airline
"let g:airline#extensions#tabline#enabled = 1
set laststatus=2
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'i'  : 'I',
    \ 'R'  : 'R',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'V',
    \ '' : 'V',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
    \ }

" Gundo
nnoremap U :GundoToggle<CR>
set undofile
set undodir=~/.vim/undo

" CtrlP + CtrlP-Cmatcher
if executable('ag')
  let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  noremap <leader>f :CtrlPClearCache<CR>:CtrlPRoot<CR>
else
  let g:ctrlp_lazy_update = 75
  set wildignore+=*/tmp/*,*/img/*,*/images/*,*/imgs/*,*.so,*.swp,*.zip,*/\.git/*,*/log/*
  let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
  noremap <leader>f :CtrlPRoot<CR>
endif

" Only for Colemak keyboards, remap hjkl
"noremap k j
"noremap j h
"noremap h k
"noremap <C-W>k <C-W>j
"noremap <C-W>j <C-W>h
"noremap <C-W>h <C-W>k
"noremap <C-W>K <C-W>J
"noremap <C-W>J <C-W>H
"noremap <C-W>H <C-W>K

" opens search results in a window w/ links and highlight the matches
if executable('ag')
  command! -nargs=+ AG execute 'silent Ag! <args>' | copen 33 | redraw! | execute 'silent /<args>'
  " leader + D searches for the word under the cursor
  nmap <leader>d :AG <c-r>=expand("<cword>")<cr><cr>
else
  command! -nargs=+ Grep execute 'silent grep! -Ir --exclude=\*.{json,pyc,tmp,log} --exclude=tags --exclude-dir=*\tmp\* --exclude-dir=*\.git\* --exclude-dir=*\.idea\* . -e <args>' | copen 33 | redraw! | execute 'silent /<args>'
  " leader + D searches for the word under the cursor
  nmap <leader>d :Grep <c-r>=expand("<cword>")<cr><cr>
endif

" Test helpers from Gary Bernhardt's screen cast:
" https://www.destroyallsoftware.com/screencasts/catalog/file-navigation-in-vim
" https://www.destroyallsoftware.com/file-navigation-in-vim.html
function! RunTests(filename)
    " Write the file and run tests for the given filename
    :w
    :silent !echo;echo;echo;echo;echo
    exec ":!time spring rspec " . a:filename
endfunction

function! SetTestFile()
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

function! RunTestFile(...)
    if a:0
        let command_suffix = a:1
    else
        let command_suffix = ""
    endif

    " Run the tests for the previously-marked file.
    let in_spec_file = match(expand("%"), '_spec.rb$') != -1
    if in_spec_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        return
    end
    call RunTests(t:grb_test_file . command_suffix)
endfunction

function! RunNearestTest()
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number)
endfunction

" Run this file
map <leader>m :call RunTestFile()<cr>
" Run only the example under the cursor
map <leader>. :call RunNearestTest()<cr>
" Run all test files
" map <leader>a :call RunTests('spec')<cr>

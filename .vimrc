set t_Co=16

let mapleader=" "

set undofile
set undodir=~/.vim/undo
set showmode                    " always show what mode we're currently editing in
set expandtab                   " expand tabs by default (overloadable per file type later) (WARNING: this gets reset when :set paste is true!)
set tabstop=2                   " a tab is four spaces
set softtabstop=2               " when hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=2                " number of spaces to use for autoindenting
set bs=2
set autoindent
set ignorecase
set smartcase
set clipboard=unnamed           " copy the default buffer to clipboard
execute pathogen#infect()
syntax on
filetype plugin indent on
set hlsearch
set incsearch
set list
set listchars=tab:▸·
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59

" 100 characters line width highlight
hi LineOverflow  ctermfg=white ctermbg=red guifg=white guibg=#FF2270
autocmd BufEnter,VimEnter,FileType *.rb,*.coffee,*.js let w:m2=matchadd('LineOverflow', '\%>100v.\+', -1)
autocmd BufEnter,VimEnter,FileType,VimEnter *.rb,*.coffee,*.js autocmd WinEnter *.rb,*.coffee let w:created=1
autocmd BufEnter,VimEnter,FileType,VimEnter *.rb,*.coffee,*.js let w:created=1

" gp remaps to "select recently changed text" (e.g. from paste)
nnoremap gp `[v`]

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

" Vim-Do async shell configs
let g:check_interval = 500
let g:do_new_buffer_size = 10
let g:do_refresh_key = "<F37>"

" Mundo, an active fork of Gundo:
" https://github.com/simnalamburt/vim-mundo
nnoremap U :MundoToggle<CR>
set undofile
set undodir=~/.vim/undo

" CtrlP + CtrlP-Cmatcher
" Use the maintained version of CtrlP:
" https://github.com/ctrlpvim/ctrlp.vim
if executable('ag')
  if !empty(glob("~/.vim/bundle/ctrlp-cmatcher/autoload/matcher.vim"))
    let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }
  endif
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  noremap <leader>f :CtrlPClearCache<CR>:CtrlPRoot<CR>
else
  let g:ctrlp_lazy_update = 75
  set wildignore+=*/tmp/*,*/img/*,*/images/*,*/imgs/*,*.so,*.swp,*.zip,*/\.git/*,*/log/*
  let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
  noremap <leader>f :CtrlPRoot<CR>
endif

" Smart tab completion. Credit: Gary Bernhardt
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
 return "\<tab>"
  else
 return "\<c-p>"
  endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

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
if exists(':Ag')
  command! -nargs=+ Grep execute 'silent Ag! "<args>"' | copen 15 | redraw! | execute 'silent /<args>'
else
  command! -nargs=+ Grep execute 'silent grep! -Ir --exclude=\*.{json,pyc,tmp,log} --exclude=tags --exclude-dir=*\tmp\* --exclude-dir=*\.git\* --exclude-dir=*\.idea\* --exclude-dir=*\*cache\* . -e "<args>"' | copen 15 | redraw! | execute 'silent /"<args>"'
endif
" leader + D searches for the word under the cursor
nmap <leader>d :Grep <c-r>=expand("<cword>")<cr><cr>

" Test helpers from Gary Bernhardt's screen cast:
" https://www.destroyallsoftware.com/screencasts/catalog/file-navigation-in-vim
" https://www.destroyallsoftware.com/file-navigation-in-vim.html
function! RunTests(filename, async)
    " Write the file and run tests for the given filename
    :w
    ":silent !echo;echo;echo;echo;echo
    "exec ":cexpr system('spring rspec " . a:filename . "') | copen | redraw!"
    if a:async == 'async'
      exec ":Do spring rspec " . a:filename
    else
      exec ":!time spring rspec " . a:filename
    endif
endfunction

function! SetTestFile()
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

function! RunTestFile(async)
    " Run the tests for the previously-marked file.
    let in_spec_file = match(expand("%"), '_spec.rb$') != -1
    if in_spec_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        return
    endif

    call RunTests(t:grb_test_file, a:async)
endfunction

function! RunNearestTest(async)
    let spec_line_number = line('.')
    call RunTestFile(a:async)
endfunction

" Run this file
map <leader>m :call RunTestFile('noasync')<cr>
" Run only the example under the cursor
map <leader>. :call RunNearestTest('noasync')<cr>
" Run all test files
" map <leader>a :call RunTests('spec')<cr>

" Autocreate parent directory on file save
function! s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

function! ConfigurePluginAfterLoad()
  " Run this spec file asynchronously if vim-do plugin exists
  if exists(':DoAgain')
    map <leader>a :call RunTestFile('async')<cr>
  endif
endfunction

au VimEnter * call ConfigurePluginAfterLoad()

"""""" Language specific auto-expansion
" This function will only expand if it's at the beginning of the line
function! ConditionalExpansionMap(open, close)
  let line = getline('.')
  let col = col('.')
  if col > indent('.') + 1
    return a:open
  else
    return a:open . a:close
  endif
endf

""" Generic Bracket-based language
function! GenericAutoExpansion()
  " { }
  inoremap <buffer> { {}<Left>
  inoremap <buffer> {<CR> {<CR><SPACE><CR>}<Up><C-O>$<BS>
  inoremap <buffer> {{ {
  inoremap <buffer><expr> }  strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
  " ( )
  inoremap <buffer> ( ()<Left>
  inoremap <buffer> (( (
  inoremap <buffer><expr> )  strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
  " [ ]
  inoremap <buffer> [ []<Left>
  inoremap <buffer> [[ [
  inoremap <buffer><expr> ]  strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"
endfunction
au BufEnter,VimEnter,FileType *.rb,*.coffee,*.js,*.rst,*.c,*.cpp call GenericAutoExpansion()

function! JSAutoExpansion()
  imap <buffer> function<space> function() {<CR><Up><C-O>$<C-O>b<SPACE>
endfunction
au BufEnter,VimEnter,FileType *.js call JSAutoExpansion()

function! RubyAutoExpansion()
  inoremap <buffer><expr> def<SPACE> ConditionalExpansionMap('def ', '<CR>end<Up><C-O>$')
  inoremap <buffer> do<Space> do<Cr>end<Up><C-O>$<Space>
  inoremap <buffer> do<CR> do<CR><SPACE><CR>end<Up><C-O>$<BS>
  inoremap <buffer> dd d
  inoremap <buffer><expr> class<SPACE> ConditionalExpansionMap('class ', '<CR>end<Up><c-o>$')
  inoremap <buffer> cc c
  inoremap <buffer><expr> module<SPACE> ConditionalExpansionMap('module ', '<CR>end<Up><c-o>$')
  inoremap <buffer> mm m
endfunction
au BufEnter,VimEnter,FileType *.rb call RubyAutoExpansion()

function! RubySpecAutoExpansion()
  inoremap <buffer><expr> describe<SPACE> ConditionalExpansionMap('describe ', "'' do<CR>end<UP><C-O>f'<RIGHT>")
  inoremap <buffer> dd d
  inoremap <buffer><expr> it<SPACE> ConditionalExpansionMap('it ', "'' do<CR>end<UP><C-O>f'")
  inoremap <buffer> ii i
  inoremap <buffer><expr> context<SPACE> ConditionalExpansionMap('context ', "'' do<CR>end<UP><C-O>f'<RIGHT>")
  inoremap <buffer> cc c
endfunction
au BufEnter,VimEnter,FileType *_spec.rb call RubySpecAutoExpansion()

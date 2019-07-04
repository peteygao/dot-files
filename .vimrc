set t_Co=16

let mapleader=" "

set nocompatible
set backspace=indent,eol,start
set number
set showmode                    " always show what mode we're currently editing in
set expandtab                   " expand tabs by default (overloadable per file type later) (WARNING: this gets reset when :set paste is true!)
set autoindent
set tabstop=2                   " a tab is four spaces (DEFAULT, will get changed by vim-sleuth)
set softtabstop=2               " when hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=2                " number of spaces to use for autoindenting
set ignorecase
set smartcase
set clipboard=unnamedplus       " copy the default buffer to clipboard
set ttyfast
set scrolloff=2                 " Start scrolling when the cursor is 2 lines away from the top/bottom of the screen
set switchbuf+=usetab,newtab    " Open a file in existing tab if already open, otherwise new tab
syntax on
filetype plugin indent on
set hlsearch
set incsearch
set list listchars=tab:»\ ,trail:·,nbsp:· " Tabs and trailing whitespace are visible
highlight NonText guifg=#4a4a59
highlight SpecialKey guifg=#4a4a59
nnoremap <C-L> :nohl<CR>
" Ctrl+C when in Input mode sends ESC
inoremap <C-C> <ESC>

""" Possibly obsolete performance optimizations:
" set lazyredraw
" set re=1                        " Use version 1 of regexp engine (faster for Ruby syntax highlighting)

"***************************
" vim-plug PLUGIN management
"***************************
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
" Don't forget to SOURCE .vimrc when you add a new plugin!!!
Plug 'w0rp/ale'
Plug 'vim-airline/vim-airline'
Plug 'simnalamburt/vim-mundo'
Plug 'ctrlpvim/ctrlp.vim'
" To install & compile cpsm:
" apt-get install build-essentials python3-dev libboost-all-dev cmake libicu-dev
Plug 'nixprime/cpsm', { 'do': './install.sh' }
" To use `elm-vim`, the following NPM packages must be installed:
" `elm`, `elm-format`, `elm-oracle`, `elm-test`
Plug 'ElmCast/elm-vim'
Plug 'tomtom/tcomment_vim'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-dadbod'
Plug 'tomtom/tcomment_vim'
Plug 'junegunn/vim-easy-align'
" Don't forget to SOURCE .vimrc when you add a new plugin!!!
call plug#end()

function! NumberToggle()
  if(&relativenumber == 1 && &number == 1)
    set norelativenumber
    set nonumber
  elseif(&number == 1)
    set nonumber
  else
    set relativenumber
    set number
  endif
endfunc

nnoremap <C-N> :call NumberToggle()<cr>

augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
augroup END

" Highlight lines that are too long, and trailing spaces
hi LineOverflow  ctermfg=white ctermbg=red guifg=white guibg=#FF2270
hi TrailingSpaces  ctermfg=white ctermbg=red guifg=white guibg=#FF2270
augroup highlight
  autocmd!
  " Highlight lines longer than 80 chars
  autocmd BufEnter,VimEnter,FileType *.rb,*.coffee,*.js,*.jsx,*.ex,*.exs,*.elm
      \ if !exists('w:m1') | let w:m1=matchadd('LineOverflow','\%>80v.\+', -1) | endif
  " Highlight trailing spaces
  autocmd BufEnter,VimEnter,FileType *.rb,*.coffee,*.js,*.jsx,*.ex,*.exs,*.elm
      \ if !exists('w:m2') | let w:m2=matchadd('TrailingSpaces','\s\+$', -1) | endif
augroup END

"********************
" Custom keybindings
"********************
" gp remaps to "select recently changed text" (e.g. from paste)
nnoremap gp `[v`]
nnoremap <Leader>sc :tabe db/schema.rb<CR>
nnoremap <Leader>sv :source ~/.vimrc<CR>
nnoremap <Leader>ev :tabe ~/.vimrc<CR>
" nnoremap <C-S> :w<CR> " Doesn't work right now... Investigate this later
nnoremap <Leader>pi :PlugInstall<CR>
nnoremap <Leader>pu :PlugUpdate<CR>

" Remaps Git Gutter hunk movement from ]h, [h to gh, gH
nmap gh <Plug>GitGutterNextHunk
nmap gH <Plug>GitGutterPrevHunk

" Vim-Airline
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
    \ 't'  : 'T',
    \ }
let g:airline#extensions#ale#enabled = 1

" Vim-Do async shell configs
let g:check_interval = 500
let g:do_new_buffer_size = 10
let g:do_refresh_key = "<F37>"

" Mundo, an active fork of Gundo:
" https://github.com/simnalamburt/vim-mundo
nnoremap U :MundoToggle<CR>
set undofile
set undodir=~/.vim/undo

""" Clear CtrlP Cache after writing a new file
autocmd BufWritePre * if !filereadable(expand('%')) | let b:is_new = 1 | endif
autocmd BufWritePost * if get(b:, 'is_new', 0) | let b:is_new = 0 | CtrlPClearCache | endif

" CtrlP + cpsm matcher
" Use the maintained version of CtrlP:
" https://github.com/ctrlpvim/ctrlp.vim
if !empty(glob("~/.vim/plugged/cpsm/bin/cpsm_py.so"))
  let g:ctrlp_match_func = {'match': 'cpsm#CtrlPMatch'}
  noremap <leader>f :CtrlPRoot<CR>
  noremap <leader><S-F> :CtrlPClearCache<CR>:CtrlPRoot<CR>
else
  let g:ctrlp_lazy_update = 75
  set wildignore+=*/tmp/*,*/img/*,*/images/*,*/imgs/*,*.so,*.swp,*.zip,*/\.git/*,*/log/*,*/node_modules/*,\.bundle/*,deps/*
  let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
  noremap <leader>f :CtrlPRoot<CR>
  noremap <leader><S-F> :CtrlPClearCache<CR>:CtrlPRoot<CR>
endif
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

" Vim Easy Align
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

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
  command! -nargs=+ Grep execute 'silent Ag!' . shellescape(<q-args>, 1) | copen 15 | redraw! | execute 'silent /' . <q-args>
else
  command! -nargs=+ Grep execute 'silent grep! -Ir --exclude=\*.{json,pyc,tmp,log} --exclude=\*.min.js --exclude=tags --exclude-dir=coverage --exclude-dir=vendor --exclude-dir=node_modules --exclude-dir=*\dist\* --exclude-dir=*\tmp\* --exclude-dir=*\.git\* --exclude-dir=*\.idea\* --exclude-dir=*\*cache\* --exclude-dir=*\deps\* --exclude-dir=*\web/libs\* . -e ' . shellescape(<q-args>, 1) | copen 15 | redraw! | execute 'silent /' . <q-args>
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
      exec ":DoQuietly spring rspec " . a:filename
      exec ":Done"
    else
      exec ":!time spring rspec " . a:filename
    endif
endfunction

function! SetTestFile()
    " Set the spec file that tests will be run for.
    let t:grb_test_file=@%
endfunction

function! RunTestFile(...)
    if a:0 && a:1 != ''
      let command_suffix = a:1
    else
      let command_suffix = ""
    endif

    if a:0 > 1
      let async = a:2
    end

    " Run the tests for the previously-marked file.
    let in_spec_file = match(expand("%"), '_spec.rb$') != -1
    if in_spec_file
        call SetTestFile()
    elseif !exists("t:grb_test_file")
        return
    endif

    call RunTests(t:grb_test_file . command_suffix, async)
endfunction

function! RunNearestTest(async)
    let spec_line_number = line('.')
    call RunTestFile(":" . spec_line_number, a:async)
endfunction

" Run this file
map <leader>m :call RunTestFile('','noasync')<cr>
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
    map <leader>a :call RunTestFile('', 'async')<cr>
  endif
endfunction

au VimEnter * call ConfigurePluginAfterLoad()

"""""" Language specific auto-expansion
" Pass in a list of mappings of expansions
" Arg1: The search string
" Arg2: The expansion string
" Arg3: The line position the character can appear and still be matched
function! ConditionalExpansionMap(trigger_char, mapping_list)
  for mapping in a:mapping_list
    let result = ''
    if a:trigger_char == "\<SPACE>"
      let result = SpaceExpansion(mapping[0], mapping[1], mapping[2])
    elseif a:trigger_char == "\<CR>"
      let result = EnterExpansion(mapping[0], mapping[1], mapping[2])
    elseif a:trigger_char == "\<BS>"
      let result = BackspaceExpansion(mapping[0], mapping[1], mapping[2])
    else
      let result = CharExpansion(mapping[0], mapping[1], mapping[2])
    endif

    if result != ''
      return result
    endif
  endfor

  return a:trigger_char
endf

" This function will check for expansion match, and optionally expand if it's
" at the beginning of the line (line_pos == '^')
" at the end of the line (line_pos == '$')
" or anywhere (line_pos == '.')
function! SpaceExpansion(check, output, line_pos)
  let start    = indent('.') + 1
  let col      = col('.')
  let char_len = strchars(a:check)

  " The char_len + 1 is because we need to rewind an extra step to account for
  " the space that's inserted prior to triggering of this mapping
  if strpart(getline('.'), col - (char_len + 1), char_len) == a:check
    if a:line_pos == '^'
      if col - char_len == start
        return a:output
      endif
    elseif a:line_pos == '$'
      if col == col('$')
        return a:output
      endif
    elseif a:line_pos == '.'
      return a:output
    endif
  endif
endf

function! EnterExpansion(check, output, line_pos)
  let pos      = col('.')
  let char_len = strchars(a:check)

  if strpart(getline('.'), pos - (char_len + 1), char_len) == a:check
    return CharExpansion(a:check, a:output, a:line_pos)
  endif
endf

function! BackspaceExpansion(check, output, next_char_check)
  let pos          = col('.')-2
  let next_pos     = col('.')-1
  let current_char = getline('.')[pos]
  let next_char    = getline('.')[next_pos]

  if a:check == current_char && a:next_char_check == next_char
      return a:output
  endif
endf

function! CharExpansion(check, output, line_pos)
  let start    = indent('.') + 1
  let col      = col('.')

  if a:line_pos == '^'
    if col == start
      return a:output
    endif
  elseif a:line_pos == '$'
    if col == col('$')
      return a:output
    endif
  elseif a:line_pos == '.'
    return a:output
  endif
endf

""" Expansion augroup

augroup expansions
au!

""" Generic Bracket-based language
function! GenericAutoExpansion()
  " { }
  inoremap <buffer><expr> {
        \ ConditionalExpansionMap(
        \ "{",
        \ [
        \   ['{', '{}<LEFT>', '$'],
        \ ])
  inoremap <buffer><expr> } strpart(getline('.'), col('.')-1, 1) == "}" ? "\<Right>" : "}"
  " ( )
  inoremap <buffer><expr> (
        \ ConditionalExpansionMap(
        \ "(",
        \ [
        \   ['(', '()<LEFT>', '$'],
        \ ])
  inoremap <buffer><expr> ) strpart(getline('.'), col('.')-1, 1) == ")" ? "\<Right>" : ")"
  " [ ]
  inoremap <buffer><expr> [
        \ ConditionalExpansionMap(
        \ "[",
        \ [
        \   ['[', '[]<LEFT>', '$'],
        \ ])
  inoremap <buffer><expr> ] strpart(getline('.'), col('.')-1, 1) == "]" ? "\<Right>" : "]"

  " Backspace deletes matching pair
  inoremap <buffer><expr> <BS>
        \ ConditionalExpansionMap(
        \ "\<BS>",
        \ [
        \   ['{', '<BS><DEL>', '}'],
        \   ['(', '<BS><DEL>', ')'],
        \   ['[', '<BS><DEL>', ']'],
        \ ])
endfunction
au BufEnter,VimEnter,FileType *.rb,*.coffee,*.js,*.jsx,*.rst,*.c,*.cpp,*.ex,*.exs,*.elm call GenericAutoExpansion()

function! JSAutoExpansion()
  inoremap <buffer><expr> <SPACE>
        \ ConditionalExpansionMap(
        \ "\<SPACE>",
        \ [
        \   ['function', '  {<CR>}<Up><C-O>$<LEFT><LEFT>', '.'],
        \   ['constructor', '  {<CR>}<Up><C-O>$<LEFT><LEFT>()<LEFT>', '.'],
        \   ['.constructor', ' = function  {<CR>}<Up><C-O>$<LEFT><LEFT>', '$'],
        \   ['=>', ' {<CR>}<UP><C-O>$<LEFT><LEFT><LEFT><LEFT>() <LEFT><LEFT>', '$'],
        \ ])
  inoremap <buffer><expr> <CR>
        \ ConditionalExpansionMap(
        \ "\<CR>",
        \ [
        \   ['=>', ' {<CR>}<UP><C-O>$<LEFT><LEFT><LEFT><LEFT>() <C-O>$<CR>', '.'],
        \ ])
endfunction
au BufEnter,VimEnter,FileType *.js,*.jsx call JSAutoExpansion()

function! RubyAutoExpansion()
  inoremap <buffer><expr> <SPACE>
        \ ConditionalExpansionMap(
        \ "\<SPACE>",
        \ [
        \   ['class', '<CR>end<UP><C-O>$<SPACE>', '^'],
        \   ['module', '<CR>end<UP><C-O>$<SPACE>', '^'],
        \   ['def', '<CR>end<UP><C-O>$<SPACE>', '^'],
        \   ['do', '<CR>end<UP><C-O>$<SPACE>', '$'],
        \   ['class <<', '<SPACE>self<cr><CR>def<SPACE><CR>end<cr><UP><UP><C-O>$', '^'],
        \ ])
  inoremap <buffer><expr> <CR>
        \ ConditionalExpansionMap(
        \ "\<CR>",
        \ [
        \   ["do", "<CR><SPACE><CR>end<UP><BS>", '.'],
        \ ])
endfunction
au BufEnter,VimEnter,FileType *.rb call RubyAutoExpansion()

function! RubySpecAutoExpansion()
  inoremap <buffer><expr> <SPACE>
        \ ConditionalExpansionMap(
        \ "\<SPACE>",
        \ [
        \   ['class', '<CR>end<UP><C-O>$<SPACE>', '^'],
        \   ['module', '<CR>end<UP><C-O>$<SPACE>', '^'],
        \   ['def', '<CR>end<UP><C-O>$<SPACE>', '^'],
        \   ['do', '<CR>end<UP><C-O>$<SPACE>', '$'],
        \
        \   ['context', " '' do<CR>end<UP><C-O>f'<RIGHT>", '^'],
        \   ['describe', " '' do<CR>end<UP><C-O>f'<RIGHT>", '^'],
        \   ['it', " '' do<CR>end<UP><C-O>f'", '^'],
        \ ])
endfunction
au BufEnter,VimEnter,FileType *_spec.rb call RubySpecAutoExpansion()

function! ElixirAutoExpansion()
  inoremap <buffer><expr> <SPACE>
        \ ConditionalExpansionMap(
        \ "\<SPACE>",
        \ [
        \   ['defmodule', '<CR>end<UP><C-O>$<SPACE>', '^'],
        \   ['do', '<CR>end<UP><C-O>$<SPACE>', '$'],
        \ ])
  inoremap <buffer><expr> <CR>
        \ ConditionalExpansionMap(
        \ "\<CR>",
        \ [
        \   ["do", "<CR><SPACE><CR>end<UP><BS>", '.'],
        \ ])
endfunction
au BufEnter,VimEnter,FileType *.ex,*.exs call ElixirAutoExpansion()

augroup END

execute pathogen#infect()


let mapleader = ","

set nocompatible                " choose no compatibility with legacy vi
syntax enable
set encoding=utf-8
set showcmd                     " display incomplete commands
filetype plugin indent on       " load file type plugins + indentation

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=2 shiftwidth=2      " a tab is two spaces (or set this to 4)
set noexpandtab                 " use tabs, not spaces (optional)
set backspace=indent,eol,start  " backspace through everything in insert mode
set list                        " Show invisible characters

set nojoinspaces                  " Use only 1 space after "." when joining lines, not 2

" Indicator chars
set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮
set showbreak=↪\


"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

color desert
"let g:airline_theme=
set laststatus=2  " always show the status bar

" Change buffer dir to match open file
"autocmd BufEnter * silent! lcd %:p:h

" Filetypes customization
au BufNewFile,BufRead mozex.textarea.* setfiletype typoscript
au BufNewFile,BufRead *.ts setfiletype typoscript
au BufNewFile,BufRead setup.txt setfiletype typoscript
au BufNewFile,BufRead constants.txt setfiletype typoscript
au BufNewFile,BufRead *setup.txt setfiletype typoscript
au BufNewFile,BufRead *constants.txt setfiletype typoscript

au FileType {typoscript,php} set noexpandtab

" Disable phpcs and phpmd from Syntastic
let g:syntastic_php_checkers=['php']
let g:syntastic_php_phpcs_args = "--standard=TYPO3CMS"
let g:phpqa_codesniffer_args = "--standard=TYPO3CMS"
" Don't run phpqa on write... TYPO3 files are really big and slow to process
let g:phpqa_run_on_write = 0


" Custom key mappings
map <leader>n :sp<cr>:e %:p:h<cr>
cabbr <expr> %% expand('%:p:h')

" Tmux navigation
let g:tmux_navigator_no_mappings = 1

nnoremap <silent> <c-w>h :TmuxNavigateLeft<cr>
nnoremap <silent> <c-w>j :TmuxNavigateDown<cr>
nnoremap <silent> <c-w>k :TmuxNavigateUp<cr>
nnoremap <silent> <c-w>l :TmuxNavigateRight<cr>
nnoremap <silent> <c-w>\ :TmuxNavigatePrevious<cr>

" Tags file
" http://tbaggery.com/2011/08/08/effortless-ctags-with-git.html
set tags=.git/tags,tags,./tags

map <Leader>rt :!ctags --tag-relative --extra=+f -Rf.git/tags --exclude=.git,pkg --languages=-javascript,sql<CR><CR>

" Editorconfig must play well with Fugitive
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" scss_lint with syntastic
let g:syntastic_scss_checkers = ['scss_lint']

" eslint with syntastic
let g:syntastic_javascript_checkers = ['eslint']

" Return indent (all whitespace at start of a line), converted from
" tabs to spaces if what = 1, or from spaces to tabs otherwise.
" When converting to tabs, result has no redundant spaces.
function! Indenting(indent, what, cols)
  let spccol = repeat(' ', a:cols)
  let result = substitute(a:indent, spccol, '\t', 'g')
  let result = substitute(result, ' \+\ze\t', '', 'g')
  if a:what == 1
    let result = substitute(result, '\t', spccol, 'g')
  endif
  return result
endfunction

" Convert whitespace used for indenting (before first non-whitespace).
" what = 0 (convert spaces to tabs), or 1 (convert tabs to spaces).
" cols = string with number of columns per tab, or empty to use 'tabstop'.
" The cursor position is restored, but the cursor will be in a different
" column when the number of characters in the indent of the line is changed.
function! IndentConvert(line1, line2, what, cols)
  let savepos = getpos('.')
  let cols = empty(a:cols) ? &tabstop : a:cols
  execute a:line1 . ',' . a:line2 . 's/^\s\+/\=Indenting(submatch(0), a:what, cols)/e'
  call histdel('search', -1)
  call setpos('.', savepos)
endfunction
command! -nargs=? -range=% Space2Tab call IndentConvert(<line1>,<line2>,0,<q-args>)
command! -nargs=? -range=% Tab2Space call IndentConvert(<line1>,<line2>,1,<q-args>)
command! -nargs=? -range=% RetabIndent call IndentConvert(<line1>,<line2>,&et,<q-args>)

" Convert src relative paths to VH f:uri.resource
function! ImgSrc2UriResource()
	execute '%s/src="\.\.\/\([^"]*\)"/src="{f:uri.resource(path: ''Assets\/\1'', extensionName: ''speciality'')}"/g'
endfunction
command! -nargs=? -range=% ImgSrc2UriResource call ImgSrc2UriResource()

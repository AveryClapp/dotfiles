set nocompatible

" ---------------------------------------------
" Init - plugins
" ---------------------------------------------
call plug#begin()
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
Plug 'morhetz/gruvbox'
Plug 'rust-lang/rust.vim'
Plug 'dense-analysis/ale'
call plug#end()

set number
nnoremap J 10j
nnoremap K 10k
nnoremap L $
nnoremap H 0
" ---------------------------------------------
" Vim Options
" ---------------------------------------------
set autoindent			" Default to indenting files
set backspace=indent,eol,start	" Backspace all characters
set formatoptions-=t		" Don't add line-breaks for lines over 'textwidth' characters
set showmatch               " Highlight matching brackets
set incsearch               " Search as characters are entered
set hlsearch                " Highlight search matches
set ignorecase              " Ignore case when searching
set smartcase               " But make it case sensitive if an uppercase is entered
set nostartofline		" Do not jump to first character with page commands
set showmatch			" Show matching brackets.
set showmode			" Show the current mode in status line
set showcmd			" Show partial command in status line
set tabstop=4			" Number of spaces <tab> counts for
set textwidth=80		" 80 columns
set title			" Set the title

" ---------------------------------------------
" Theme / Color Scheme
" ---------------------------------------------
colorscheme desert
" Or using a specific color code
highlight Comment ctermfg=245 guifg=#8a8a8a
highlight Normal ctermbg=236 guibg=#303030
" ---------------------------------------------
" Abbreviations
" ---------------------------------------------
iab <expr> me:: strftime("Author: Avery Clapp <avery.clapp@gmail.com><cr>Date: %B %d, %Y<cr>License: MIT")

" ---------------------------------------------
" Aliases
" ---------------------------------------------
cmap w!! w !sudo tee > /dev/null %

" ---------------------------------------------
" File/Indenting and Syntax Highlighting
" ---------------------------------------------
if has("autocmd")
	filetype plugin indent on

	" Jump to previous cursor location, unless it's a commit message
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
	autocmd BufReadPost COMMIT_EDITMSG exe "normal! gg"

	" Chef/Ruby
	autocmd BufNewFile,BufRead                  *.rb setlocal filetype=ruby
	autocmd FileType                            ruby setlocal sw=2 sts=2 et

	" Yaml
	autocmd BufNewFile,BufRead                  *.yaml,*.yml setlocal filetype=yaml
	autocmd FileType                            yaml         setlocal sw=2 sts=2 et

	" JavaScript files
	autocmd BufNewFile,BufReadPre,FileReadPre   *.js        setlocal filetype=javascript
	autocmd FileType                            javascript  setlocal sw=4 sts=4 et

	" JSON files
	autocmd BufNewFile,BufReadPre,FileReadPre   *.json setlocal filetype=json
	autocmd FileType                            json   setlocal sw=2 sts=2 et

	" Objective C / C++
	autocmd BufNewFile,BufReadPre,FileReadPre   *.m    setlocal filetype=objc
	autocmd FileType                            objc   setlocal sw=4 sts=4 et
	autocmd BufNewFile,BufReadPre,FileReadPre   *.mm   setlocal filetype=objcpp
	autocmd FileType                            objcpp setlocal sw=4 sts=4 et

	" Rust files
	" autocmd BufNewFile,BufReadPre,FileReadPre   *.rs   setlocal filetype=rust
	autocmd FileType                            rust   setlocal sw=4 sts=4 et textwidth=80

	" Python files
	autocmd BufNewFile,BufReadPre,FileReadPre   *.py   setlocal filetype=python
	autocmd FileType                            python setlocal sw=4 sts=4 et
	autocmd FileType python set expandtab tabstop=4 shiftwidth=4

	" Markdown files
	autocmd BufNewFile,BufRead,FileReadPre      *.md,*.markdown setlocal filetype=markdown
	autocmd FileType                            markdown      setlocal sw=4 sts=4 et spell
	" Jekyll posts ignore yaml headers
	autocmd BufNewFile,BufRead                  */_posts/*.md syntax match Comment /\%^---\_.\{-}---$/
	autocmd BufNewFile,BufRead                  */_posts/*.md syntax region lqdHighlight start=/^{%\s*highlight\(\s\+\w\+\)\{0,1}\s*%}$/ end=/{%\s*endhighlight\s*%}/

	" EJS javascript templates
	autocmd BufNewFile,BufRead,FileReadPre      *.ejs setlocal filetype=html

	" TXT files
	autocmd FileType                            text setlocal spell
endif

" ---------------------------------------------
" Spell Check Settings
" ---------------------------------------------
set spelllang=en
highlight clear SpellBad
highlight SpellBad term=standout cterm=underline ctermfg=red
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline

" ---------------------------------------------
" Plugins
" ---------------------------------------------
" Enable Airline theme
let g:airline_theme='gruvbox'

" Enable true color support (if your terminal supports it)
if has('termguicolors')
    set termguicolors
endif
let g:rust_recommended_style = 1
let g:ale_linters = {
"\  'bash': [],
"\  'sh': [],
"\  'c': [],
\  'rust': ['analyzer'],
\}
let g:ale_completion_enabled = 0
let g:vim_markdown_folding_disabled = 1
highlight EndOfBuffer ctermbg=NONE guibg=NONE
" ---------------------------------------------
" Source local config
" ---------------------------------------------
if filereadable(expand("~/.vimrc.local"))
	source ~/.vimrc.local
endif
if filereadable(expand("~/.vimrc.indent"))
	source ~/.vimrc.indent
endif

set hidden
set wildmenu
" " Control how Vim cycles through matches
set wildmode=longest:full,full

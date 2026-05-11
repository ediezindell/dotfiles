vim9script

# --- General Options ---
filetype plugin indent on
syntax enable

set encoding=utf-8
set fileencoding=utf-8
set list
set scrolloff=4
set ignorecase
set smartcase
set completeopt=menuone,noinsert
set cursorline
set cursorcolumn
set softtabstop=-1
set shiftwidth=0
set tabstop=2
set number
set expandtab
set numberwidth=4
set incsearch
set shell=zsh
set splitright
set splitbelow
if has('termguicolors')
    set termguicolors
endif
set clipboard=unnamedplus
set signcolumn=yes:2
set title
set hlsearch
set showcmd
set helplang=ja,en
set hidden
# cmdheight=0 is supported in Vim 9.0.0114 and later
if has('patch-9.0.0114')
    set cmdheight=0
else
    set cmdheight=1
endif
set whichwrap+=<,>,[,],h,l

# --- Keymaps ---
g:mapleader = " "
g:maplocalleader = "_"

# Normal mode maps
nnoremap Y y$
nnoremap / /\v
nnoremap <S-m> `
nnoremap <BS> <C-o>
nnoremap <Left> <C-o>
nnoremap <Right> <C-i>
nnoremap <Esc><Esc> <Cmd>nohlsearch<CR>
nnoremap <leader>ss <Cmd>split<CR>
nnoremap <leader>sv <Cmd>vsplit<CR>
nnoremap <leader><C-v> <Cmd>%d <bar> normal! "+P<CR>
nnoremap <leader>bd <Cmd>%bd <bar> e# <bar> bd#<CR>
nnoremap q: :

# Visual mode maps
vnoremap y mzy`z
vnoremap p P
vnoremap < <gv
vnoremap > >gv

# Motion maps
for quote in ['"', "'", '`']
    execute $"xnoremap a{quote} 2i{quote}"
    execute $"onoremap a{quote} 2i{quote}"
endfor
xnoremap i<space> iW
onoremap i<space> iW
xnoremap a<space> 2iW
onoremap a<space> 2iW

# --- Custom Functions ---

# Search by clipboard
def SearchByClipboard()
    var search_term = getreg('+')->escape('/\*^$.~[]()<>+={}-')
    feedkeys('/' .. search_term, 'n')
enddef
nnoremap g/ <scriptCmd>SearchByClipboard()<CR>

# Compare with clipboard
def CompareWithClipboard()
    var ftype = &filetype
    vsplit
    wincmd l
    enew
    setlocal buftype=nofile
    execute 'set filetype=' .. ftype
    normal! "+P
    diffthis
    wincmd h
    diffthis
enddef
nnoremap <leader>bc <scriptCmd>CompareWithClipboard()<CR>

# --- Autocmds ---
augroup MyAutoCmds
    autocmd!

    # Save scroll position
    autocmd BufReadPost * {
        if line("'\"") > 0 && line("'\"") <= line("$")
            execute "normal! g'\""
        endif
    }

    # Auto mkdir
    autocmd BufWritePre * {
        var dir = expand('<afile>:p:h')
        if !isdirectory(dir)
            mkdir(dir, 'p')
        endif
    }

    # Quickfix open
    autocmd QuickfixCmdPost * {
        if len(getqflist()) > 0
            copen
        endif
    }

    # o/O no comment continuation
    autocmd FileType * setlocal formatoptions-=o
augroup END

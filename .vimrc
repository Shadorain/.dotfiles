autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
set ttymouse=sgr
syntax on
set encoding=utf-8
set expandtab
set shiftwidth=4
set softtabstop=4
set tabstop=4
"set termguicolors

set nocompatible
filetype plugin on

let mapleader = "'"

" Lightline
set laststatus=2

if !has('gui_running')
  set t_Co=256
endif
set noshowmode

"let g:lightline = {
"      \ 'colorscheme': 'wombat',
"      \ }

" Number
set number                     " Show current line number
set relativenumber             " Show relative line numbers

" Vifm
map <Leader>vf :Vifm<CR>
map <Leader>vs :VsplitVifm<CR>
map <Leader>vh :SplitVifm<CR>
map <Leader>dv :DiffVifm<CR>
map <Leader>tv :TabVifm<CR>

" VimWiki
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

" Quick Scope
let g:qs_highlight_on_keys = ['f', 'F', 't' , 'T']
highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

" Plugs
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/autoload/')

    Plug 'terryma/vim-multiple-cursors'
    Plug 'https://github.com/chrisbra/Colorizer.git'
    Plug 'itchyny/lightline.vim'
    Plug 'vifm/vifm.vim'
    Plug 'vimwiki/vimwiki'
    Plug 'ap/vim-css-color'
    Plug 'plasticboy/vim-markdown'
    Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install' }
    Plug 'unblevable/quick-scope'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'tpope/vim-surround'
    Plug 'sainnhe/lightline_foobar.vim'
    Plug 'kaicataldo/material.vim'

call plug#end()

colorscheme koehler
"colorscheme material
"let g:material_theme_style = 'ocean'
highlight LineNr ctermfg=magenta

let g:lightline = { 'colorscheme': 'palenight_alter' }

"I still need alot more in here, new rice, new vim

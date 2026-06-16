" Settings
syntax on
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set relativenumber
set nu
set smartcase
set cursorline
highlight Cursor guifg=white guibg=black
set background=dark
set clipboard+=unnamedplus
set colorcolumn=80

" Plugins
call plug#begin('~/.config/nvim/plug')
Plug 'NLKNguyen/papercolor-theme'
Plug 'arcticicestudio/nord-vim'
Plug 'dart-lang/dart-vim-plugin'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-rooter'
Plug 'rafi/awesome-vim-colorschemes'
call plug#end()

colorscheme nord 

" Keybindings
let mapleader = " "

nnoremap <leader>ot :sp <CR> :term<CR>

"nnoremap <leader>V :vsp<CR>
"nnoremap <leader>H :sp<CR>

nnoremap <leader>wn :vsp new<CR>
"nnoremap <leader>ok :sp new<CR>

nnoremap <C-h> :vertical resize +5<CR>
nnoremap <C-j> :resize +5<CR>
nnoremap <C-k> :resize -5<CR>
nnoremap <C-l> :vertical resize -5<CR>

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
nnoremap <leader>wh <C-w>h
nnoremap <leader>wj <C-w>j
nnoremap <leader>wk <C-w>k
nnoremap <leader>wl <C-w>l

nnoremap <leader>op :NERDTreeToggle<CR>


set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
set guifont=Source\ Code\ Pro:h20
let g:neovide_iso_layout=1 "non qwerty keyboards
nnoremap <F1> :set guifont=Source\ Code\ Pro:h25

" fzf - doing doom emacs' keybindings
nnoremap <leader>sp :Rg <CR>
nnoremap <leader>bi :Buffers <CR>
nnoremap <leader>ht :Colors <CR>
nnoremap <leader>: :Commands <CR>
nnoremap <leader><leader> :Files <CR>
nnoremap <leader>is :Snippets <CR>
nnoremap <leader>hm :Maps <CR>
nnoremap <leader>sm :BLines<CR>

" git
nnoremap <leader>gg :Git <CR>

" rooter
let g:rooter_patterns = ['.git', 'Makefile']

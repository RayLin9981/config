
runtime! debian.vim

if has("syntax")
  syntax on
endif

set background=dark


if filereadable("/etc/vim/vimrc.local")
  source /etc/vim/vimrc.local
endif

colorscheme moneyforward

" ray

" YAML 編輯推薦設定
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2
set autoindent
set smartindent
set number
set cursorline
set colorcolumn=80
set list
set listchars=tab:▸\ ,trail:·

" 確保語法與檔案型別辨識
syntax on
filetype plugin indent on


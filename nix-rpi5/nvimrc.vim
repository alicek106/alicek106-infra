" 리더 키는 , 로 고정
let mapleader = ","

set hlsearch " 모든 검색결과 하이라이트
set ignorecase " 대소문자 무시하고 검색
set incsearch " 타이핑할 때마다 검색 결과 표시
set noswapfile " 스왑파일 사용안함

" Copy from yank
set clipboard=unnamed " use OS clipboard

" Auto formatting for terraform
let g:terraform_fmt_on_save=1

" History
if has("persistent_undo")
  " mkdir -p ~/.vim/undodir
  let vimdir = '$HOME/.vim'
  let vimundodir = expand(vimdir . '/undodir')
  call system('mkdir ' . vimdir)
  call system('mkdir ' . vimundodir)

  let &undodir = vimundodir
  set undofile
endif

" Abbreviation for korean
cabbrev ㅈ w
cabbrev ㅂ q
cabbrev ㅈㅂ wq

syntax on
filetype indent plugin on

set tabstop=4
set expandtab
set softtabstop=4
set autoindent
set bg=dark
set nu

set smartindent
set shiftwidth=4

" Tab navigations
nnoremap <esc>t :tabnew<CR>
nnoremap <esc>T :-tabnew<CR>
nnoremap <esc>1 1gt
nnoremap <esc>2 2gt
nnoremap <esc>3 3gt
nnoremap <esc>4 4gt
nnoremap <esc>5 5gt
nnoremap <esc>6 6gt
nnoremap <esc>7 7gt
nnoremap <esc>8 8gt
nnoremap <esc>9 9gt
nnoremap <esc>b :Files<CR>
nnoremap <esc>f :Rg<CR>
nnoremap <esc>h :History<CR>

set mouse=

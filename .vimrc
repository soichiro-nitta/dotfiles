set title "編集中のファイル名を表示
set t_Co=256 "使用するカラー
set expandtab "入力モードでTabキー押下時に、半角スペースを挿入する
set tabstop=2 "タブ幅をスペース2つ分に
set shiftwidth=2 "vimが読み込み時に自動で生成するタブ幅
set nowrap "行の折り返し表示をやめる

set laststatus=2 "ステータスラインを常に表示
set statusline=%F "ファイル名表示
set statusline+=\  "空白スペース
set statusline+=[%l/%L] "現在行数/全行数
set statusline+=\  "空白スペース
set statusline+=%m "変更チェック表示

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

let mapleader = "\<Space>" "LeaderをSpaceキーにする
nmap <Leader>w :w<CR> "<Space>wを押してファイルを保存する
"imap <C-j> <ESC> "<Space>jでエスケープ

"<Space>pと<Space>yでクリップボードにコピー＆ペースト
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

"貼り付けた複数行のテキストの末尾へ自動的に移動する
vmap <silent> y y`]
vmap <silent> p p`]
nmap <silent> p p`]

"範囲拡大を使う
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)

colorscheme zellner

autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx
autocmd ColorScheme * hi statusline cterm=NONE ctermfg=white ctermbg=NONE "ステータスラインの色を上書き
autocmd ColorScheme * hi MatchParen cterm=bold ctermfg=200 ctermbg=NONE "対応する括弧の色を上書き

" 貼り付け時にペーストバッファが上書きされないようにする
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction
function! s:Repl()
  let s:restore_reg = @"
  return "p@=RestoreRegister()\<cr>"
endfunction
vmap <silent> <expr> p <sid>Repl()

call plug#begin('~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'leafgarland/typescript-vim'
Plug 'cohama/lexima.vim'
Plug 'terryma/vim-expand-region'
call plug#end()


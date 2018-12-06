""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author: whoru.S.Q <whoru@sqiang.net>
" Link: https://github.com/whorusq/linux-learning/blob/master/vim/.vimrc
" Version: 0.2
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""基本设置""""""""""


" 去掉vi一致性模式，避免以前版本的一些bug和局限
set nocompatible

" 显示行号
set nu
highlight LineNr cterm=bold ctermfg=darkgray

" 语法高亮
syntax on

" 显示光标所在行号、列号
"set ruler

" 粘贴带格式
set paste

" 高亮当前行
set cursorline
"hi CursorLine cterm=NONE ctermbg=darkred ctermfg=white
"hi CursorLine cterm=NONE ctermbg=230 ctermfg=NONE

" 高亮当前列
"set cursorcolumn
"hi CursorColumn cterm=NONE ctermbg=darkred ctermfg=white
"hi CursorColumn cterm=NONE ctermbg=237 ctermfg=NONE

" history 文件中需要记录的行数
set history=100

" 去掉输入错误的提示声音
"set noeb

" 在处理未保存或只读文件的时候，弹出确认
set confirm

" 带有如下符号的单词不要被换行分割
set iskeyword+=_,$,@,%,#,-

" 显示 Tab 键、行尾符
set list lcs=tab:>-,trail:-

" 不要换行
"set nowrap

" 禁止生成临时文件
set nobackup
set noswapfile

" 设置当文件被改动时自动载入
set autoread



""""""""""搜索和匹配设置""""""""""


" 搜索高亮
set hlsearch
hi Search cterm=NONE ctermfg=darkred ctermbg=yellow cterm=reverse

" 搜索时忽略大小写
set ignorecase

" 在查找时输入字符过程中就高亮显示匹配点，然后回车跳到该匹配点。
set incsearch

" 设置查找到文件尾部后折返开头或查找到开头后折返尾部。
set wrapscan

" 不要高亮被搜索的句子（phrases）
"set nohlsearch

" 匹配括号高亮的时间（单位是十分之一秒）
set matchtime=5



""""""""""文本操作设置""""""""""


" 统一缩进为 4 制表符
set tabstop=4
set softtabstop=4
set shiftwidth=4

" 智能对齐
set smartindent

" 用空格代替制表符
set expandtab

" 继承前一行的缩进方式，特别适用于多行注释
set autoindent

" 使用 C 样式的缩进
"set cindent

" 文件编码
set fileencodings=utf-8,gb2312,usc-bom,cp936,euc-cn
set termencoding=utf-8
set encoding=utf-8




""""""""""底部状态条设置""""""""""


set laststatus=2                                          " 长久显示1
set statusline=
set statusline+=%7*\[%n]                                  " buffernr
set statusline+=%1*\ %<%F\                                " 文件路径
set statusline+=%2*\ %y\                                  " 文件类型
set statusline+=%3*\ %{''.(&fenc!=''?&fenc:&enc).''}      " 编码1
set statusline+=%3*\ %{(&bomb?\",BOM\":\"\")}\            " 编码2
set statusline+=%4*\ %{&ff}\                              " 文件系统(dos/unix..)
set statusline+=%5*\ %{&spelllang}\%{HighlightSearch()}\  " 语言 & 是否高亮，H表示高亮?
set statusline+=%8*\ %=\ row:%l/%L\ (%03p%%)\             " 光标所在行号/总行数 (百分比)
set statusline+=%9*\ col:%03c\                            " 光标所在列
set statusline+=%0*\ \ %m%r%w\ %P\ \                      " Modified? Read only? Top/bottom
function! HighlightSearch()
    if &hls
        return 'H'
    else
        return ''
    endif
endfunction
hi User1 ctermfg=white  ctermbg=darkred
hi User2 ctermfg=blue  ctermbg=58
hi User3 ctermfg=white  ctermbg=100
hi User4 ctermfg=darkred  ctermbg=95
hi User5 ctermfg=darkred  ctermbg=77
hi User7 ctermfg=darkred  ctermbg=138  cterm=bold
hi User8 ctermfg=231  ctermbg=darkgray
"hi User9 ctermfg=#ffffff  ctermbg=#810085
hi User0 ctermfg=yellow  ctermbg=138



""""""""""其它""""""""""


" 用空格键来开关折叠
"set foldenable
"set foldmethod=manual
"nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc':'zo')<CR>


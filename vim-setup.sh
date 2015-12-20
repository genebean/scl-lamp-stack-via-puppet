#!/bin/bash

mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim

echo 'execute pathogen#infect()' > ~/.vimrc
echo 'syntax on' >> ~/.vimrc
echo 'filetype plugin indent on' >> ~/.vimrc

cd ~/.vim/bundle
rm -rf ./*
git clone git://github.com/rodjek/vim-puppet.git
git clone git://github.com/godlygeek/tabular.git
git clone https://github.com/scrooloose/syntastic.git
git clone https://github.com/SirVer/ultisnips
git clone https://github.com/Valloric/YouCompleteMe
git clone https://github.com/honza/vim-snippets


echo >> ~/.vimrc
echo 'set statusline+=%#warningmsg#' >> ~/.vimrc
echo 'set statusline+=%{SyntasticStatuslineFlag()}' >> ~/.vimrc
echo 'set statusline+=%*' >> ~/.vimrc
echo >> ~/.vimrc
echo 'let g:syntastic_always_populate_loc_list = 1' >> ~/.vimrc
echo 'let g:syntastic_auto_loc_list = 1' >> ~/.vimrc
echo 'let g:syntastic_check_on_open = 1' >> ~/.vimrc
echo 'let g:syntastic_check_on_wq = 0' >> ~/.vimrc

cd ~/.vim/bundle/YouCompleteMe
git submodule update --init --recursive
./install.py
cd ~
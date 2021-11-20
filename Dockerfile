FROM ubuntu

RUN apt update && apt install -y \
    git \
    vim \
    neovim

WORKDIR root

RUN git clone https://github.com/junegunn/vader.vim
COPY . main

RUN mkdir -p /root/.vim/pack/all/start
RUN mkdir -p /root/.local/share/nvim/site/pack/all/start

RUN ln -s /root/* /root/.vim/pack/all/start
RUN ln -s /root/* /root/.local/share/nvim/site/pack/all/start

RUN echo "set encoding=utf-8" > /root/.vim/vimrc

WORKDIR main
ENTRYPOINT ["./run-tests.sh"]

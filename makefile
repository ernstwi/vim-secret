VIM = vim -N -u NORC -i NONE --cmd 'set rtp=test/vim-vader packpath='

all: v nv

v: test/vim-vader
	$(VIM) -c 'Vader! test/*.vader'

v-i: test/vim-vader
	$(VIM) -c 'Vader test/*.vader'

nv: test/vim-vader
	n$(VIM) --headless -c 'Vader! test/*.vader'

nv-i: test/vim-vader
	n$(VIM) -c 'Vader test/*.vader'

test/vim-vader:
	git clone https://github.com/junegunn/vader.vim test/vim-vader || ( cd test/vim-vader && git pull --rebase )

.PHONY: all v v-i nv nv-i

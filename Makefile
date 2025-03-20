docker-mount:
	make docker-build
	docker run -it --rm --hostname tmux-test --name tmux-test \
	  --volume ./:/root/.config/tmux \
	  --volume ~/.config/nvim/:/root/.config/nvim \
	  --volume ~/.local/share/nvim:/root/.local/share/nvim \
	  --volume ~/.cache/nvim:/root/.cache/nvim \
	  tmux:tmp tmux

docker-run:
	make docker-build
	docker run -it --rm --hostname tmux-test --name tmux-test tmux:tmp tmux

docker-build:
	docker build -t tmux:tmp .

docker-build-no-cache:
	docker build --no-cache -t tmux:tmp .

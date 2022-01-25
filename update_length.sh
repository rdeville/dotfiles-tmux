#!/usr/bin/env bash

status_size="$(( $(tput cols) ))"
echo "__test___$(tput cols)" > ${HOME}/tmux.log
tmux set -g status-left-length $status_size
tmux set -g status-right-length $status_size

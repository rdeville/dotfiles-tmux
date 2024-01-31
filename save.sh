#!/usr/bin/env bash

if tmux info &> /dev/null
then
  "${XDG_CONFIG_HOME:-${HOME}/.config}/tmux/plugins/tmux-resurrect/scripts/save.sh"
else
  echo "No Tmux Server" &>>/tmp/tmux_save.log
  exit 1
fi

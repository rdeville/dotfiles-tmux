#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2034

SCRIPTPATH="$( cd -- "$(dirname "$0")" || exit 1 >/dev/null 2>&1 ; pwd -P )"

# Source my colors definition
source "${SCRIPTPATH}/colors.sh"

# TMUX Config overrides
# -----------------------------------------------------------------------------
# Set the default value of the TERM environment variable.
tmux set -g default-terminal "$TERM"
# if 'infocmp -x tmux-256color &> /dev/null' \
# 'set -g default-terminal "tmux-256color"'
tmux set -ag terminal-overrides ",$TERM:RGB"
tmux set -ag terminal-features ",$TERM:usstyle"
tmux set -as terminal-features ",$TERM:RGB"

source ${SCRIPTPATH}/defaults/modules.sh
source ${SCRIPTPATH}/defaults/responsive.sh
source ${SCRIPTPATH}/defaults/custom.sh
source ${SCRIPTPATH}/defaults/tmux.sh

# Generate status-{right,left} content
# -----------------------------------------------------------------------------
status[left]="${status[left_prefix]}"
for i_module in ${status[left_module]}
do
  declare -n tmp_array=${i_module}
  if [[ -n "${tmp_array[order]}" ]]
  then
    status[left]+="#{${i_module}}"
  fi
done
status[left]+="${status[left_suffix]}"

status[right]="${status[right_prefix]}"
for i_module in ${status[right_module]}
do
  declare -n tmp_array=${i_module}
  if [[ -n "${tmp_array[order]}" ]]
  then
    status[right]+=" #{${i_module}}"
  fi
done
status[right]+="${status[right_suffix]}"

# Set module configuration as tmux global variables
# -----------------------------------------------------------------------------
for i_module in "${modules[@]}"
do
  declare -n tmp_array="${i_module}"
  for i_var in "${!tmp_array[@]}"
  do
    tmux set -g "@${i_module}_${i_var}"  "${tmp_array[$i_var]}"
  done
  unset tmp_array
done

# Main status line information
# -----------------------------------------------------------------------------
# Update the status line every interval seconds.
tmux set -g status-interval 2

# Set status line style
tmux set -g status-style "fg=${status[fg]},bg=${status[bg]}"

# Set window mode style.
tmux set -g mode-style "fg=${mode[fg]},bg=${mode[bg]}"

# command line style
tmux set -g message-style "fg=${message[fg]},bg=${message[bg]}"

# Set status line message command style. This is used for the command prompt
# with vi(1) keys when in command mode.
tmux set -g message-command-style "fg=${message_command[fg]},bg=${message_command[bg]}"

# Left status
# -----------------------------------------------------------------------------
# Length of the left status bar
tmux set -g status-left-length 200
# Content of the left status bar
tmux set -g status-left "${status[left]}"

# Right status
# -----------------------------------------------------------------------------
# Lengtht of the right status bar
tmux set -g status-right-length 200
# Content of the right status bar
tmux set -g status-right "${status[right]}"

tmux run "${HOME}/.config/tmux/plugins/tmux-sysstat/sysstat.tmux"

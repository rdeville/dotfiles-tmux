#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Set status background color for darth-vader
status[bg]="${red_700}"

# Set darth-vader module order
hostname[order]="icon value"
hostname[fg]="${status[bg]}"
battery[order]=""

# Update modules and tmux variable using status[bg]
status[left_suffix]="#[bg=${status[bg]}]${separator[left]}"
status[right_prefix]="#[fg=${status[bg]}]"
window[bg]="${status[bg]}"

disk[bg]="${grey_900}"
net[bg]="${grey_800}"
mem[bg]="${grey_900}"
cpu[bg]="${grey_800}"
date[bg]="${grey_900}"

if [[ 125 -lt ${tmux_window_width} && ${tmux_window_width} -le 150 ]]
then
  net[bg]="${grey_900}"
  mem[bg]="${grey_800}"
  cpu[bg]="${grey_900}"
  date[bg]="${grey_800}"
elif [[ 100 -lt ${tmux_window_width} && ${tmux_window_width} -le 125 ]]
then
  net[bg]="${grey_900}"
  mem[bg]="${grey_800}"
  cpu[bg]="${grey_900}"
  date[bg]="${grey_800}"
fi


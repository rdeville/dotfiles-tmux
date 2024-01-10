#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# Set my default module order
# -----------------------------------------------------------------------------
mode_indicator[order]="icon"
session[order]="session"
hostname[order]=""
ip[order]=""
uptime[order]=""
battery[order]="icon status pourcent"
disk[order]=""
# disk[devices]="/dev/sdx"
disk[sub_order]=""
net[order]=""
mem[order]=""
cpu[order]=""
date[order]="icon format"
date[format]="%a %d %b | %H:%M"

# Set status background color for rey
status[bg]="${lime_500}"

window[bg]="${status[bg]}"
window[fg]="${grey_500}"
window[current_bg]="${light_green_A100}"
window[current_fg]="${grey_900}"

# Update modules and tmux variable using status[bg]
status[left_suffix]="#[bg=${status[bg]}]${separator[left]}"
status[right_prefix]="#[fg=${status[bg]}]"

# Main status line information
# -----------------------------------------------------------------------------
# Update the status line every interval seconds.
tmux set -g status-interval 5




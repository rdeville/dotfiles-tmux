#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2034

tmux_window_width=$(tmux display -p  "#{window_width}")

# Define responsive behaviour
# -----------------------------------------------------------------------------
if [[ 175 -lt ${tmux_window_width} && ${tmux_window_width} -le 200 ]]
then
  mode_indicator[order]="icon"
  session[order]="session"
  hostname[order]="value"
  ip[order]="icon_vpn vpn icon value"
  uptime[order]="icon value"
  battery[order]="icon status bar pourcent remaining"
  disk[order]="icon sub_order"
  disk_sub[order]="bar"
  net[order]="up_value up_icon status down_icon down_value"
  mem[order]="icon bar"
  cpu[order]="icon bar"
  date[format]="%D | %H:%M"
  date[order]="icon format"
elif [[ 150 -lt ${tmux_window_width} && ${tmux_window_width} -le 175 ]]
then
  mode_indicator[order]="icon"
  session[order]="session"
  hostname[order]=""
  ip[order]="icon_vpn vpn icon value"
  uptime[order]="icon value"
  battery[order]="icon status bar pourcent remaining"
  disk[order]="icon sub_order"
  disk_sub[order]="bar"
  net[order]="up_bar up_icon status down_icon down_bar"
  mem[order]="icon bar"
  cpu[order]="icon bar"
  date[format]="%D | %H:%M"
  date[order]="icon format"
elif [[ 125 -lt ${tmux_window_width} && ${tmux_window_width} -le 150 ]]
then
  mode_indicator[order]="icon"
  session[order]="session"
  hostname[order]=""
  ip[order]="icon_vpn vpn icon value"
  uptime[order]="icon value"
  battery[order]="icon bar"
  disk[order]=""
  net[bg]="${grey_800}"
  net[order]="up_bar up_icon status down_icon down_bar"
  mem[bg]="${grey_900}"
  mem[order]="icon bar"
  cpu[bg]="${grey_800}"
  cpu[order]="icon bar"
  date[bg]="${grey_900}"
  date[format]="%H:%M"
elif [[ 100 -lt ${tmux_window_width} && ${tmux_window_width} -le 125 ]]
then
  mode_indicator[order]="icon"
  session[order]="session"
  hostname[order]=""
  ip[order]=""
  uptime[order]=""
  battery[order]="icon bar"
  disk[order]=""
  net[bg]="${grey_800}"
  net[order]="up_bar status down_bar"
  mem[bg]="${grey_900}"
  mem[order]="icon bar"
  cpu[bg]="${grey_800}"
  cpu[order]="icon bar"
  date[bg]="${grey_900}"
  date[format]="%H:%M"
elif [[ ${tmux_window_width} -le 100 ]]
then
  mode_indicator[order]="icon"
  session[order]="session"
  hostname[order]=""
  ip[order]=""
  uptime[order]=""
  battery[order]=""
  disk[order]=""
  net[order]=""
  mem[order]=""
  cpu[order]=""
  date[format]="%H:%M"
fi


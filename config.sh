#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2034

SCRIPTPATH="$( cd -- "$(dirname "$0")" || exit 1 >/dev/null 2>&1 ; pwd -P )"

# Source my colors definition
source "${SCRIPTPATH}/colors.sh"

# Module variables
# =============================================================================
# Define list of modules to setup
modules=(
  "separator"
  "mode_indicator"
  "session"
  "window"
  "hostname"
  "ip"
  "uptime"
  "battery"
  "disk"
  "net"
  "mem"
  "cpu"
  "date"
)

for i_module in "${modules[@]}"
do
  declare -A "${i_module}"
done

# Set global variable to be used with main tmux config
# -----------------------------------------------------------------------------
declare -A separator
separator[right]=""
separator[left]=""

declare -A status
status[bg]="${red_500}"
status[fg]="${grey_100}"
status[fg_inv]="${grey_900}"
status[left_module]="mode_indicator session"
status[left_prefix]=""
status[left_suffix]="#[bg=${status[bg]}]${separator[left]}"
status[right_module]="hostname ip uptime battery disk net mem cpu date"
status[right_prefix]="#[fg=${status[bg]}]"
status[right_suffix]=" "
status[intervale]=2

tmux set -g @status_fg "${status[fg]}"
tmux set -g @status_bg "${status[bg]}"

declare -A mode
mode[fg]="${status[fg_inv]}"
mode[bg]="${yellow_500}"

declare -A message
message[fg]="${status[fg_inv]}"
message[bg]="${green_500}"

declare -A message_command
message_command[fg]="${status[fg_inv]}"
message_command[bg]="${red_500}"

# Set status modules variables
# -----------------------------------------------------------------------------
declare -A tier_clr
tier_clr[1]="${green_500}"
tier_clr[2]="${yellow_500}"
tier_clr[3]="${orange_500}"
tier_clr[4]="${red_500}"

# Mode Indicator Module
# -----------------------------------------------------------------------------
mode_indicator[prefix]="WAIT"
mode_indicator[prefix_icon]=""
mode_indicator[prefix_bg]="${yellow_500}"
mode_indicator[prefix_fg]="${grey_900}"

mode_indicator[copy]="COPY"
mode_indicator[copy_icon]=""
mode_indicator[copy_bg]="${purple_500}"
mode_indicator[copy_fg]="${grey_900}"

mode_indicator[sync]="SYNC"
mode_indicator[sync_icon]=""
mode_indicator[sync_bg]="${red_500}"
mode_indicator[sync_fg]="${grey_900}"

mode_indicator[empty]="TMUX"
mode_indicator[empty_icon]=""
mode_indicator[empty_bg]="${blue_500}"
mode_indicator[empty_fg]="${grey_900}"

# Session name Module
# -----------------------------------------------------------------------------
session[bg]="${brown_900}"
session[fg]="${grey_100}"
session[icon]=" "

# Window name Module
# -----------------------------------------------------------------------------
window[bg]="${status[bg]}"
window[fg]="${grey_100}"

window[current_bg]="${light_green_A400}"
window[current_fg]="${grey_900}"

# Hostname Module
# -----------------------------------------------------------------------------
hostname[bg]="${grey_800}"
hostname[fg]="#{@status_bg}"

hostname[icon]=" "

# IP Module
# -----------------------------------------------------------------------------
ip[bg]="${grey_900}"
ip[fg]="${purple_300}"

ip[icon]=""
ip[icon_vpn]=""


# Uptime Module
# -----------------------------------------------------------------------------
uptime[bg]="${grey_800}"
uptime[fg]="${cyan_300}"

uptime[icon]=""

# Battery Module
# -----------------------------------------------------------------------------
battery[bg]="${grey_900}"
battery[fg]="gradient"

battery[icon]=""
battery[icon_plugged]="ﮣ"
battery[bar]="gradient"
battery[bar_type]="vertical"
battery[pourcent]="gradient"
battery[remaining]="gradient"
battery[bar_tier1_color_charging]="${tier_clr[4]}"
battery[bar_tier2_color_charging]="${tier_clr[3]}"
battery[bar_tier3_color_charging]="${tier_clr[2]}"
battery[bar_tier4_color_charging]="${tier_clr[1]}"
battery[bar_tier1_color_discharging]="${tier_clr[4]}"
battery[bar_tier2_color_discharging]="${tier_clr[3]}"
battery[bar_tier3_color_discharging]="${tier_clr[2]}"
battery[bar_tier4_color_discharging]="${green_500}"
battery[bar_tier4_color_full]="${light_green_500}"

# Disk Module
# -----------------------------------------------------------------------------
disk[bg]="${grey_800}"
disk[fg]="gradient"

disk[icon]=" "
disk[icon_color]="${grey_100}"
disk[bar]="gradient"
disk[bar_type]="vertical"
disk[bar_tier1_color]="${tier_clr[1]}"
disk[bar_tier2_color]="${tier_clr[2]}"
disk[bar_tier3_color]="${tier_clr[3]}"
disk[bar_tier4_color]="${tier_clr[4]}"
disk[devices]="/dev/sda2 /dev/sdc1"

# Net Module
# -----------------------------------------------------------------------------
net[bg]="${grey_900}"
net[fg]="gradient"

net[ping_timeout]="3"
net[ping_route]="wikipedia.org"

net[online_icon]=" "
net[online_fg]="${green_500}"

net[offline_icon]=" "
net[offline_fg]="${red_500}"

net[up]="true"
net[up_icon]=" "
net[up_bar]="gradient"
net[up_bar_type]="vertical"
net[up_value]="gradient"
net[up_bar_tier1_color]="${tier_clr[1]}"
net[up_bar_tier2_color]="${tier_clr[2]}"
net[up_bar_tier3_color]="${tier_clr[3]}"
net[up_bar_tier4_color]="${tier_clr[4]}"
net[up_bar_tier2_value]="2500"
net[up_bar_tier3_value]="5000"
net[up_bar_tier4_value]="7500"

net[down]="true"
net[down_icon]=" "
net[down_bar]="gradient"
net[down_bar_type]="vertical"
net[down_value]="gradient"
net[down_bar_tier1_color]="${tier_clr[1]}"
net[down_bar_tier2_color]="${tier_clr[2]}"
net[down_bar_tier3_color]="${tier_clr[3]}"
net[down_bar_tier4_color]="${tier_clr[4]}"
net[down_bar_tier2_value]="2500"
net[down_bar_tier3_value]="5000"
net[down_bar_tier4_value]="7500"

# Memory module
# -----------------------------------------------------------------------------
mem[bg]="${grey_800}"
mem[fg]="gradient"

mem[icon]=""
mem[bar]="gradient"
mem[bar_type]="vertical"
mem[value]="gradient"
mem[bar_tier1_color]="${tier_clr[1]}"
mem[bar_tier2_color]="${tier_clr[2]}"
mem[bar_tier3_color]="${tier_clr[3]}"
mem[bar_tier4_color]="${tier_clr[4]}"

# CPU Module
# -----------------------------------------------------------------------------
cpu[bg]="${grey_900}"
cpu[fg]="gradient"

cpu[icon]=""
cpu[bar]="gradient"
cpu[bar_type]="vertical"
cpu[pourcent]="gradient"
cpu[bar_tier1_color]="${tier_clr[1]}"
cpu[bar_tier2_color]="${tier_clr[2]}"
cpu[bar_tier3_color]="${tier_clr[3]}"
cpu[bar_tier4_color]="${tier_clr[4]}"

# Date Module
# -----------------------------------------------------------------------------
date[bg]="${grey_800}"
date[fg]="${grey_100}"
date[devices]=""

date[icon]=""
date[format]="%a %d %b | %H:%M"

# Set my default module order
# -----------------------------------------------------------------------------
mode_indicator[order]="icon mode_indicator"
session[order]="icon session"
hostname[order]="icon value"
ip[order]="icon_vpn vpn icon value"
uptime[order]="icon value"
battery[order]="icon status bar pourcent remaining"
disk[order]="icon sub_order"
disk[sub_order]="bar"
net[order]="up_value up_icon status down_icon down_value"
mem[order]="icon bar value"
cpu[order]="icon bar pourcent load"
date[order]="icon format"

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

# Source per host/user configuration if any
# -----------------------------------------------------------------------------
host_file="${SCRIPTPATH}/$(hostname)/config.sh"
user_file="${SCRIPTPATH}/$(hostname)/$(whoami)/config.sh"
if [[ -f "${host_file}" ]]
then
  # shellcheck disable=SC1090
  source "${host_file}"
  if [[ -f "${user_file}" ]]
  then
    # shellcheck disable=SC1090
    source "${user_file}"
  fi
fi

# Update fg to bold if SSH
# -----------------------------------------------------------------------------
if [[ -n "${SSH_CLIENT}"  ]]
then
  status[fg]+=" bold"
fi

# Update fg with underscore if root
# -----------------------------------------------------------------------------
if [[ "$(whoami)" == "root"  ]]
then
  status[fg]+=" underscore"
fi

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

# Global status variables
# =============================================================================
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

# Window list status configuration
# -----------------------------------------------------------------------------
# Window segments separator
tmux set -g window-status-separator ""

# Format of the window list
tmux setw -g window-status-format "#(#{window} 'normal')"
tmux setw -g window-status-current-format "#(#{window} 'current')"

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

# SSH toggle nested tmux key binding
# -----------------------------------------------------------------------------
# We want to have single prefix key "prefix", usable both for local and remote session
# we don't want to "prefix" + "a" approach either
# Idea is to turn off all key bindings and prefix handling on local session,
# so that all keystrokes are passed to inner/remote session

# See: toggle on/off all keybindings · Issue #237 · tmux/tmux -
#   https://github.com/tmux/tmux/issues/237

# Also, change some visual styles when window keys are off
tmux bind -T root F12 "
  set prefix None
  set prefix2 None
  set key-table off
  set status-position top
  set status-style 'fg=${status[fg]} strikethrough,bg=${status[bg]}'
  if -F '#{pane_in_mode}' 'send-keys -X cancel'
  refresh-client -S"

tmux bind -T off F12 "
  set -u prefix
  set -u prefix2
  set -u key-table
  set status-position bottom
  set -u status-style
  refresh-client -S"

tmux run "${HOME}/.config/tmux/plugins/tmux-sysstat/sysstat.tmux"

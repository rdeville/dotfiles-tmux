# Module variables
# -----------------------------------------------------------------------------
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
status[bg]="${green_500}"
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
hostname[fg]="${status[bg]}"

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


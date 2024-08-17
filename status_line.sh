#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2034

tmux_window_width=$(tmux display -p "#{window_width}")

# Set global variable to be used with main tmux config
# -----------------------------------------------------------------------------
# Default separator
separator[right]=""
separator[left]=""

# Define responsive behaviour
# -----------------------------------------------------------------------------
if [[ ${tmux_window_width} -gt 200 ]]; then
	status[left_module]="mode_indicator session git"
	status[right_module]="battery uptime mem cpu disk hostname date"

	battery[order]="icon percent "
	cpu[order]="icon bar load"
	date[order]="icon format"
	date[format]="%a %d %b | %H:%M "
	disk[order]="icon sub_order"
	disk[sub_order]="bar"
	git[order]="icon tag branch status_order file_order"
	git[status_order]="up_to_date conflicted behind ahead"
	git[file_order]="stash added deleted modified type_changed renamed untracked"
	hostname[order]="icon value"
	mem[order]="icon bar value"
	mode_indicator[order]="icon text"
	session[order]="icon session"
	uptime[order]="icon value"
elif [[ 150 -lt ${tmux_window_width} && ${tmux_window_width} -le 200 ]]; then
	status[left_module]="mode_indicator session git"
	status[right_module]="battery uptime mem cpu disk hostname date"

	battery[order]="icon percent "
	cpu[order]="icon bar load"
	date[order]="icon format"
	date[format]="%a %d %b | %H:%M "
	disk[order]="icon sub_order"
	disk[sub_order]="bar"
	git[order]="icon status_order"
	git[status_order]="up_to_date conflicted behind ahead"
	hostname[order]="icon value"
	mem[order]="icon bar"
	mode_indicator[order]="icon text"
	session[order]="icon session"
	uptime[order]="icon value"
elif [[ 100 -lt ${tmux_window_width} && ${tmux_window_width} -le 150 ]]; then
	status[left_module]="mode_indicator session git"
	status[right_module]="battery mem cpu date"

	battery[order]="icon"
	cpu[order]="icon bar"
	date[order]="icon format"
	date[format]="%H:%M "
	git[order]="icon"
	mem[order]="icon bar"
	mode_indicator[order]="icon"
	session[order]="session"
elif [[ ${tmux_window_width} -le 100 ]]; then
	status[left_module]="mode_indicator session"
	status[right_module]="battery date"

	mode_indicator[order]="icon"
	session[order]="session"
	battery[order]="icon"
	date[format]="%H:%M "
fi

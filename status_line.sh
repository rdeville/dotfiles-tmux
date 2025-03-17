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

	date[order]="icon format"
	date[format]="%a %d %b | %H:%M "
	hostname[order]="icon value"
	mode_indicator[order]="icon text"
	session[order]="icon session"
elif [[ 150 -lt ${tmux_window_width} && ${tmux_window_width} -le 200 ]]; then
	status[left_module]="mode_indicator session git"
	status[right_module]="battery uptime mem cpu disk hostname date"

	date[order]="icon format"
	date[format]="%a %d %b | %H:%M "
	hostname[order]="icon value"
	mode_indicator[order]="icon text"
	session[order]="icon session"
elif [[ 100 -lt ${tmux_window_width} && ${tmux_window_width} -le 150 ]]; then
	status[left_module]="mode_indicator session git"
	status[right_module]="battery mem cpu date"

	date[order]="icon format"
	date[format]="%H:%M "
	mode_indicator[order]="icon"
	session[order]="session"
elif [[ ${tmux_window_width} -le 100 ]]; then
	status[left_module]="mode_indicator session"
	status[right_module]="battery date"

	mode_indicator[order]="icon"
	session[order]="session"
	date[format]="%H:%M "
fi

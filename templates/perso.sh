#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2034

status[bg]="${green_700}"
status[fg]="${grey_100}"

window[bg]="${green_500}"
window[fg]="${green_700}"

window[current_bg]="${green_a400}"
window[current_fg]="${black}"

status[left_module]="mode_indicator session git"
status[right_module]="hostname date"

date[format]="%a %d %b | %H:%M"

#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A window

declare -A window_default
window_default[bg]='#000000'
window_default[fg]='#ffffff'

window_default[current_bg]='#00ff00'
window_default[current_fg]='#000000'

window_default[format]=' #I:#W'

window_default[order]='format'

_get_window_settings() {
  for idx in "${!window_default[@]}"
  do
    window[$idx]=$(get_tmux_option "@window_${idx}" "${window_default[$idx]}")
  done

  session[separator_right]=$(get_tmux_option "@right_separator")
}


main() {
  local window_string=""
  local window_state="$1"
  local up_gradient_color=""
  local down_gradient_color=""

  _get_window_settings

  if [[ "${window_state}" =~ current ]]
  then
    fg_clr="${window[current_fg]}"
    bg_clr="${window[current_bg]}"
  else
    fg_clr="${window[fg]}"
    bg_clr="${window[bg]}"
  fi

  if [[ "${window_state}" =~ "current" ]]
  then
    window_string+="#[bg=${bg_clr},fg=${window[bg]}]"
    window_string+="${window[separator_right]}"
  fi
  window_string+="#[fg=${fg_clr},bg=${bg_clr}]"
  window_string+="${window[format]}"
  window_string+="#[bg=${window[bg]},fg=${bg_clr}]"
  window_string+="${window[separator_right]}"

  echo -e "${window_string}"
}

main "$@"

# ******************************************************************************
# VIM windowLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************


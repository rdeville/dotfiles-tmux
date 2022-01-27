#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A online

declare -A online_default
online_default[ping_timeout]='3'
online_default[ping_route]='wikipedia.org'

online_default[separator_right]=''
online_default[separator_left]=''

online_default[online_icon]=' '
online_default[online_bg]='#4caf50'
online_default[online_fg]='#000000'

online_default[offline_icon]=' '
online_default[offline_bg]='#f44336'
online_default[offline_fg]='#000000'

online_default[order]="status"

_get_online_settings() {
  for idx in "${!online_default[@]}"
  do
    online[$idx]=$(get_tmux_option "@online_${idx}" "${online_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    online[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    online[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_online_value() {
  if ping -c 1 -w "${online[ping_timeout]}" "${online[ping_route]}" &> /dev/null
  then
    online[status]="online"
  else
    online[status]="offline"
  fi
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${online[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  fg_clr="${online["${online[status]}_fg"]}"
  bg_clr="${online["${online[status]}_bg"]}"

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        online_string+="#[bg=${bg_clr}]"
        online_string+="${online[${idx_name}]}"
      fi
      ;;
    separator_right)
      online_string+="#[fg=${bg_clr}]"
      online_string+="${online[${idx_name}]}"
      ;;
    end)
      online_string+="#[fg=${bg_clr}]"
      ;;
    status)
      online_string+="#[bg=${bg_clr},fg=${fg_clr}]"
      online_string+=" ${online["${online[$idx_name]}_icon"]}"
      ;;
    *)
      online_string+="#[bg=${bg_clr},fg=${fg_clr}]"
      online_string+=" ${online[$idx_name]}"
      ;;
  esac
}

main() {
  local option=$1
  local online_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_online_settings
  _get_online_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${online[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${online_string}"
}

main "$@"

# ******************************************************************************
# VIM onlineLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************

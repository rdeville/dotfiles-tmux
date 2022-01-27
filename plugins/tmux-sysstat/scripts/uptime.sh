#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A uptime

declare -A uptime_default
uptime_default[bg]='#636363'
uptime_default[fg]='#ffffff'

uptime_default[icon]="⬆️"

uptime_default[order]="icon value"

_get_uptime_settings() {
  for idx in "${!uptime_default[@]}"
  do
    uptime[$idx]=$(get_tmux_option "@uptime_${idx}" "${uptime_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    uptime[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    uptime[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_uptime_value() {
  # From:
  # https://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds
  local seconds=$(cat /proc/uptime | awk '{printf("%d",$1+.5)}')
  local days=$(( seconds / 60 / 60 / 24))
  local hours=$(( seconds / 60 / 60 % 24))
  local minutes=$(( seconds/ 60 % 60))
  (( $days > 0 )) && uptime[value]="${days} Days "
  uptime[value]+="$(printf "%02d:%02d" "${hours}" "${minutes}")"
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${uptime[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        uptime_string+="#[bg=${uptime[bg]}]"
        uptime_string+="${uptime[${idx_name}]}"
      fi
      ;;
    separator_right)
      uptime_string+="#[fg=${uptime[bg]}]"
      uptime_string+="${uptime[${idx_name}]}"
      ;;
    end)
      uptime_string+="#[fg=${uptime[bg]}]"
      ;;
    *)
      uptime_string+="#[bg=${uptime[bg]},fg=${uptime[fg]}]"
      uptime_string+=" ${uptime[$idx_name]}"
      ;;
  esac
}

main() {
  local option=$1
  local uptime_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_uptime_settings
  _get_uptime_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${uptime[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${uptime_string}"
}

main "$@"

# ******************************************************************************
# VIM uptimeLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************


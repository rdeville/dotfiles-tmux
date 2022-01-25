#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A ip

declare -A ip_default
ip_default[bg]='#636363'
ip_default[fg]='#ffffff'
ip_default[separator_right]=''
ip_default[separator_left]=''

ip_default[icon]=" "
ip_default[icon_vpn]="旅"
ip_default[vpn]=""

ip_default[order]="icon_vpn vpn icon value"

_get_ip_settings() {
  for idx in "${!ip_default[@]}"
  do
    ip[$idx]=$(get_tmux_option "@ip_${idx}" "${ip_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    ip[separator_right]=$(get_tmux_option "@right_separator")
    echo "${ip[separator_right]}"
  elif [[ "${option}" == "status-left" ]]
  then
    ip[separator_left]=$(get_tmux_option "@left_separator")
  fi
}

_get_ip_value() {
  ip[value]+="$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')"
  if ip link show | grep -q -E " tun.*:" &> /dev/null
  then
    ip[vpn]="$(ip link show | grep -q -E " tun.*:" | cut -d ":" -f 2)"
  fi
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${ip[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        ip_string+="#[bg=${ip[bg]}]"
        ip_string+="${ip[${idx_name}]}"
      fi
      ;;
    separator_right)
      ip_string+="#[bg=${ip[bg]}]"
      ip_string+="${ip[${idx_name}]}"
      ;;
    end)
      ip_string+="#[fg=${ip[bg]}]"
      ;;
    icon_vpn)
      if [[ -n "${ip[vpn]}" ]]
      then
        ip_string+="#[bg=${ip[bg]},fg=${ip[fg]}]"
        ip_string+=" ${ip[$idx_name]}"
      fi
      ;;
    *)
      ip_string+="#[bg=${ip[bg]},fg=${ip[fg]}]"
      ip_string+=" ${ip[$idx_name]}"
      ;;
  esac
}

main() {
  local option=$1
  local ip_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_ip_settings
  _get_ip_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${ip[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${ip_string}"
}

main "$@"

# ******************************************************************************
# VIM ipLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************

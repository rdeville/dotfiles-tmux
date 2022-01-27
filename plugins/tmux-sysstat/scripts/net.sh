#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A net

declare -A net_default
net_default[bg]='#212121'
net_default[fg]='gradient'
net_default[devices]=''

net_default[ping_timeout]='3'
net_default[ping_route]='wikipedia.org'

net_default[online_icon]=' '
net_default[online_fg]='#4caf50'

net_default[offline_icon]=' '
net_default[offline_fg]='#f44336'

net_default[up]='true'
net_default[up_icon]=' '
net_default[up_bar]='gradient'
net_default[up_bar_type]='vertical'
net_default[up_bar_size]=10
net_default[up_value]='gradient'
net_default[up_bar_color]='#ffffff'
net_default[up_bar_tier1_color]='#8bc34a'
net_default[up_bar_tier2_color]='#ffeb3b'
net_default[up_bar_tier3_color]='#ff9800'
net_default[up_bar_tier4_color]='#f44336'
net_default[up_bar_tier2_value]='5000'
net_default[up_bar_tier3_value]='7500'
net_default[up_bar_tier4_value]='10000'

net_default[down]='true'
net_default[down_icon]=' '
net_default[down_bar]='gradient'
net_default[down_bar_type]='vertical'
net_default[down_bar_size]=10
net_default[down_value]='gradient'
net_default[down_bar_color]='#ffffff'
net_default[down_bar_tier1_color]='#8bc34a'
net_default[down_bar_tier2_color]='#ffeb3b'
net_default[down_bar_tier3_color]='#ff9800'
net_default[down_bar_tier4_color]='#f44336'
net_default[down_bar_tier2_value]='5000'
net_default[down_bar_tier3_value]='7500'
net_default[down_bar_tier4_value]='10000'


net_default[order]="up_bar up_value up_icon status down_icon down_value down_bar"

_get_net_settings() {
  for idx in "${!net_default[@]}"
  do
    net[$idx]=$(get_tmux_option "@net_${idx}" "${net_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    net[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    net[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_net_value(){
  local curr_card_stat=""
  local net_up=0
  local net_up_card=""
  local net_down=0
  local net_down_card=""
  local net_info=("0" "0")
  local old_net_info=("0" "0")
  local devices=""
  local round_pourcent=0
  local tmp_stat_file="/tmp/old_net_stat.tmp"
  local tmux_status_interval=$(get_tmux_option "status-interval")

  if [[ -f "${tmp_stat_file}" ]]
  then
    IFS=" " read -a old_net_info <<< $(cat "${tmp_stat_file}")
  else
    old_net_info=("0" "0")
  fi

  if [[ -z "${net[devices]}" ]]
  then
    # Use of echo to flatten output
    devices="$(echo $(ip link show | grep -E "^[0-9]*:" | cut -d ":" -f 2 )) "
    # Remove loopback, docker and bridge card
    devices=${devices// br* / }
    devices=${devices// docker* / }
  fi

  IFS=" " read -a devices <<<$(echo ${devices})
  for i_device in "${devices[@]}"
  do
    curr_card_stat="/sys/class/net/${i_device}/statistics"
    net_up="$(cat "${curr_card_stat}/tx_bytes")"
    net_down="$(cat "${curr_card_stat}/rx_bytes")"
    net_info[0]=$(echo "${net_info[0]} + ${net_up}" | bc -l )
    net_info[1]=$(echo "${net_info[1]} + ${net_down}" | bc -l )
  done

  # Save current active and total CPU
  echo "${net_info[0]} ${net_info[1]}" > "${tmp_stat_file}"

  net[up_val]=$(echo "(${net_info[0]} - ${old_net_info[0]}) / 1024 / ${tmux_status_interval}" | bc -l)
  net[up_pourcent]=$(echo "${net[up_val]} / ${net[up_bar_tier4_value]} * 100" | bc -l )
  round_pourcent=$(echo "${net[up_pourcent]}"| awk '{printf("%d",$1+.5)}')
  if [[ "${round_pourcent}" -gt 100 ]]
  then
    net[up_pourcent]=100
  fi
  net[down_val]=$(echo "(${net_info[1]} - ${old_net_info[1]}) / 1024 / ${tmux_status_interval}" | bc -l)
  net[down_pourcent]=$(echo "${net[down_val]} / ${net[down_bar_tier4_value]} * 100" | bc -l )
  round_pourcent=$(echo "${net[down_pourcent]}"| awk '{printf("%d",$1+.5)}')
  if [[ "${round_pourcent}" -gt 100 ]]
  then
    net[down_pourcent]=100
  fi

  if ping -c 1 -w "${net[ping_timeout]}" "${net[ping_route]}" &> /dev/null
  then
    net[status]="online"
  else
    net[status]="offline"
  fi
}


_get_gradient_color() {
  local type=$1
  local tier4=0
  local tier3=0
  local tier2=0
  local val=""

  case "$type" in
    up)
      tier4=${net[up_bar_tier4_value]}
      tier3=${net[up_bar_tier3_value]}
      tier2=${net[up_bar_tier2_value]}
      tier4_clr=${net[up_bar_tier4_color]}
      tier3_clr=${net[up_bar_tier3_color]}
      tier2_clr=${net[up_bar_tier2_color]}
      tier1_clr=${net[up_bar_tier1_color]}
      val=$(echo "${net[up_val]}"| awk '{printf("%d",$1+.5)}')
      ;;
    down)
      tier4=${net[down_bar_tier4_value]}
      tier3=${net[down_bar_tier3_value]}
      tier2=${net[down_bar_tier2_value]}
      tier4_clr=${net[down_bar_tier4_color]}
      tier3_clr=${net[down_bar_tier3_color]}
      tier2_clr=${net[down_bar_tier2_color]}
      tier1_clr=${net[down_bar_tier1_color]}
      val=$(echo "${net[down_val]}"| awk '{printf("%d",$1+.5)}')
      ;;
  esac

  if [[ "${val}" -ge "${tier4}" ]]
  then
    echo "${tier4_clr}"
  elif [[ "${val}" -ge "${tier3}" ]]
  then
    echo "${tier3_clr}"
  elif [[ "${val}" -ge "${tier2}" ]]
  then
    echo "${tier2_clr}"
  else
    echo "${tier1_clr}"
  fi
}

_net_human_readable(){
  local val=$(echo "$1"| awk '{printf("%d",$1+.5)}')
  local ext=("k" "M" "G")
  local ext_idx=0
  local output_val=$1

  while [[ $(( ${val} / 1024 )) -gt 0 ]]
  do
    output_val=$(echo "${output_val} / 1024" | bc -l)
    val="$(( val / 1024 ))"
    ext_idx="$(( ext_idx + 1 ))"
  done

  printf "%04.1f%s" "${output_val}" "${ext[$ext_idx]}B"
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${net[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  if [[ "${idx_name}" =~ up_* ]]
  then
    gradient_color="${up_gradient_color}"
  else
    gradient_color="${down_gradient_color}"
  fi

  if [[ ${net[fg]} == "gradient" ]]
  then
    fg_clr="${gradient_color}"
  else
    fg_clr="${net[fg]}"
    if [[ ${net[$idx_name]} == "gradient" ]]
    then
      fg_clr="${gradient_color}"
    else
      fg_clr="${net[fg]}"
    fi
  fi
  bg_clr="${net[bg]}"

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        net_string+="#[bg=${net[bg]}]"
        net_string+="${net[${idx_name}]}"
      fi
      ;;
    separator_right)
      net_string+="#[fg=${net[bg]}]"
      net_string+="${net[${idx_name}]}"
      ;;
    end)
      net_string+="#[fg=${net[bg]}]"
      ;;
    status)
      net_string+="#[bg=${bg_clr},fg=${net_default[online_fg]}]"
      net_string+=" ${net["${net[status]}_icon"]}"
      ;;
    *_bar)
      net_string+="#[fg=${fg_clr},bg=${bg_clr}] "
      net_string+="#[fg=${fg_clr},bg=black]"
      case "${idx_name}" in
        up*)
            if [[ "${net[up_bar_type]}" == "horizontal" ]]
            then
              net_string+="$(compute_hbar_graph ${net[up_pourcent]} ${net[up_bar_size]})"
            elif [[ "${net[up_bar_type]}" == "vertical" ]]
            then
              net_string+="$(compute_vbar_graph ${net[up_pourcent]} ${net[up_bar_size]})"
            else
              net_string+="ERROR-Wrong up_bar_type"
            fi
          ;;
        down*)
            if [[ "${net[down_bar_type]}" == "horizontal" ]]
            then
              net_string+="$(compute_hbar_graph ${net[down_pourcent]} ${net[down_bar_size]})"
            elif [[ "${net[down_bar_type]}" == "vertical" ]]
            then
              net_string+="$(compute_vbar_graph ${net[down_pourcent]} ${net[down_bar_size]})"
            else
              net_string+="ERROR-Wrong down_bar_type"
            fi
          ;;
      esac
      net_string+="#[fg=${fg_clr},bg=${bg_clr}]"
      ;;
    *)
      net_string+="#[fg=${fg_clr},bg=${bg_clr}]"
      case "${idx_name}" in
        *_value)
          net_string+=" $(_net_human_readable ${net[${idx_name//ue/}]})"
          ;;
        *)
          net_string+=" ${net[$idx_name]}"
          ;;
      esac
      ;;
  esac
}


main() {
  local option="$1"
  local net_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_net_settings
  _get_net_value

  up_gradient_color="$(_get_gradient_color "up")"
  down_gradient_color="$(_get_gradient_color "down")"

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${net[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${net_string}"
}

main "$@"

# ******************************************************************************
# VIM MODELINE
# vim: ft=sh: fdm=indent
# ******************************************************************************

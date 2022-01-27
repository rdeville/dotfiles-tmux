#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A disk

declare -A disk_default
disk_default[bg]='#424242'
disk_default[fg]='gradient'

disk_default[icon]=" "
disk_default[icon_color]="#f0f0f0"
disk_default[bar]='gradient'
disk_default[bar_type]='vertical'
disk_default[bar_size]=10
disk_default[pourcent]='true'
disk_default[bar_color]='#ffffff'
disk_default[bar_tier1_color]='#8bc34a'
disk_default[bar_tier2_color]='#ffeb3b'
disk_default[bar_tier3_color]='#ff9800'
disk_default[bar_tier4_color]='#f44336'
disk_default[devices]=''

disk_default[order]='icon sub_order'
disk_default[sub_order]='bar pourcent'

_get_disk_settings() {
  for idx in "${!disk_default[@]}"
  do
    disk[$idx]=$(get_tmux_option "@disk_${idx}" "${disk_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    disk[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    disk[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_disk_value(){
  declare -A disk_info
  local active=0
  local total=0
  local old_disk_info=()
  local load_avg=()

  while read line
  do
    IFS=" " read -a tmp_data <<< "${line}"
    if [[ ${disk[devices]} =~ ${tmp_data[0]} ]]
    then
      disk[${tmp_data[0]}]=${tmp_data[4]}
    fi
  done <<<$(df -H | grep -vE '^Filesystem|tmpfs|cdrom' )
}

_get_gradient_color() {
  local value=$(echo "$1" | awk '{printf("%d",$1+.5)}')
  if (( ${value} >= 75 ))
  then
    echo "${disk[bar_tier4_color]}"
  elif (( ${value} >= 50 ))
  then
    echo "${disk[bar_tier3_color]}"
  elif (( ${value} >= 25 ))
  then
    echo "${disk[bar_tier2_color]}"
  else
    echo "${disk[bar_tier1_color]}"
  fi
}

_compute_bg_fg(){
  local idx_name=$1
  local disk_name=$2
  local fg_clr=""
  local bg_clr=""

  if [[  -z "${disk[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  if [[ ${disk[bg]} == "gradient" ]]
  then
    if [[ ${idx_name} == "bar" && ${disk[$idx_name]} == "gradient" ]]
    then
      fg_clr="${gradient_color}"
    elif [[ ${idx_name} == "bar" ]]
    then
      fg_clr="white"
    else
      fg_clr="black"
    fi
    bg_clr="${gradient_color}"
  elif [[ ${disk[fg]} == "gradient" ]]
  then
    bg_clr="${disk[bg]}"
    fg_clr="${gradient_color}"
    if [[ "${idx_name}" == "icon" ]]
    then
      fg_clr="${disk[icon_color]:-#ffffff}"
    fi
  else
    bg_clr="${disk[bg]}"
    fg_clr="${disk[fg]}"
    if [[ ${disk[$idx_name]} == "gradient" && "${idx_name}" != "icon" ]]
    then
      fg_clr="${gradient_color}"
    fi
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
      disk_string+="#[fg=${disk[bg]}]"
      disk_string+="${disk[${idx_name}]}"
      ;;
    end)
      disk_string+="#[fg=${disk[bg]}]"
      ;;
    bar)
      disk_string+=" #[bg=black]"
      disk_string+="#[fg=${fg_clr}]"
      if [[ "${disk[bar_type]}" == "horizontal" ]]
      then
        disk_string+="$(compute_hbar_graph ${disk[$disk_name]} ${disk[bar_size]})"
      elif [[ "${disk[bar_type]}" == "vertical" ]]
      then
        disk_string+="$(compute_vbar_graph ${disk[$disk_name]} ${disk[bar_size]})"
      else
        disk_string+="ERROR-Wrong bar_type"
      fi
      disk_string+="#[bg=${bg_clr}]"
      ;;
    *)
      disk_string+="#[bg=${bg_clr}]"
      disk_string+="#[fg=${fg_clr}]"
      case "${idx_name}" in
        pourcent)
          disk_string+=" $(printf "%02d%%" "${disk[${disk_name}]/\%}")"
          ;;
        *)
          disk_string+=" ${disk[$idx_name]}"
          ;;
      esac
      ;;
  esac
}


main() {
  local option=$1
  local disk_string=""
  local disk_list=""
  local gradient_color=""

  _get_disk_settings

  if [[ -z "${disk[devices]}" ]]
  then
    disk[devices]=$(df -H \
      | grep -vE '^run|Filesystem|tmpfs|cdrom|\/boot\/efi' \
      | grep -vE '^dev ' \
      | grep -vE '^udev ' \
      | awk '{ print $1 }' \
      | sort | uniq)
  fi

  _get_disk_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${disk[order]}
  do
    if [[ "${i_module}" == "sub_order" ]]
    then
      for i_disk in ${disk[devices]}
      do
        for i_submodule in ${disk[sub_order]}
        do
          gradient_color="$(_get_gradient_color ${disk[${i_disk}]})"
          _compute_bg_fg "${i_submodule}" "${i_disk}"
        done
      done
    else
      _compute_bg_fg "${i_module}"
    fi
  done
  _compute_bg_fg "end"

  echo -e "${disk_string}"

  return
}

main "$@"

# ******************************************************************************
# VIM MODELINE
# vim: ft=sh: fdm=indent
# ******************************************************************************

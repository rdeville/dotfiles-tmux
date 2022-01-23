#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A cpu

declare -A cpu_default
cpu_default[bg]='#212121'
cpu_default[fg]='gradient'
cpu_default[separator_right]=''
cpu_default[separator_left]=''

cpu_default[icon]=" "
cpu_default[bar]='gradient'
cpu_default[bar_type]='vertical'
cpu_default[bar_size]=10
cpu_default[pourcent]='gradient'
cpu_default[load]='gradient'
cpu_default[nb_load]='1'
cpu_default[bar_color]='#ffffff'
cpu_default[bar_tier1_color]='#8bc34a'
cpu_default[bar_tier2_color]='#ffeb3b'
cpu_default[bar_tier3_color]='#ff9800'
cpu_default[bar_tier4_color]='#f44336'

cpu_default[order]="icon bar pourcent load"

_get_cpu_settings() {
  for idx in "${!cpu_default[@]}"
  do
    cpu[$idx]=$(get_tmux_option "@cpu_${idx}" "${cpu_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    cpu[separator_right]=$(get_tmux_option "@right_separator")
  elif [[ "${option}" == "status-left" ]]
  then
    cpu[separator_left]=$(get_tmux_option "@left_separator")
  fi
}

_get_cpu_value(){
  local active=0
  local total=0
  local cpu_info=()
  local old_cpu_info=()
  local load_avg=()
  local tmp_stat_file="/tmp/old_proc_stat.tmp"

  IFS=" " read -a cpu_info <<< $(cat "/proc/stat" | grep "cpu ")
  if [[ -f "${tmp_stat_file}" ]]
  then
    IFS=" " read -a old_cpu_info <<< $(cat "${tmp_stat_file}")
  else
    old_cpu_info=("0" "0")
  fi

  # Compute active CPU
  cpu[val_active]=$(echo "${cpu_info[1]} + ${cpu_info[2]} + ${cpu_info[3]} + \
                 ${cpu_info[6]} + ${cpu_info[7]} + ${cpu_info[8]} + \
                 ${cpu_info[9]} + ${cpu_info[10]}" | bc -l )

  # Compute total CPU
  cpu[val_total]=$(echo "${cpu[val_active]} + ${cpu_info[4]} + ${cpu_info[5]}" | bc -l )

  # Save current active and total CPU
  echo "${cpu[val_active]} ${cpu[val_total]}" > "${tmp_stat_file}"

  # Compute number of operation since last call
  cpu[val_active]=$(echo "${cpu[val_active]} - ${old_cpu_info[0]}" | bc -l  )
  cpu[val_total]=$(echo "${cpu[val_total]} - ${old_cpu_info[1]}" | bc -l  )

  # Compute pourcentage of CPU usage
  cpu[val_pourcent]=$(echo "${cpu[val_active]} / ${cpu[val_total]} * 100" | bc -l)

  # Compute load average
  IFS=" " read -a load_avg <<< $(cat /proc/loadavg)
  cpu[val_load]=""
  for (( idx=0; idx < ${cpu[nb_load]}; idx++ ))
  do
    cpu[val_load]+=" ${load_avg[$idx]}"
  done
}

_get_gradient_color() {
  local value=$(echo "${cpu[val_pourcent]}"| awk '{printf("%d",$1+.5)}')
  if (( ${value} >= 75 ))
  then
    echo "${cpu[bar_tier4_color]}"
  elif (( ${value} >= 50 ))
  then
    echo "${cpu[bar_tier3_color]}"
  elif (( ${value} >= 25 ))
  then
    echo "${cpu[bar_tier2_color]}"
  else
    echo "${cpu[bar_tier1_color]}"
  fi
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""

  if [[  -z "${cpu[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  if [[ ${cpu[bg]} == "gradient" ]]
  then
    if [[ ${idx_name} == "bar" && ${cpu[$idx_name]} == "gradient" ]]
    then
      fg_clr="${gradient_color}"
    elif [[ ${idx_name} == "bar" ]]
    then
      fg_clr="white"
    else
      fg_clr="black"
    fi
    bg_clr="${gradient_color}"
  elif [[ ${cpu[fg]} == "gradient" ]]
  then
    fg_clr="${gradient_color}"
    bg_clr="${cpu[bg]}"
  else
    fg_clr="${cpu[fg]}"
    if [[ ${cpu[$idx_name]} == "gradient" ]]
    then
      fg_clr="${gradient_color}"
    else
      fg_clr="${cpu[fg]}"
    fi
    bg_clr="${cpu[bg]}"
  fi

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        cpu_string+="#[bg=${cpu[bg]}]"
        cpu_string+="${cpu[${idx_name}]}"
      fi
      ;;
    separator_right)
      cpu_string+="#[bg=${cpu[bg]}]"
      cpu_string+="${cpu[${idx_name}]}"
      ;;
    end)
      cpu_string+="#[fg=${cpu[bg]}]"
      ;;
    bar)
      cpu_string+="#[bg=black]"
      cpu_string+="#[fg=${fg_clr}]"
      if [[ "${cpu[bar_type]}" == "horizontal" ]]
      then
        cpu_string+="$(compute_hbar_graph ${cpu[val_pourcent]} ${cpu[bar_size]})"
      elif [[ "${cpu[bar_type]}" == "vertical" ]]
      then
        cpu_string+="$(compute_vbar_graph ${cpu[val_pourcent]} ${cpu[bar_size]})"
      else
        cpu_string+="ERROR-Wrong bar_type"
      fi
      ;;
    *)
      cpu_string+="#[bg=${bg_clr}]"
      cpu_string+="#[fg=${fg_clr}]"
      case "${idx_name}" in
        pourcent)
          cpu_string+=" $(printf "%04.1f%%" "${cpu[val_pourcent]}")"
          ;;
        load)
          cpu_string+="$(printf "%s" "${cpu[val_load]}")"
          ;;
        *)
          cpu_string+=" ${cpu[$idx_name]}"
          ;;
      esac
      ;;
  esac
}

main() {
  local option="$1"
  local cpu_string=""
  local gradient_color=""

  _get_cpu_settings
  _get_cpu_value

  gradient_color="$(_get_gradient_color)"

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${cpu[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${cpu_string}"
}

main "$@"

# ******************************************************************************
# VIM MODELINE
# vim: ft=sh: fdm=indent
# ******************************************************************************

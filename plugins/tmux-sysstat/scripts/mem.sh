#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A mem

declare -A mem_default
mem_default[bg]='#424242'
mem_default[fg]='gradient'
mem_default[separator_right]=''
mem_default[separator_left]=''

mem_default[icon]=" "
mem_default[bar]='gradient'
mem_default[bar_type]='vertical'
mem_default[bar_size]=10
mem_default[pourcent]=''
mem_default[value]='gradient'
mem_default[total]=''
mem_default[bar_color]='#ffffff'
mem_default[bar_tier1_color]='#8bc34a'
mem_default[bar_tier2_color]='#ffeb3b'
mem_default[bar_tier3_color]='#ff9800'
mem_default[bar_tier4_color]='#f44336'

mem_default[order]="icon bar pourcent value total"

_get_mem_settings() {
  for idx in "${!mem_default[@]}"
  do
    mem[$idx]=$(get_tmux_option "@mem_${idx}" "${mem_default[$idx]}")
  done
  if [[ "${option}" == "status-right" ]]
  then
    mem[separator_right]=$(get_tmux_option "@right_separator")
  elif [[ "${option}" == "status-left" ]]
  then
    mem[separator_left]=$(get_tmux_option "@left_separator")
  fi
}

_get_mem_value(){
  local active=0
  local total=0
  local mem_info=()

  IFS=" " read -a mem_info <<< $(free | grep "Mem:")

  # Compute used mem
  mem[val_active]="$(echo "${mem_info[2]} + ${mem_info[4]}" | bc -l)"
  mem[val_buffer]="${mem_info[5]}"
  # Compute total mem
  mem[val_total]="${mem_info[1]}"
  # Compute pourcentage of mem usage
  mem[val_pourcent]="$(echo "${mem[val_active]} / ${mem[val_total]} * 100" | bc -l)"
}

_get_gradient_color() {
  local value=$(echo "${mem[val_pourcent]}"| awk '{printf("%d",$1+.5)}')
  if (( ${value} >= 75 ))
  then
    echo "${mem[bar_tier4_color]}"
  elif (( ${value} >= 50 ))
  then
    echo "${mem[bar_tier3_color]}"
  elif (( ${value} >= 25 ))
  then
    echo "${mem[bar_tier2_color]}"
  else
    echo "${mem[bar_tier1_color]}"
  fi
}

_mem_human_readable(){
  local val=$1
  local ext=("k" "M" "G")
  local ext_idx=0
  local output_val=$1

  while [[ $(( ${val} / 1024 )) -gt 0 ]]
  do
    output_val=$(echo "${output_val} / 1024" | bc -l)
    val="$(( val / 1024 ))"
    ext_idx="$(( ext_idx + 1 ))"
  done

  printf "%1.2f%s" "${output_val}" "${ext[$ext_idx]}B"
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""

  if [[  -z "${mem[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  if [[ ${mem[bg]} == "gradient" ]]
  then
    if [[ ${idx_name} == "bar" && ${mem[$idx_name]} == "gradient" ]]
    then
      fg_clr="${gradient_color}"
    elif [[ ${idx_name} == "bar" ]]
    then
      fg_clr="white"
    else
      fg_clr="black"
    fi
    bg_clr="${gradient_color}"
  elif [[ ${mem[fg]} == "gradient" ]]
  then
    fg_clr="${gradient_color}"
    bg_clr="${mem[bg]}"
  else
    fg_clr="${mem[fg]}"
    if [[ ${mem[$idx_name]} == "gradient" ]]
    then
      fg_clr="${gradient_color}"
    else
      fg_clr="${mem[fg]}"
    fi
    bg_clr="${mem[bg]}"
  fi

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        mem_string+="#[bg=${mem[bg]}]"
        mem_string+="${mem[${idx_name}]}"
      fi
      ;;
    separator_right)
      mem_string+="#[bg=${mem[bg]}]"
      mem_string+="${mem[${idx_name}]}"
      ;;
    end)
      mem_string+="#[fg=${mem[bg]}]"
      ;;
    bar)
      mem_string+="#[bg=black]"
      mem_string+="#[fg=${fg_clr}]"
      if [[ "${mem[bar_type]}" == "horizontal" ]]
      then
        mem_string+="$(compute_hbar_graph ${mem[val_pourcent]} ${mem[bar_size]})"
      elif [[ "${mem[bar_type]}" == "vertical" ]]
      then
        mem_string+="$(compute_vbar_graph ${mem[val_pourcent]} ${mem[bar_size]})"
      else
        mem_string+="ERROR-Wrong bar_type"
      fi
      ;;
    *)
      mem_string+="#[bg=${bg_clr}]"
      mem_string+="#[fg=${fg_clr}]"
      case "${idx_name}" in
        pourcent)
          mem_string+=" $(printf "%02.1f%%" "${mem[val_pourcent]}")"
          ;;
        value)
          mem_string+=" $(_mem_human_readable ${mem[val_active]})"
          ;;
        total)
          mem_string+="/$(_mem_human_readable ${mem[val_total]})"
          ;;
        *)
          mem_string+=" ${mem[$idx_name]}"
          ;;
      esac
      ;;
  esac
}

main() {
  local option="$1"
  local mem_string=""
  local gradient_color=""

  _get_mem_value
  _get_mem_settings

  gradient_color="$(_get_gradient_color)"

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${mem[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${mem_string}"
}

main "$@"

# ******************************************************************************
# VIM MODELINE
# vim: ft=sh: fdm=indent
# ******************************************************************************

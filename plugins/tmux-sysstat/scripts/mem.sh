#!/usr/bin/env bash

SCRIPTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A mem

declare -A mem_default
mem_default[bg]="#424242"
mem_default[fg]="gradient"

mem_default[icon]=" "
mem_default[bar]="gradient"
mem_default[percent]="gradient"
mem_default[value]="gradient"
mem_default[total]="#8bc34a"
mem_default[bar_color]="#ffffff"
mem_default[clr_1]="#8bc34a"
mem_default[clr_2]="#ffeb3b"
mem_default[clr_3]="#ff9800"
mem_default[clr_4]="#f44336"

mem_default[order]="icon bar percent value total"

_get_mem_settings() {
  for idx in "${!mem_default[@]}"; do
    mem[${idx}]=$(get_tmux_option "@mem_${idx}" "${mem_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    mem[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    mem[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_mem_value() {
  local mem_info=()

  IFS=" " read -r -a mem_info <<<"$(free | grep "Mem:")"

  # Compute used mem
  mem[val_active]="$((mem_info[2]))"
  mem[val_buffer]="${mem_info[5]}"
  # Compute total mem
  mem[val_total]="${mem_info[1]}"
  # Compute pourcentage of mem usage
  mem[val_percent]="$(echo "${mem[val_active]} / ${mem[val_total]} * 100" | bc -l)"
}

_mem_human_readable() {
  local val=$1
  local ext=("Ki" "Mi" "Gi")
  local ext_idx=0
  local output_val=$1

  while [[ $((val / 1024)) -gt 0 ]]; do
    output_val=$(echo "${output_val} / 1024" | bc -l)
    val="$((val / 1024))"
    ext_idx="$((ext_idx + 1))"
  done

  printf "%1.2f%s" "${output_val}" "${ext[${ext_idx}]}B"
}

_compute_bg_fg() {
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local clr_idx
  local idx

  idx=$(get_gradient_idx "${mem[val_percent]}")
  clr_idx="clr_${idx}"

  if ((idx == 5)); then
    clr_idx="clr_4"
  fi

  if [[ ${mem[bg]} == "gradient" ]]; then
    bg_clr="${mem[${clr_idx}]}"
    fg_clr="${mem[fg]}"
  elif [[ ${mem[fg]} == "gradient" ]]; then
    fg_clr="${mem[${clr_idx}]}"
    bg_clr="${mem[bg]}"
  else
    fg_clr="${mem[fg]}"
    bg_clr="${mem[bg]}"
  fi

  case "${idx_name}" in
  status-left)
    mem_string+="#[bg=${mem[bg]}]"
    mem_string+="${mem[separator_left]}"
    ;;
  status-right)
    mem_string+="#[fg=${mem[bg]}]"
    mem_string+="${mem[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      mem_string+=" #[bg=default]"
    fi
    mem_string+="#[fg=${mem[bg]}]"
    ;;
  bar)
    mem_string+=" #[bg=black]"
    mem_string+="#[fg=${fg_clr}]"
    mem_string+="$(compute_bar_graph "${mem[val_percent]}")"
    mem_string+="#[bg=${bg_clr}]"
    ;;
  percent)
    mem_string+="#[bg=${bg_clr}]"
    mem_string+="#[fg=${fg_clr}]"
    mem_string+=" $(printf "%02.1f%%" "${mem[val_percent]}")"
    ;;
  value)
    mem_string+="#[bg=${bg_clr}]"
    mem_string+="#[fg=${fg_clr}]"
    mem_string+=" $(_mem_human_readable "${mem[val_active]}")"
    ;;
  total)
    mem_string+="#[bg=${bg_clr}]"
    mem_string+="#[fg=${fg_clr}]"
    mem_string+="/$(_mem_human_readable "${mem[val_total]}")"
    ;;
  *)
    mem_string+="#[bg=${bg_clr}]"
    mem_string+="#[fg=${fg_clr}]"
    mem_string+=" ${mem[${idx_name}]}"
    ;;
  esac
}

main() {
  local option="$1"
  local mem_string=""

  _get_mem_settings
  _get_mem_value

  _compute_bg_fg "${option}"
  for module in ${mem[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo -e "${mem_string}"
}

main "$@"

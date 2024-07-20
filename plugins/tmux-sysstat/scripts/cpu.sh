#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A cpu

declare -A cpu_default
cpu_default[bg]="#212121"
cpu_default[fg]="gradient"

cpu_default[icon]=" "
cpu_default[bar]="gradient"
cpu_default[percent]="gradient"
cpu_default[load]="gradient"
cpu_default[nb_load]="1"
cpu_default[bar_color]="#ffffff"
cpu_default[clr_1]="#8bc34a"
cpu_default[clr_2]="#ffeb3b"
cpu_default[clr_3]="#ff9800"
cpu_default[clr_4]="#f44336"

cpu_default[order]="icon bar percent load"

_get_cpu_settings() {
  for idx in "${!cpu_default[@]}"; do
    cpu[${idx}]=$(get_tmux_option "@cpu_${idx}" "${cpu_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    cpu[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    cpu[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

get_percent() {
  case $(uname -s) in
  Linux)
    percent=$(LC_NUMERIC=en_US.UTF-8 top -bn2 -d 0.01 |
      grep "Cpu(s)" |
      tail -1 |
      sed "s/.*, *\([0-9.]*\)%* id.*/\1/" |
      awk '{print 100 - $1}')
    ;;

  Darwin)
    cpuvalue=$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')
    cpucores=$(sysctl -n hw.logicalcpu)
    percent=$((cpuvalue / cpucores))
    ;;

  OpenBSD)
    cpuvalue=$(ps -A -o %cpu | awk -F. '{s+=$1} END {print s}')
    cpucores=$(sysctl -n hw.ncpuonline)
    percent=$((cpuvalue / cpucores))
    ;;
  esac
  echo "${percent}"
}

get_load() {
  loadavg=$(uptime | awk -F'[a-z]:' '{ print $2}' | sed "s/,//g")
  echo "${loadavg}"
}

_get_cpu_value() {
  local load_avg=()

  cpu[val_percent]=$(get_percent)
  cpu[val_load]=$(get_load)

  IFS=" " read -r -a load_avg <<<"$(cat /proc/loadavg)"
  cpu[val_load]=""
  for ((idx = 0; idx < cpu[nb_load]; idx++)); do
    cpu[val_load]+=" ${load_avg[${idx}]}"
  done
}

_get_gradient_color() {
  local value
  value=$(echo "${cpu[val_percent]}" | awk '{printf("%d",$1+.5)}')
  echo "${cpu["clr_bar_$((value / 25 + 1))"]}"
}

_compute_bg_fg() {
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local clr_idx
  local idx

  idx=$(get_gradient_idx "${cpu[val_percent]}")
  clr_idx="clr_${idx}"

  if ((idx == 5)); then
    clr_idx="clr_4"
  fi

  if [[ ${cpu[bg]} == "gradient" ]]; then
    bg_clr="${cpu[${clr_idx}]}"
    fg_clr="${cpu[fg]}"
  elif [[ ${cpu[fg]} == "gradient" ]]; then
    fg_clr="${cpu[${clr_idx}]}"
    bg_clr="${cpu[bg]}"
  else
    fg_clr="${cpu[fg]}"
    bg_clr="${cpu[bg]}"
  fi

  case "${idx_name}" in
  status-left)
    cpu_string+="#[bg=${cpu[bg]}]"
    cpu_string+="${cpu[separator_left]}"
    ;;
  status-right)
    cpu_string+="#[fg=${cpu[bg]}]"
    cpu_string+="${cpu[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      cpu_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        cpu_string+="#[fg=${cpu[bg]}]"
        cpu_string+="${cpu[separator_left]}"
      fi
    fi
    cpu_string+="#[fg=${cpu[bg]}]"
    ;;
  bar)
    cpu_string+=" #[bg=black]"
    cpu_string+="#[fg=${fg_clr}]"
    cpu_string+="$(compute_bar_graph "${cpu[val_percent]}")"
    cpu_string+="#[bg=${bg_clr}]"
    ;;
  percent)
    cpu_string+="#[bg=${bg_clr}]"
    cpu_string+="#[fg=${fg_clr}]"
    cpu_string+=" $(printf "%04.1f%%" "${cpu[val_percent]}")"
    ;;
  load)
    cpu_string+="#[bg=${bg_clr}]"
    cpu_string+="#[fg=${fg_clr}]"
    cpu_string+="$(printf "%s" "${cpu[val_load]}")"
    ;;
  *)
    cpu_string+="#[bg=${bg_clr}]"
    cpu_string+="#[fg=${fg_clr}]"
    cpu_string+=" ${cpu[${idx_name}]}"
    ;;
  esac
}

main() {
  local option="$1"
  local cpu_string=""

  _get_cpu_settings
  _get_cpu_value

  _compute_bg_fg "${option}"
  for module in ${cpu[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo -e "${cpu_string}"
}

main "$@"

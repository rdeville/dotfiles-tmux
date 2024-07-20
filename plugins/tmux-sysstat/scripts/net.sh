#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A net

declare -A net_default
net_default[bg]="#212121"
net_default[fg]="gradient"
net_default[devices]=""

net_default[ping_timeout]="3"
net_default[ping_route]="wikipedia.org"

net_default[online_icon]="󰲝 "
net_default[online_fg]="#4caf50"

net_default[offline_icon]="󰲜 "
net_default[offline_fg]="#f44336"

net_default[clr_1]="#8bc34a"
net_default[clr_2]="#ffeb3b"
net_default[clr_3]="#ff9800"
net_default[clr_4]="#f44336"
net_default[threshold_clr_1]="0"
net_default[threshold_clr_2]="5000"
net_default[threshold_clr_3]="7500"
net_default[threshold_clr_4]="10000"

net_default[up]="true"
net_default[up_icon]=" "
net_default[up_value]="gradient"

net_default[down]="true"
net_default[down_icon]=" "
net_default[down_value]="gradient"

net_default[order]="up_value up_icon status down_icon down_value"
#
_get_net_settings() {
  for idx in "${!net_default[@]}"; do
    net[${idx}]=$(get_tmux_option "@net_${idx}" "${net_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    net[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    net[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_net_value() {
  local curr_card_stat=""
  local net_up=0
  local net_down=0
  local net_info=("0" "0")
  local old_net_info=("0" "0")
  local stat_file="/tmp/cache/tmux_plugins/last_net_stat.data"
  local tmux_status_interval
  tmux_status_interval=$(get_tmux_option "status-interval")

  if ! ping -c 1 -w "${net[ping_timeout]}" "${net[ping_route]}" &>/dev/null; then
    net[status]="offline"
    net[up_val]=0
    net[down_val]=0
    return
  fi
  net[status]="online"

  if [[ -f "${stat_file}" ]]; then
    IFS=" " read -r -a old_net_info <<<"$(cat "${stat_file}")"
  else
    mkdir -p "$(dirname ${stat_file})"
  fi

  for net_card in $(ip link show | grep -E "^[0-9]*:" | cut -d ":" -f 2); do
    if ! [[ "${net_card}" =~ (lo|br|docker) ]]; then
      curr_card_stat="/sys/class/net/${net_card}/statistics"
      net_up="$(cat "${curr_card_stat}/tx_bytes")"
      net_down="$(cat "${curr_card_stat}/rx_bytes")"
      # shellcheck disable=SC2004
      net_info[0]=$((${net_info[0]} + net_up))
      # shellcheck disable=SC2004
      net_info[1]=$((${net_info[1]} + net_down))
    fi
  done

  # Save current active and total net
  echo "${net_info[0]} ${net_info[1]}" >"${stat_file}"
  # shellcheck disable=SC2004
  net[up_val]=$(((${net_info[0]} - ${old_net_info[0]}) / 1024 / tmux_status_interval))
  # shellcheck disable=SC2004
  net[down_val]=$(((${net_info[1]} - ${old_net_info[1]}) / 1024 / tmux_status_interval))
}

_net_human_readable() {
  local val
  local ext=("Ki" "Mi" "Gi")
  local ext_idx=0
  local output_val=$1

  val=$(echo "$1" | awk '{printf("%d",$1+.5)}')

  while [[ $((val / 1024)) -gt 0 ]]; do
    output_val=$(echo "${output_val} / 1024" | bc -l)
    val="$((val / 1024))"
    ext_idx="$((ext_idx + 1))"
  done

  printf "%04.1f%s" "${output_val}" "${ext[${ext_idx}]}B"
}

_compute_bg_fg() {
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local clr_idx=""
  local idx=1

  if [[ ${idx_name} =~ up_* ]]; then
    val=$(get_gradient_idx "${net[up_val]}")
  elif [[ ${idx_name} =~ down_* ]]; then
    val=$(get_gradient_idx "${net[down_val]}")
  fi

  while [[ ${val} -le ${net[threshold_clr_${idx}]} ]] && ((idx != 4)); do
    idx=$((idx + 1))
  done
  clr_idx="clr_${idx}"

  if [[ ${net[bg]} == "gradient" ]]; then
    bg_clr="${net[${clr_idx}]}"
    fg_clr="${net[fg]}"
  elif [[ ${net[fg]} == "gradient" ]]; then
    fg_clr="${net[${clr_idx}]}"
    bg_clr="${net[bg]}"
  else
    fg_clr="${net[fg]}"
    bg_clr="${net[bg]}"
  fi

  case "${idx_name}" in
  status-left)
    net_string+="#[bg=${net[bg]}]"
    net_string+="${net[separator_left]}"
    ;;
  status-right)
    net_string+="#[fg=${net[bg]}]"
    net_string+="${net[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      net_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        net_string+="#[fg=${net[bg]}]"
        net_string+="${net[separator_left]}"
      fi
    fi
    net_string+="#[fg=${net[bg]}]"
    ;;
  status)
    net_string+="#[bg=${bg_clr},fg=${net_default[online_fg]}]"
    net_string+=" ${net["${net[status]}_icon"]}"
    ;;
  *_value)
    net_string+="#[bg=${bg_clr}]"
    net_string+="#[fg=${fg_clr}]"
    net_string+=" $(_net_human_readable "${net[${idx_name//ue/}]}")"
    ;;
  *)
    net_string+="#[bg=${bg_clr}]"
    net_string+="#[fg=${fg_clr}]"
    net_string+=" ${net[${idx_name}]}"
    ;;
  esac
}

main() {
  local option="$1"
  local net_string=""

  _get_net_settings
  _get_net_value

  _compute_bg_fg "${option}"
  for module in ${net[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo -e "${net_string}"
}

main "$@"

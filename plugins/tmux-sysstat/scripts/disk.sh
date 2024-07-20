#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A disk

declare -A disk_default
disk_default[bg]='#424242'
disk_default[fg]='gradient'

disk_default[icon]=" "
disk_default[icon_color]="#f0f0f0"
disk_default[percent]="gradient"
disk_default[bar_color]='#ffffff'
disk_default[clr_1]="#8bc34a"
disk_default[clr_2]="#ffeb3b"
disk_default[clr_3]="#ff9800"
disk_default[clr_4]="#f44336"

disk_default[mounts]="/,/home,/nix/store"

disk_default[order]="icon sub_order"
disk_default[sub_order]="icon bar percent"

_get_disk_settings() {
  for idx in "${!disk_default[@]}"; do
    disk[${idx}]=$(get_tmux_option "@disk_${idx}" "${disk_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    disk[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    disk[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_disk_value() {
  IFS=',' read -r -a list <<<"${disk[mounts]}"
  for mount in "${list[@]}"; do
    value=$(df | grep "${mount}\$" | awk '{printf $5;}')
    if [[ -n ${value} ]]; then
      disk[${mount}]=${value/\%/}
    fi
  done
}

_get_gradient_color() {
  local value=$1
  echo "${disk["clr_$((value / 25 + 1))"]}"
}

_compute_bg_fg() {
  local idx_name=$1
  local disk_name=$2
  local fg_clr=""
  local bg_clr=""
  local clr_idx
  local idx
  idx=$(get_gradient_idx "${disk[${disk_name}]}")
  clr_idx="clr_${idx}"
  if ((idx == 5)); then
    clr_idx="clr_4"
  fi

  if [[ "${module}" == "sub_order" ]]; then
    if [[ ${disk[bg]} == "gradient" ]]; then
      bg_clr="${disk[${clr_idx}]}"
      fg_clr="${disk[fg]}"
    elif [[ ${disk[fg]} == "gradient" ]]; then
      bg_clr="${disk[bg]}"
      fg_clr="${disk[${clr_idx}]}"
    else
      bg_clr="${disk[bg]}"
      fg_clr="${disk[fg]}"
    fi
  elif [[ "${idx_name}" == "icon" ]]; then
    bg_clr="${disk[bg]}"
    fg_clr="${disk[icon_color]}"
  else
    bg_clr="${disk[bg]}"
    fg_clr="${disk[fg]}"
  fi

  case "${idx_name}" in
  status-left)
    disk_string+="#[bg=${disk[bg]}]"
    disk_string+="${disk[separator_left]}"
    ;;
  status-right)
    disk_string+="#[fg=${disk[bg]}]"
    disk_string+="${disk[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      disk_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        disk_string+="#[fg=${disk[bg]}]"
        disk_string+="${disk[separator_left]}"
      fi
    fi
    disk_string+="#[fg=${disk[bg]}]"
    ;;
  bar)
    disk_string+=" #[bg=black]"
    disk_string+="#[fg=${fg_clr}]"
    disk_string+="$(compute_bar_graph "${disk[${disk_name}]}")"
    disk_string+="#[bg=${bg_clr}]"
    ;;
  percent)
    disk_string+="#[bg=${bg_clr}]"
    disk_string+="#[fg=${fg_clr}]"
    disk_string+=" $(printf "%02d%%" "${disk[${disk_name}]/\%/}")"
    ;;
  *)
    disk_string+="#[bg=${bg_clr}]"
    disk_string+="#[fg=${fg_clr}]"
    disk_string+=" ${disk[${idx_name}]}"
    ;;
  esac
}

main() {
  local option=$1
  local disk_string=""

  _get_disk_settings

  if [[ -z "${disk[mounts]}" ]]; then
    return 1
  fi

  _get_disk_value

  _compute_bg_fg "${option}"
  for module in ${disk[order]}; do
    if [[ "${module}" == "sub_order" ]]; then
      IFS=',' read -r -a list <<<"${disk[mounts]}"
      for mount in "${list[@]}"; do
        if [[ -n "${disk[${mount}]}" ]]; then
          for submodule in ${disk[sub_order]}; do
            _compute_bg_fg "${submodule}" "${mount}"
          done
        fi
      done
    else
      _compute_bg_fg "${module}"
    fi
  done
  _compute_bg_fg "end"

  echo -e "${disk_string}"

  return
}

main "$@"

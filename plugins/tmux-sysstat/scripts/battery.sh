#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

declare -A battery

declare -A battery_default
battery_default[bg]="#212121"
battery_default[fg]="gradient"
battery_default[clr_type]="gradient" # Or fixed

battery_default[order]="icon percent"

battery_default[icon]=" 󱊡"
battery_default[icon_plugged]="󱐥󱊡"

battery_default[clr_1]="#f44336"
battery_default[clr_2]="#ff9800"
battery_default[clr_3]="#ffeb3b"
battery_default[clr_4]="#8bc34a"

battery_default[icon_discharging_1]=" 󰂎"
battery_default[icon_discharging_2]=" 󱊡"
battery_default[icon_discharging_3]=" 󱊢"
battery_default[icon_discharging_4]=" 󱊣"

battery_default[icon_charging_1]="󱐥󰂎"
battery_default[icon_charging_2]="󱐥󱊡"
battery_default[icon_charging_3]="󱐥󱊢"
battery_default[icon_charging_4]="󱐥󱊣"

battery_default[clr_full]="#8bc34a"
battery_default[icon_full]=" 󱊣"
battery_default[icon_unknown]=" 󰂑"

_get_battery_settings() {
  for idx in "${!battery_default[@]}"; do
    battery[${idx}]=$(get_tmux_option "@battery_${idx}" "${battery_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    battery[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    battery[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_battery_value() {
  # Only working for linux now
  local bat
  bat=$(ls -d /sys/class/power_supply/BAT*)
  if [[ ! -x "$(which acpi 2>/dev/null)" ]]; then
    battery[status]="$(tr '[:upper:]' '[:lower:]' <"${bat}/status")"
  else
    battery[status]="$(acpi | cut -d: -f2- | cut -d, -f1 | tr -d ' ')"
  fi

  case $(uname -s) in
  Linux)
    if [[ ! -x "$(which acpi 2>/dev/null)" ]]; then
      battery[val_percent]=$(cat "${bat}/capacity")
    else
      battery[val_percent]=$(acpi | cut -d: -f2- | cut -d, -f2 | tr -d '% ')
    fi
    ;;
  Darwin)
    battery[val_percent]=$(pmset -g batt | grep -Eo '[0-9]?[0-9]?[0-9]%')
    ;;
  FreeBSD)
    battery[val_percent]=$(apm | sed '8,11d' | grep life | awk '{print $4}')
    ;;
  esac
}

_compute_bg_fg() {
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local icon_idx=""
  local clr_idx=""
  local idx

  idx=$(get_gradient_idx "${battery[val_percent]}")
  clr_idx="clr_${idx}"
  icon_idx="icon_${battery[status]}_${idx}"

  if ((idx == 5)); then
    clr_idx="clr_full"
    icon_idx="icon_full"
  fi

  if [[ ${battery[bg]} == "gradient" ]]; then
    fg_clr="${battery[fg]}"
    bg_clr="${battery[${clr_idx}]}"
  elif [[ ${battery[fg]} == "gradient" ]]; then
    fg_clr="${battery[${clr_idx}]}"
    bg_clr="${battery[bg]}"
  else
    fg_clr="${battery[fg]}"
    bg_clr="${battery[bg]}"
  fi

  case "${idx_name}" in
  status-left)
    battery_string+="#[bg=${battery[bg]}]"
    battery_string+="${battery[separator_left]}"
    ;;
  status-right)
    battery_string+="#[fg=${battery[bg]}]"
    battery_string+="${battery[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      battery_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        battery_string+="#[fg=${battery[bg]}]"
        battery_string+="${battery[separator_left]}"
      fi
    fi
    battery_string+="#[fg=${battery[bg]}]"
    ;;
  percent)
    battery_string+="#[bg=${bg_clr},fg=${fg_clr}]"
    battery_string+=" ${battery[val_percent]}%"
    ;;
  icon)
    battery_string+="#[bg=${bg_clr},fg=${fg_clr}]"
    battery_string+=" ${battery[${icon_idx}]}"
    ;;
  *)
    battery_string+="#[bg=${bg_clr}]"
    battery_string+="#[fg=${fg_clr}]"
    battery_string+=" ${battery[${idx_name}]}"
    ;;
  esac
}

main() {
  local option=$1
  local battery_string=""

  _get_battery_settings
  _get_battery_value

  _compute_bg_fg "${option}"
  for module in ${battery[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo -e "${battery_string}"
}

main "$@"

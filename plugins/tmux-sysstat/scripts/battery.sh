#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A battery

declare -A battery_default
battery_default[bg]='#212121'
battery_default[fg]='gradient'

battery_default[icon]=''
battery_default[icon_plugged]='ﮣ '
battery_default[bar]='gradient'
battery_default[bar_type]='vertical'
battery_default[bar_size]=10
battery_default[pourcent]='gradient'
battery_default[remaining]='gradient'
battery_default[bar_color]='#ffffff'
battery_default[bar_tier1_color_charging]='#8bc34a'
battery_default[bar_tier2_color_charging]='#ffeb3b'
battery_default[bar_tier3_color_charging]='#ff9800'
battery_default[bar_tier4_color_charging]='#f44336'
battery_default[bar_tier1_color_discharging]='#f44336'
battery_default[bar_tier2_color_discharging]='#ff9800'
battery_default[bar_tier3_color_discharging]='#ffeb3b'
battery_default[bar_tier4_color_discharging]='#8bc34a'
battery_default[bar_tier4_color_full]='#8bc34a'

battery_default[icon_discharging_0]=''
battery_default[icon_discharging_1]=''
battery_default[icon_discharging_2]=''
battery_default[icon_discharging_3]=''
battery_default[icon_discharging_4]=''
battery_default[icon_discharging_5]=''

battery_default[icon_charging_0]=''
battery_default[icon_charging_1]=''
battery_default[icon_charging_2]=''
battery_default[icon_charging_3]=''
battery_default[icon_charging_4]=''
battery_default[icon_charging_5]=''

battery_default[icon_full_5]=''

battery_default[order]="icon status bar pourcent remaining"

_get_battery_settings() {
  for idx in "${!battery_default[@]}"
  do
    battery[$idx]=$(get_tmux_option "@battery_${idx}" "${battery_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    battery[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    battery[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_battery_value() {
  local remaining_time=""
  if ! compgen -G "/sys/class/power_supply/BAT*" &> /dev/null
  then
    return 1
  fi

  source /sys/class/power_supply/BAT*/uevent

  battery[status]="$( echo "${POWER_SUPPLY_STATUS}" | tr '[:upper:]' '[:lower:]' )"
  battery[val_pourcent]="${POWER_SUPPLY_CAPACITY}"

  if command -v upower &> /dev/null
  then
    if [[ "${battery[status]}" == "full" ]]
    then
      battery[val_remain]="--:--"
      return 0
    fi

    remaining_time="$(upower -i /org/freedesktop/UPower/devices/battery_${POWER_SUPPLY_NAME} \
      | grep 'time to' | cut -d ':' -f 2)"
    if echo "${remaining_time}" | grep -q "hours" &> /dev/null
    then
      remaining_time="$(echo ${remaining_time/hours})"
      remaining_time_hours="${remaining_time/.*}"
      remaining_time_minutes="$(echo "0.${remaining_time/*.} * 60" | bc -l | cut -d "." -f 1 )"
    elif echo "${remaining_time}" | grep -q "minutes" &> /dev/null
    then
      remaining_time=$(echo "${remaining_time/hours}")
      remaining_time_hours="00"
      remaining_time_minutes="$(echo ${remaining_time/.*})"
    fi
    battery[val_remain]="${remaining_time_hours}:${remaining_time_minutes}"
  else
    battery[val_remain]=""
  fi
}

_get_gradient_color() {
  local value=$(echo "${battery[val_pourcent]}"| awk '{printf("%d",$1+.5)}')
  if (( ${value} >= 75 ))
  then
    echo "${battery["bar_tier4_color_${battery[status]}"]}"
  elif (( ${value} >= 50 ))
  then
    echo "${battery["bar_tier3_color_${battery[status]}"]}"
  elif (( ${value} >= 25 ))
  then
    echo "${battery["bar_tier2_color_${battery[status]}"]}"
  else
    echo "${battery["bar_tier1_color_${battery[status]}"]}"
  fi
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local icon_tier=""

  if [[  -z "${battery[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  if [[ ${battery[bg]} == "gradient" ]]
  then
    if [[ ${idx_name} == "bar" && ${battery[$idx_name]} == "gradient" ]]
    then
      fg_clr="${gradient_color}"
    elif [[ ${idx_name} == "bar" ]]
    then
      fg_clr="white"
    else
      fg_clr="black"
    fi
    bg_clr="${gradient_color}"
  elif [[ ${battery[fg]} == "gradient" ]]
  then
    fg_clr="${gradient_color}"
    bg_clr="${battery[bg]}"
  else
    fg_clr="${battery[fg]}"
    if [[ ${battery[$idx_name]} == "gradient" ]]
    then
      fg_clr="${gradient_color}"
    else
      fg_clr="${battery[fg]}"
    fi
    bg_clr="${battery[bg]}"
  fi

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        battery_string+="#[bg=${battery[bg]}]"
        battery_string+="${battery[${idx_name}]}"
      fi
      ;;
    separator_right)
      battery_string+="#[fg=${battery[bg]}]"
      battery_string+="${battery[${idx_name}]}"
      ;;
    end)
      battery_string+="#[fg=${battery[bg]}]"
      ;;
    bar)
      battery_string+=" #[bg=black]"
      battery_string+="#[fg=${fg_clr}]"
      if [[ "${battery[bar_type]}" == "horizontal" ]]
      then
        battery_string+="$(compute_hbar_graph ${battery[val_pourcent]} ${battery[bar_size]})"
      elif [[ "${battery[bar_type]}" == "vertical" ]]
      then
        battery_string+="$(compute_vbar_graph ${battery[val_pourcent]} ${battery[bar_size]})"
      else
        battery_string+="ERROR-Wrong bar_type"
      fi
      ;;
    pourcent)
      battery_string+="#[bg=${bg_clr},fg=${fg_clr}]"
      battery_string+=" ${battery[val_pourcent]}%"
      ;;
    status)
      battery_string+="#[bg=${bg_clr},fg=${fg_clr}]"
      icon_tier="icon_${battery[status]}_$(( ${battery[val_pourcent]} / 20 ))"
      battery_string+=" ${battery[$icon_tier]}"
      ;;
    remaining)
      battery_string+="#[bg=${bg_clr},fg=${fg_clr}]"
      battery_string+=" (${battery[val_remain]})"
      ;;
    *)
      battery_string+="#[bg=${bg_clr},fg=${fg_clr}]"
      battery_string+=" ${battery[$idx_name]}"
      ;;
  esac
}

main() {
  local option=$1
  local battery_string=""

  _get_battery_settings
  _get_battery_value



  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  if [[ -z "${battery[val_pourcent]}" ]]
  then
    gradient_color="${battery_default[bar_tier4_color_full]}"
    _compute_bg_fg "icon_plugged"
  else
    gradient_color="$(_get_gradient_color)"
    for i_module in ${battery[order]}
    do
      _compute_bg_fg "${i_module}"
    done
  fi
  _compute_bg_fg "end"

  echo -e "${battery_string}"
}

main "$@"

# ******************************************************************************
# VIM batteryLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************


#!/usr/bin/env bash
# shellcheck disable=SC2154,SC2034

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" || exit 1 >/dev/null 2>&1
  pwd -P
)"

# Module variables
# -----------------------------------------------------------------------------
# Define list of modules to setup
modules=(
  "date"
  "mode_indicator"
  "session"
  "hostname"
  # Even if not a tmux-systat module required to have sperator
  "separator"
)
declare -A status

for i_module in "${modules[@]}"; do
  declare -A "${i_module}"
done

# Source my colors definition
source "${SCRIPTPATH}/colors.sh"
source "${SCRIPTPATH}/status_line.sh"

# Set Global Configuration
status[left_module]="mode_indicator session"
status[right_module]="hostname date"

date[format]="%a %d %b | %H:%M"

HOST_FILE="${SCRIPTPATH}/hosts/$(hostname).sh"
DEFAULT_FILE="${SCRIPTPATH}/templates/default.sh"
if [[ -f "${HOST_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${HOST_FILE}"
else
  # shellcheck disable=SC1090
  source "${DEFAULT_FILE}"
fi

# Update fg to bold if SSH
# -----------------------------------------------------------------------------
if [[ -n "${SSH_CLIENT}" ]]; then
  status[fg]+=" bold"
fi

# Update fg with underscore if root
# -----------------------------------------------------------------------------
if [[ "$(whoami)" == "root" ]]; then
  status[fg]+=" underscore"
fi

tmux set -g @status_fg "${status[fg]}"
tmux set -g @status_bg "${status[bg]}"

# Generate status-{right,left} content
# -----------------------------------------------------------------------------
for module in ${status[left_module]}; do
  declare -n tmp_array=${module}
  status[left]+="#{${module}}"
done

for module in ${status[right_module]}; do
  declare -n tmp_array=${module}
  status[right]+=" #{${module}}"
done

# Set module configuration as tmux global variables
# -----------------------------------------------------------------------------
for module in "${modules[@]}"; do
  declare -n tmp_array="${module}"
  for var in "${!tmp_array[@]}"; do
    tmux set -g "@${module}_${var}" "${tmp_array[$var]}"
  done
done

# Main status line information
# -----------------------------------------------------------------------------
# Set status line style
tmux set -g status-style "fg=${status[fg]},bg=${status[bg]}"
# Set window mode style.
tmux set -g mode-style "fg=${mode[fg]},bg=${mode[bg]}"
# command line style
tmux set -g message-style "fg=${message[fg]},bg=${message[bg]}"
# Set status line message command style. This is used for the command prompt
# with vi(1) keys when in command mode.
tmux set -g message-command-style "fg=${message_command[fg]},bg=${message_command[bg]}"

# Left status
# -----------------------------------------------------------------------------
# Length of the left status bar
tmux set -g status-left-length 200
# Content of the left status bar
tmux set -g status-left "${status[left]}"

# Right status
# -----------------------------------------------------------------------------
# Lengtht of the right status bar
tmux set -g status-right-length 200
# Content of the right status bar
tmux set -g status-right "${status[right]}"

# Global status variables
# =============================================================================
# Window segments separator
tmux set -g window-status-separator ""

# Format of the window list
tmux setw -g window-status-format "#(#{window} 'normal')"
tmux setw -g window-status-current-format "#(#{window} 'current')"

# Set color and style of pane border
tmux set -g pane-border-lines simple
tmux set -g pane-border-indicators off

tmux set -g pane-border-style "fg=${grey_900},bg=${grey_900}"
tmux set -g pane-active-border-style "fg=${window[bg]},bg=${window[bg]}"

pane_active="#[fg=${window["current_fg"]}]#[bg=${window["current_bg"]}]"
pane_active_powerline_left="#[fg=${window[bg]}]#[bg=${window[current_bg]}]"
pane_active_powerline_right="#[fg=${window[current_bg]}]#[bg=${window[bg]}]"

pane_inactive="#[fg=${white}]#[bg=${grey_800}]"
pane_inactive_powerline_left="#[fg=${grey_900}]#[bg=${grey_800}]"
pane_inactive_powerline_right="#[fg=${grey_800}]#[bg=${grey_900}]"

pane_powerline_left="#{?#{pane_active},${pane_active_powerline_left},${pane_inactive_powerline_left}}"
pane_powerline_right="#{?#{pane_active},${pane_active_powerline_right},${pane_inactive_powerline_right}}"
pane="#{?#{pane_active},${pane_active},${pane_inactive}}"

if [[ "$(uname)" == "Darwin" ]]; then
  ps_cmd="#(ps -t #{pane_tty} -o args= | head -n 1)"
else
  ps_cmd="#(ps --no-headers -t #{pane_tty} -o args -O-c | sed -e 's|.*\(nvim\).*|\1|g' -e 's|^-||' -e 's|.*nix-profile\/bin\/||g' )"
fi
tmux set -g pane-border-format "${pane_powerline_left}${pane} #{pane_index}:${ps_cmd} ${pane_powerline_right}"

# Only show pane status if more than one pane
tmux set-hook -g -w pane-focus-in "set-option -Fw pane-border-status '#{?#{e|>:#{window_panes},1},top,off}'"

# Unset loaded variables
unset tmp_array

# SSH toggle nested tmux key binding
# -----------------------------------------------------------------------------
# We want to have single prefix key "prefix", usable both for local and remote session
# we don't want to "prefix" + "a" approach either
# Idea is to turn off all key bindings and prefix handling on local session,
# so that all keystrokes are passed to inner/remote session

# See: toggle on/off all keybindings · Issue #237 · tmux/tmux -
#   https://github.com/tmux/tmux/issues/237

# set status-style 'fg=${status[fg]} strikethrough,bg=${status[bg]}'
# set status-left ''
# set status-right ''
# Also, change some visual styles when window keys are off
tmux bind -T root F12 "
  set prefix None
  set prefix2 None
  set key-table off
  set status-position top
  set status off
  if -F '#{pane_in_mode}' 'send-keys -X cancel'
  refresh-client -S"

tmux bind -T off F12 "
  set -u prefix
  set -u prefix2
  set -u key-table
  set status-position bottom
  set -u status
  refresh-client -S"

tmux set-hook -g client-resized "run '${HOME}/.local/share/tmux/config.sh'"
tmux set-hook -g client-attached "run '${HOME}/.local/share/tmux/config.sh'"

tmux run "${HOME}/.config/tmux/plugins/tmux-sysstat/sysstat.tmux"

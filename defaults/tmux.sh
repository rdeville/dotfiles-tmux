# Global status variables
# =============================================================================
# Set terminal window title
# tmux set-option -g set-titles on
# tmux set-option -g set-titles-string "#S / #I : #W"

# Make Ctrl + Arrow working
# -----------------------------------------------------------------------------
tmux set-window-option -g xterm-keys on
tmux set -g terminal-overrides "xterm*:kLFT5=\eOD:kRIT5=\eOC:kUP5=\eOA:kDN5=\eOB:smkx@:rmkx@"
#tmux set-window-option -g alternate-screen on

# Window list status configuration
# -----------------------------------------------------------------------------
# Window segments separator
tmux set -g window-status-separator ""

# Format of the window list
tmux setw -g window-status-format "#(#{window} 'normal')"
tmux setw -g window-status-current-format "#(#{window} 'current')"

# Set color and style of pane border
tmux set -g pane-border-lines double
tmux set -g pane-border-style "fg=#222222,bg=#222222"
tmux set -g pane-active-border-style "fg=${green_900},bg=${green_900}"
tmux set -g pane-border-indicators off
# Only show pane status if more than one pane
tmux set-hook -g -w pane-focus-in "set-option -Fw pane-border-status '#{?#{e|>:#{window_panes},1},top,off}'"

inactive_pane="#[bg=#111111]#[fg=#FFFFFF]"
active_pane="#[fg=${white}]#[bg=${green_500}]"
test_pane_first_powerline="#{?#{pane_active},#[bg=${green_500}]#[fg=${green_900}],#[fg=#222222]#[bg=#111111]}"
test_pane_last_powerline="#{?#{pane_active},#[bg=${green_900}]#[fg=${green_500}],#[fg=#111111]#[bg=#222222]}"
test_pane="#{?#{pane_active},$active_pane,$inactive_pane}"

if [[ "$(uname)" == "Darwin" ]]
then
  ps_cmd="#(ps -t #{pane_tty} -o args= | head -n 1)"
else
  ps_cmd="#(ps --no-headers -t #{pane_tty} -o args -O-c | sed -e 's|.*\(nvim\).*|\1|g' -e 's|^-||' )"
fi
tmux set -g pane-border-format "${test_pane_first_powerline}${test_pane} #{pane_index} ${ps_cmd} ${test_pane_last_powerline}"

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

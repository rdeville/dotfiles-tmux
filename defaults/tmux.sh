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

# Set color of active and inactive windows/pane
tmux set -g window-style "fg=${grey_500},bg=default"
tmux set -g window-active-style "fg=${grey_100},bg=default"
# Set color and style of pane border
tmux set -g pane-border-lines double
tmux set -g pane-border-style "fg=${grey_500},bg=default"
tmux set -g pane-active-border-style "fg=${green_500},bg=default"
tmux set -g pane-border-indicators off
# Only show pane status if more than one pane
tmux set-hook -g -w pane-focus-in "set-option -Fw pane-border-status '#{?#{e|>:#{window_panes},1},top,off}'"

if [[ "$(uname)" == "Darwin" ]]
then
  tmux set -g pane-border-format " #{pane_index} #(ps -t #{pane_tty} -o args= | head -n 1) "
else
  tmux set -g pane-border-format " #{pane_index} #(ps --no-headers -t #{pane_tty} -o args -o-c) "
fi
tmux set -g pane-border-format " #{pane_index} #(ps -t #{pane_tty} -o args= | tail -1) "

# tmux set-hook -g client-attached 'display-message "hi world"'
# tmux set-hook -g client-attached 'osascript -e "display notification \"hello world!\""'
# tmux set-hook -g after-client-session-changed "osascript -e 'display notification \"hello world!\"'"

# KEY BINDING
# -----------------------------------------------------------------------------
tmux set -g bind-key C-Tab next-window
tmux set -g bind-key C-S-Tab previous-window

# SSH toggle nested tmux key binding
# -----------------------------------------------------------------------------
# We want to have single prefix key "prefix", usable both for local and remote session
# we don't want to "prefix" + "a" approach either
# Idea is to turn off all key bindings and prefix handling on local session,
# so that all keystrokes are passed to inner/remote session

# See: toggle on/off all keybindings · Issue #237 · tmux/tmux -
#   https://github.com/tmux/tmux/issues/237

# Also, change some visual styles when window keys are off
tmux bind -T root F12 "
  set prefix None
  set prefix2 None
  set key-table off
  set status-position top
  set status-style 'fg=${status[fg]} strikethrough,bg=${status[bg]}'
  if -F '#{pane_in_mode}' 'send-keys -X cancel'
  refresh-client -S"

tmux bind -T off F12 "
  set -u prefix
  set -u prefix2
  set -u key-table
  set status-position bottom
  set -u status-style
  refresh-client -S"

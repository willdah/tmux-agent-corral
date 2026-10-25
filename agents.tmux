# tmux-agent-corral: source this from ~/.tmux.conf
#
#   source-file ~/.config/tmux/agents/agents.tmux
#
# Each agent's hooks tag its own pane through agent-state; the panel lists
# every tagged pane in every session, waiting ones first. The status line and
# window tabs are yours: this file only defines the formats to put in them
# (see the README).
#
# Your settings can go before or after the source-file line: each default
# here is set only if it isn't yet (set -goq). An empty value turns a thing
# off.

# The prefix keys for the panel and the docked panel. Unlike the rest, set
# these before the source-file line: they are bound here, once. Empty binds
# none.
# shortcut: ; and ~ can't be bound this way (a separator, a home dir); quote
# them by hand here if anyone wants one. The doctor names a key left unbound.
set -goq @agents_key      a
set -goq @agents_key_dock A
if -F '#{@agents_key}' {
  run -C 'bind -N "Agents panel" #{q:@agents_key} display-popup -B -E -w 90% -h 85% "~/.config/tmux/agents/src/agents"'
}
if -F '#{@agents_key_dock}' {
  run -C 'bind -N "Agents panel, docked (toggle)" #{q:@agents_key_dock} run-shell "~/.config/tmux/agents/src/agents-dock toggle ##{window_id}"'
}

# The docked panel follows you to every window and session. Each window gets
# its own layout back when the panel leaves. Nothing runs while undocked.
set-hook -g session-window-changed[40] 'if -F "#{@agents_dock}" "run-shell \"~/.config/tmux/agents/src/agents-dock follow #{window_id}\""'
set-hook -g client-session-changed[40] 'if -F "#{@agents_dock}" "run-shell \"~/.config/tmux/agents/src/agents-dock follow #{window_id}\""'

# Looking at a finished agent marks it seen: its ✓ dims to idle. Waiting
# agents keep their ▲ until they are actually answered. pane-focus-in needs
# focus events.
set -g focus-events on
set-hook -g pane-focus-in[40] 'if -F "#{==:#{@agent_state},done}" "run-shell -b \"~/.config/tmux/agents/src/agent-state seen #{pane_id}\""'

# The docked panel's title shows whether it has focus; these tell it to look.
set-hook -g pane-focus-in[41]  'if -F "#{@agents_dock}" "run-shell -b \"~/.config/tmux/agents/src/agents --ping\""'
set-hook -g pane-focus-out[40] 'if -F "#{@agents_dock}" "run-shell -b \"~/.config/tmux/agents/src/agents --ping\""'

# State colours (256-colour indexes), shared by the status formats and the
# panel.
set -goq @agent_c_input   214   # ▲ needs you
set -goq @agent_c_running 110   # ● working
set -goq @agent_c_done    108   # ✓ finished, not yet looked at
set -goq @agent_c_text    250   # panel greys: raise to ~236/240 on a light theme
set -goq @agent_c_dim     247

# The panel groups its rows under each tmux session's name when this is on;
# g in the panel toggles it.
set -goq @agents_group off

# Folders whose subfolders the panel's c offers as places to start an agent,
# space-separated (~ works), beside the ones the running agents are in.
set -goq @agents_roots ""

# The panel's own keys move with @agents_panel_key_<action>: approve (y),
# message (m), rename (n), interrupt (x), kill (d), new (c), group (g),
# preview (p), close (q), reload (r), down (j), up (k). Empty unbinds one;
# ↵, esc and the arrows stay.

# What the panel's c offers to start: one @agents_launch_<name> per command,
# typed into the new window's shell; its harness is the first word naming
# one, so a wrapper works (set -g @agents_launch_hr "headroom wrap claude").
# Empty hides one. @agents_launch_default names the one listed first, and
# taken when a script names none; else claude.
set -goq @agents_launch_claude  claude
set -goq @agents_launch_copilot copilot
set -goq @agents_launch_pi      pi
set -goq @agents_launch_default ""

# How to tell you that an agent needs you or finished, when no client is
# looking at its pane: tmux (a message in each client looking elsewhere), os
# (a desktop notification: osascript, or notify-send), off, or a command to
# run with the message as its argument.
set -goq @agents_notify tmux

# Formats for your status line and tabs. Idle agents stay quiet.
#   @agents_status  every agent in every session, waiting first: ▲▲●✓
#   @agent_tab      the marks of one window's panes, with a leading space
set -g @agent_pip     "#{?#{==:#{@agent_state},input},#[fg=colour#{@agent_c_input}]▲,#{?#{==:#{@agent_state},running},#[fg=colour#{@agent_c_running}]●,#{?#{==:#{@agent_state},done},#[fg=colour#{@agent_c_done}]✓,}}}"
set -g @agent_tab     "#{?#{P:#{E:@agent_pip}}, #{P:#{E:@agent_pip}}#[default],}"
set -g @agents_in     "#{S:#{W:#{P:#{?#{==:#{@agent_state},input},▲,}}}}"
set -g @agents_run    "#{S:#{W:#{P:#{?#{==:#{@agent_state},running},●,}}}}"
set -g @agents_done   "#{S:#{W:#{P:#{?#{==:#{@agent_state},done},✓,}}}}"
set -g @agents_status "#[fg=colour#{@agent_c_input},bold]#{E:@agents_in}#[nobold fg=colour#{@agent_c_running}]#{E:@agents_run}#[fg=colour#{@agent_c_done}]#{E:@agents_done}#[default]"

# tmux-agent-corral: source this from ~/.tmux.conf
#
#   source-file ~/.config/tmux/agents/agents.tmux
#
# Each agent's hooks tag its own pane through agent-state; the panel lists
# every tagged pane in every session, waiting ones first. The status line and
# window tabs are yours: this file only defines the formats to put in them
# (see the README).

bind -N "Agents panel"                  a display-popup -B -E -w 90% -h 85% "~/.config/tmux/agents/agents"
bind -N "Agents panel, docked (toggle)" A run-shell "~/.config/tmux/agents/agents-dock toggle '#{window_id}'"

# The docked panel follows you to every window and session. Each window gets
# its own layout back when the panel leaves. Nothing runs while undocked.
set-hook -g session-window-changed[40] 'if -F "#{@agents_dock}" "run-shell \"~/.config/tmux/agents/agents-dock follow #{window_id}\""'
set-hook -g client-session-changed[40] 'if -F "#{@agents_dock}" "run-shell \"~/.config/tmux/agents/agents-dock follow #{window_id}\""'

# Looking at a finished agent marks it seen: its ✓ dims to idle. Waiting
# agents keep their ▲ until they are actually answered. pane-focus-in needs
# focus events.
set -g focus-events on
set-hook -g pane-focus-in[40] 'if -F "#{==:#{@agent_state},done}" "set -p @agent_state idle ; wait-for -S agents"'

# State colours (256-colour indexes), shared by the status formats and the
# panel. Override any of them after sourcing this file.
set -g @agent_c_input   214   # ▲ needs you
set -g @agent_c_running 110   # ● working
set -g @agent_c_done    108   # ✓ finished, not yet looked at
set -g @agent_c_text    250   # panel greys: raise to ~236/240 on a light theme
set -g @agent_c_dim     247

# Formats for your status line and tabs. Idle agents stay quiet.
#   @agents_status  every agent in every session, waiting first: ▲▲●✓
#   @agent_tab      the marks of one window's panes, with a leading space
set -g @agent_pip     "#{?#{==:#{@agent_state},input},#[fg=colour#{@agent_c_input}]▲,#{?#{==:#{@agent_state},running},#[fg=colour#{@agent_c_running}]●,#{?#{==:#{@agent_state},done},#[fg=colour#{@agent_c_done}]✓,}}}"
set -g @agent_tab     "#{?#{P:#{E:@agent_pip}}, #{P:#{E:@agent_pip}}#[default],}"
set -g @agents_in     "#{S:#{W:#{P:#{?#{==:#{@agent_state},input},▲,}}}}"
set -g @agents_run    "#{S:#{W:#{P:#{?#{==:#{@agent_state},running},●,}}}}"
set -g @agents_done   "#{S:#{W:#{P:#{?#{==:#{@agent_state},done},✓,}}}}"
set -g @agents_status "#[fg=colour#{@agent_c_input},bold]#{E:@agents_in}#[nobold fg=colour#{@agent_c_running}]#{E:@agents_run}#[fg=colour#{@agent_c_done}]#{E:@agents_done}#[default]"

#!/usr/bin/env bash
# common.sh: what more than one script needs, sourced, never run. It only
# defines: no options set, nothing run, so any script can source it.
# shellcheck disable=SC2034   # the variables are for the scripts that source this

# Where the install lives; the hooks and key bindings call this path.
AGENTS_HOME="$HOME/.config/tmux/agents"

# The oldest fzf the panel runs on.
FZF_MIN=0.71

# The Claude Code hooks we install: event, matcher (- for every one), state.
CLAUDE_EVENTS='SessionStart     startup|resume|clear                 idle
UserPromptSubmit -                                    running
PostToolUse      -                                    running
Notification     permission_prompt|elicitation_dialog input
Stop             -                                    done
SessionEnd       -                                    clear'

die()  { printf '\033[1;31mfail\033[0m %s\n' "$*" >&2; exit 1; }
ok()   { printf '\033[1;32m ok \033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33mwarn\033[0m %s\n' "$*" >&2; }

# atleast <version> <minimum>
atleast() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

# has_agent <name>: the agent looks installed (its command, or its config dir).
has_agent() { command -v "$1" >/dev/null 2>&1 || [ -d "$HOME/.$1" ]; }

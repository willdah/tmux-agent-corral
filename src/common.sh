#!/usr/bin/env bash
# common.sh: what more than one script needs, sourced, never run. It only
# defines: no options set, nothing run, so any script can source it.
# shellcheck disable=SC2034   # the variables are for the scripts that source this

# Where the install lives; the hooks and key bindings call this path.
AGENTS_HOME="$HOME/.config/tmux/agents"

# The oldest fzf the panel runs on.
FZF_MIN=0.71

# One folder per built-in harness: an adapter.sh, and the hook it installs.
HARNESSES="${BASH_SOURCE[0]%/*}/../harnesses"

die()  { printf '\033[1;31mfail\033[0m %s\n' "$*" >&2; exit 1; }
ok()   { printf '\033[1;32m ok \033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33mwarn\033[0m %s\n' "$*" >&2; }

# atleast <version> <minimum>
atleast() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

# has_agent <name>: the agent looks installed (its command, or its config dir).
has_agent() { command -v "$1" >/dev/null 2>&1 || [ -d "$HOME/.$1" ]; }

# harnesses: the built-in harnesses' names, one per line.
harnesses() {
  local a
  for a in "$HARNESSES"/*/adapter.sh; do a="${a%/adapter.sh}"; printf '%s\n' "${a##*/}"; done
}

# adapter <harness>: sets PROMPT (the flag before a first prompt), INTERRUPT
# (the key that stops a turn), and HOOK and HOOK_LINK (the hook file and where
# it is linked; empty when the folder's install wires it instead). Fails, and
# leaves the defaults, for a harness with no adapter.
adapter() {
  PROMPT=-- INTERRUPT=Escape HOOK='' HOOK_LINK=''
  [ -f "$HARNESSES/$1/adapter.sh" ] || return 1
  # shellcheck source=/dev/null
  . "$HARNESSES/$1/adapter.sh"
}

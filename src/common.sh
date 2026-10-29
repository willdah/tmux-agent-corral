#!/usr/bin/env bash
# common.sh: what more than one script needs, sourced, never run. It only
# defines: no options set, nothing run, so any script can source it.
# shellcheck disable=SC2034   # the variables are for the scripts that source this

# Where the install lives; the hooks and key bindings call this path.
AGENTS_HOME="$HOME/.config/tmux/agents"

# The oldest fzf the panel runs on.
FZF_MIN=0.73

# One folder per built-in harness: an adapter.sh, and the hook it installs.
HARNESSES="${BASH_SOURCE[0]%/*}/../harnesses"

die()  { printf '\033[1;31mfail\033[0m %s\n' "$*" >&2; exit 1; }
ok()   { printf '\033[1;32m ok \033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33mwarn\033[0m %s\n' "$*" >&2; }

# atleast <version> <minimum>
atleast() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

# has_agent <name>: the agent looks installed (its command, or its config dir).
has_agent() { command -v "$1" >/dev/null 2>&1 || [ -d "$HOME/.$1" ]; }

# fzfcolour <var> <colour>: a tmux colour (colourN, #rrggbb, one of the 16
# names, or a bare index) as fzf's --color takes it: an index, or #rrggbb.
# Fails on one it can't place, such as an X11 name or a typo.
fzfcolour() {
  local s="$2" c i=0
  case "$s" in
    colour*|color*) s="${s#colo}"; s="${s#u}"; s="${s#r}" ;;
    '#'*) [[ "$s" =~ ^#[0-9a-fA-F]{6}$ ]] || return 1; printf -v "$1" '%s' "$s"; return 0 ;;
    *[!0-9]*)
      for c in black red green yellow blue magenta cyan white brightblack brightred \
               brightgreen brightyellow brightblue brightmagenta brightcyan brightwhite; do
        [ "$c" = "$s" ] && { printf -v "$1" '%s' "$i"; return 0; }
        i=$(( i + 1 ))
      done
      return 1 ;;
  esac
  case "$s" in ''|*[!0-9]*) return 1 ;; esac
  [ "$s" -le 255 ] || return 1
  printf -v "$1" '%s' "$s"
}

# palette: the panel's colours, from @agent_c_* so the panel and the status
# line can't drift apart; one fzfcolour can't place falls back to its
# default. The panel hands its frames what tmux said in $AGENTS_PAL, so they
# don't ask again. Sets AMBER BLUE GREEN TEXT DIM FAINT to the escapes that turn
# each on (empty under NO_COLOR) and R to the reset, and ac bc gc tc dc fc to
# the same colours for fzf's --color, and bgc to @agent_c_bg's (-1, the
# terminal's own, when unset).
palette() {
  local i n vals defs=(214 110 108 250 247 238) fzs=(ac bc gc tc dc fc) escs=(AMBER BLUE GREEN TEXT DIM FAINT)
  pal="${AGENTS_PAL:-$(tmux display -p '#{@agent_c_input}|#{@agent_c_running}|#{@agent_c_done}|#{@agent_c_text}|#{@agent_c_dim}|#{@agent_c_border}|#{@agent_c_bg}' 2>/dev/null || true)}"
  IFS='|' read -r -a vals <<<"$pal"
  R=$'\033[0m'; [ -z "${NO_COLOR:-}" ] || R=''
  for i in 0 1 2 3 4 5; do
    fzfcolour n "${vals[i]:-}" || n="${defs[i]}"
    printf -v "${fzs[i]}" '%s' "$n"
    if [ -n "${NO_COLOR:-}" ]; then printf -v "${escs[i]}" '%s' ''
    elif [ "${n:0:1}" = '#' ]; then printf -v "${escs[i]}" '\033[38;2;%d;%d;%dm' "0x${n:1:2}" "0x${n:3:2}" "0x${n:5:2}"
    else printf -v "${escs[i]}" '\033[38;5;%sm' "$n"; fi
  done
  fzfcolour bgc "${vals[6]:-}" || bgc=-1
}

# harnesses: the built-in harnesses' names, one per line.
harnesses() {
  local a
  for a in "$HARNESSES"/*/adapter.sh; do a="${a%/adapter.sh}"; printf '%s\n' "${a##*/}"; done
}

# harness_of COMMAND: the built-in harness COMMAND runs: the first of its
# words named after one, so a wrapper's (headroom wrap claude) counts too.
# It stops at the first flag: what follows is the command's own arguments,
# which may name a harness without running it. Prints nothing for none.
harness_of() {
  local w ws
  read -r -a ws <<<"$1"
  for w in ${ws[@]+"${ws[@]}"}; do
    case "$w" in -*) return 0 ;; esac
    w="${w##*/}"
    [ -f "$HARNESSES/$w/adapter.sh" ] && { printf '%s' "$w"; return 0; }
  done
  return 0
}

# runnable COMMAND: its first word is on PATH (~ works).
runnable() { local w; read -r w _ <<<"$1"; command -v "${w/#\~/$HOME}" >/dev/null 2>&1; }

# launch_names: the launch profiles' names (@agents_launch_<name>, less
# @agents_launch_default), one per line.
launch_names() {
  tmux show -g 2>/dev/null | sed -n 's/^@agents_launch_\([^ ]*\) .*/\1/p' | grep -vx default || true
}

# adapter <harness>: sets PROMPT (the flag before a first prompt), INTERRUPT
# (the key that stops a turn), and HOOK and HOOK_LINK (the hook file and where
# it is linked; empty when the folder's install wires it instead), and ICON
# and COLOR (its mark in the panel: one single-width character, on a #rrggbb
# brand colour; either may be empty). Fails, and
# leaves the defaults, for a harness with no adapter.
adapter() {
  PROMPT=-- INTERRUPT=Escape HOOK='' HOOK_LINK='' ICON='' COLOR=''
  [ -f "$HARNESSES/$1/adapter.sh" ] || return 1
  # shellcheck source=/dev/null
  . "$HARNESSES/$1/adapter.sh"
}

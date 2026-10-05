#!/usr/bin/env bash
# install.sh [--remove]
#
# Puts the panel at ~/.config/tmux/agents (a link to this clone, unless it
# already lives there) and wires up whichever agents are installed: Claude
# Code hooks, Copilot CLI hooks, the Pi extension. Idempotent. Your
# ~/.tmux.conf is left to you; the last lines say what to add.
#
#   --remove   take the hooks and links out again
set -euo pipefail

die()  { printf '\033[1;31mfail\033[0m %s\n' "$*" >&2; exit 1; }
ok()   { printf '\033[1;32m ok \033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33mwarn\033[0m %s\n' "$*" >&2; }

here="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$HOME/.config/tmux/agents"
copilot="$HOME/.copilot/hooks/agent-state.json"
pi="$HOME/.pi/agent/extensions/agent-state.ts"

# link <target> <link>: only ever replaces a link, never a real file.
link() {
  [ -e "$2" ] && [ ! -L "$2" ] && die "$2 exists and is not a link; move it aside first"
  mkdir -p "$(dirname "$2")"
  ln -sfn "$1" "$2"
  ok "linked $2"
}
unlink_ours() { [ -L "$1" ] && rm "$1" && ok "removed $1" || true; }

if [ "${1:-}" = --remove ]; then
  [ -f "$HOME/.claude/settings.json" ] && "$here/install-claude-hooks" --remove
  unlink_ours "$copilot"
  unlink_ours "$pi"
  [ "$dest" = "$here" ] || unlink_ours "$dest"
  ok "removed; take the agents.tmux lines out of ~/.tmux.conf"
  exit 0
fi

for c in tmux fzf jq curl; do command -v "$c" >/dev/null 2>&1 || die "$c not found"; done
v="$(fzf --version | cut -d' ' -f1)"
[ "$(printf '0.71\n%s\n' "$v" | sort -V | head -1)" = 0.71 ] || die "fzf $v is too old; the panel needs 0.71+"

[ "$dest" = "$here" ] || link "$here" "$dest"

# Agent configs are touched only for agents that are installed.
if command -v claude >/dev/null 2>&1 || [ -d "$HOME/.claude" ]; then "$here/install-claude-hooks"; fi
if command -v copilot >/dev/null 2>&1 || [ -d "$HOME/.copilot" ]; then link "$dest/copilot-hooks.json" "$copilot"; fi
if command -v pi >/dev/null 2>&1 || [ -d "$HOME/.pi" ]; then link "$dest/pi-agent-state.ts" "$pi"; fi

grep -qs 'agents/agents.tmux' "$HOME/.tmux.conf" "$HOME/.config/tmux/tmux.conf" ||
  warn "add to ~/.tmux.conf:  source-file ~/.config/tmux/agents/agents.tmux  (then the status snippet in the README)"
ok "done; restart running agents so they pick up the hooks"

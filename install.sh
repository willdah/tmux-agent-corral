#!/usr/bin/env bash
# install.sh [--remove] [--no-tmux-conf]
#
#   curl -fsSL https://raw.githubusercontent.com/willdah/tmux-agent-corral/main/install.sh | bash
#
# Puts the panel at ~/.config/tmux/agents (piped in, it clones or updates it
# there; run from a clone, it links that clone), wires up whichever agents are
# installed (Claude Code hooks, Copilot CLI hooks, the Pi extension), adds a
# marked block to your tmux.conf and reloads a running tmux. Idempotent.
#
#   --remove        take the hooks, links and tmux.conf block out again
#   --no-tmux-conf  leave tmux.conf alone; the README says what to add
set -euo pipefail

die()  { printf '\033[1;31mfail\033[0m %s\n' "$*" >&2; exit 1; }
ok()   { printf '\033[1;32m ok \033[0m %s\n' "$*" >&2; }
warn() { printf '\033[1;33mwarn\033[0m %s\n' "$*" >&2; }

repo="https://github.com/willdah/tmux-agent-corral.git"
dest="$HOME/.config/tmux/agents"
copilot="$HOME/.copilot/hooks/agent-state.json"
pi="$HOME/.pi/agent/extensions/agent-state.ts"
begin="# >>> tmux-agent-corral >>>"
end="# <<< tmux-agent-corral <<<"
block="$begin
source-file ~/.config/tmux/agents/agents.tmux
set -ag status-right \"#{E:@agents_status}\"
setw -ag window-status-format         \"#{E:@agent_tab}\"
setw -ag window-status-current-format \"#{E:@agent_tab}\"
$end"

# link <target> <link>: only ever replaces a link, never a real file.
link() {
  [ -e "$2" ] && [ ! -L "$2" ] && die "$2 exists and is not a link; move it aside first"
  mkdir -p "$(dirname "$2")"
  ln -sfn "$1" "$2"
  ok "linked $2"
}
unlink_ours() { [ -L "$1" ] && rm "$1" && ok "removed $1" || true; }

# hint <cmd>: how to install it with the package manager this machine has.
hint() {
  local pm
  for pm in brew apt-get dnf pacman; do
    command -v "$pm" >/dev/null 2>&1 || continue
    case $pm in
      brew)   printf ' (brew install %s)' "$1" ;;
      pacman) printf ' (sudo pacman -S %s)' "$1" ;;
      *)      printf ' (sudo %s install %s)' "$pm" "$1" ;;
    esac
    return
  done
}

# Piped in there is no clone to run from: fetch one, then run its install.sh.
bootstrap() {
  command -v git >/dev/null 2>&1 || die "git not found$(hint git)"
  if [ -d "$dest/.git" ]; then
    git -C "$dest" pull -q --ff-only || die "could not update $dest; update or remove it by hand"
    ok "updated $dest"
  else
    [ -e "$dest" ] && die "$dest exists and is not a clone; move it aside first"
    mkdir -p "$(dirname "$dest")"
    git clone -q "$repo" "$dest"
    ok "cloned into $dest"
  fi
  exec "$dest/install.sh" "$@"
}

# Everything runs from here, so a download cut short runs nothing.
main() {
  local remove=0 edit_conf=1 arg here conf c v tmp
  for arg; do
    case $arg in
      --remove) remove=1 ;;
      --no-tmux-conf) edit_conf=0 ;;
      *) die "unknown option $arg" ;;
    esac
  done

  [ -f "${BASH_SOURCE[0]:-}" ] || bootstrap "$@"
  here="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # tmux reads ~/.tmux.conf, or the XDG one when that is missing.
  conf="$HOME/.tmux.conf"
  [ -f "$conf" ] || [ ! -f "$HOME/.config/tmux/tmux.conf" ] || conf="$HOME/.config/tmux/tmux.conf"

  if [ $remove = 1 ]; then
    [ -f "$HOME/.claude/settings.json" ] && "$here/install-claude-hooks" --remove
    unlink_ours "$copilot"
    unlink_ours "$pi"
    [ "$dest" = "$here" ] || unlink_ours "$dest"
    if [ $edit_conf = 1 ] && grep -qsF "$begin" "$conf"; then
      # Rewritten in place, not replaced, so a symlinked tmux.conf stays a link.
      cp "$conf" "$conf.bak"
      sed "/^$begin\$/,/^$end\$/d" "$conf.bak" >"$conf"
      ok "removed the agents block from $conf (previous copy: $conf.bak)"
    elif grep -qs 'agents/agents.tmux' "$conf"; then
      warn "take the agents.tmux lines out of $conf"
    fi
    ok "removed; restart tmux to drop the panel and marks"
    exit 0
  fi

  for c in tmux fzf jq curl; do command -v "$c" >/dev/null 2>&1 || die "$c not found$(hint "$c")"; done
  v="$(fzf --version | cut -d' ' -f1)"
  [ "$(printf '0.71\n%s\n' "$v" | sort -V | head -1)" = 0.71 ] ||
    die "fzf $v is too old; the panel needs 0.71+ (https://github.com/junegunn/fzf#installation)"

  [ "$dest" = "$here" ] || link "$here" "$dest"

  # Agent configs are touched only for agents that are installed.
  if command -v claude >/dev/null 2>&1 || [ -d "$HOME/.claude" ]; then "$here/install-claude-hooks"; fi
  if command -v copilot >/dev/null 2>&1 || [ -d "$HOME/.copilot" ]; then link "$dest/copilot-hooks.json" "$copilot"; fi
  if command -v pi >/dev/null 2>&1 || [ -d "$HOME/.pi" ]; then link "$dest/pi-agent-state.ts" "$pi"; fi

  if grep -qs 'agents/agents.tmux' "$conf"; then
    ok "$conf already sources agents.tmux"
  elif [ $edit_conf = 0 ]; then
    warn "add to $conf:  source-file ~/.config/tmux/agents/agents.tmux  (then the status snippet in the README)"
  else
    # Appended last, so the -ag formats land after your own status-right.
    if [ -f "$conf" ]; then cp "$conf" "$conf.bak"; fi
    printf '\n%s\n' "$block" >>"$conf"
    ok "added the agents block to $conf"
    # Only the new lines are sourced: re-sourcing the whole file would append
    # every -a option in it a second time.
    if tmux info >/dev/null 2>&1; then
      tmp="$(mktemp)"
      printf '%s\n' "$block" >"$tmp"
      if tmux source-file "$tmp"; then ok "reloaded tmux"; else warn "reload tmux yourself"; fi
      rm -f "$tmp"
    fi
  fi
  ok "done; restart running agents so they pick up the hooks"
}

main "$@"

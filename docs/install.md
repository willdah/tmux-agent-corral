# Install details

[Back to the README](../README.md#install)

## What the installer does

The installer puts the panel at `~/.config/tmux/agents`. Piped in, it clones the repo there; run from a clone, it links that clone. If a dependency is missing, it stops and prints the command to install it. Then it sets up the agents it finds:

- **Claude Code:** merges hooks into `~/.claude/settings.json`. Your other settings are left alone, a copy is kept as `settings.json.bak`, and re-running it doesn't add duplicates.
- **Copilot CLI:** links `~/.copilot/hooks/agent-state.json`.
- **Pi:** links the `~/.pi/agent/extensions/agent-state.ts` extension.

> [!NOTE]
> The `~/.config/tmux/agents` path is fixed: the hooks and key bindings call it.

## The tmux.conf block

Last, it appends this block to `~/.tmux.conf` (or `~/.config/tmux/tmux.conf` if that's the one you use; the previous version is saved as `.bak`) and loads it into a running tmux:

```tmux
# >>> tmux-agent-corral >>>
source-file ~/.config/tmux/agents/agents.tmux
set -ag status-right "#{E:@agents_status}"
setw -ag window-status-format         "#{E:@agent_tab}"
setw -ag window-status-current-format "#{E:@agent_tab}"
# <<< tmux-agent-corral <<<
```

The `-a` appends to whatever you have. If the marks land in the wrong place, put `#{E:@agents_status}` and `#{E:@agent_tab}` where you want them in your own formats.

> [!TIP]
> To manage those lines yourself, pass `--no-tmux-conf` (with curl: `| bash -s -- --no-tmux-conf`). A config that already sources `agents.tmux` is left alone either way.

## Check the setup

```sh
~/.config/tmux/agents/src/doctor
```

It checks the dependencies, each agent's hooks, that tmux has `agents.tmux` loaded and the marks in its status line and tabs, the notifier, and your settings (keys that didn't bind or clash, colours it can't use, launch profiles not on PATH), and names any agent running in tmux that reports nothing. It only reads, and says what to fix.

## Uninstall

```sh
~/.config/tmux/agents/install.sh --remove
```

It takes out the hooks, the links and the tmux.conf block.

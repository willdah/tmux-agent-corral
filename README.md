<div align="center">

# tmux-agent-corral

*"Yeehaw!"* — You, soon

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![tmux 3.3+](https://img.shields.io/badge/tmux-3.3%2B-1bb91f.svg)](https://github.com/tmux/tmux)
[![Shell](https://img.shields.io/badge/shell-bash-4eaa25.svg)](#requirements)

[Features](#features) • [Install](#install) • [Use](#use) • [Docs](#docs)

</div>

<p align="center"><img src="https://github.com/user-attachments/assets/1d57de7b-82fb-42ba-82bd-aea325a0d68e" alt="An agent in another tmux session stops on a permission prompt; the panel, grouped by session, approves it and jumps to a finished agent, then docks and follows across windows and sessions" width="880"></p>

Claude Code, Copilot CLI and Pi sessions, in any tmux session, window or pane, report their state to tmux. You see at a glance which agent needs you, which are working, and which have finished, then jump to it, approve it, message it or interrupt it from one panel.

## Features

- **Status line:** one mark per agent across all sessions, waiting first. `▲` (amber) needs you, `●` (blue) working, `✓` (green) finished and not yet looked at.
- **Window tabs:** each tab carries the marks of its own panes, so the window to go to is the one with the `▲`.
- **The panel:** every agent in one list, waiting ones first with the longest wait on top, and a live view of the selected pane. Open it as a popup, or dock it as a pane that follows you to every window.
- **Any harness:** the protocol is one script, so agents beyond the built-in three can join with a single hook line.

## Requirements

- tmux 3.3+ (tested on 3.7)
- [fzf](https://github.com/junegunn/fzf) 0.71+
- bash, git, jq, curl
- At least one of: [Claude Code](https://claude.com/claude-code), [Copilot CLI](https://github.com/github/copilot-cli), [Pi](https://www.npmjs.com/package/@earendil-works/pi-coding-agent). Any other harness can join; see [Scripting and other agents](docs/scripting.md).

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/willdah/tmux-agent-corral/main/install.sh | bash
```

Or from a clone:

```sh
git clone https://github.com/willdah/tmux-agent-corral.git && tmux-agent-corral/install.sh
```

Run the same command again to update.

> [!IMPORTANT]
> Restart any agents that are already running so they pick up the hooks.

The installer sets up the hooks for each agent it finds and adds a block to your tmux.conf. Pass `--no-tmux-conf` to add it yourself. [Install details](docs/install.md) shows the block and lists every file the installer touches.

Check the setup with `~/.config/tmux/agents/src/doctor`. Remove everything with `~/.config/tmux/agents/install.sh --remove`.

## Use

| Key | Action |
|-----|--------|
| `prefix + a` | agents panel as a popup; `↵` jumps to the agent and closes |
| `prefix + A` | toggle the docked panel: a full-height pane on the left that follows you to every window and session and keeps focus; `↵` shows the agent, the cursor stays in the panel |

`@agents_key` and `@agents_key_dock` change these two; see the [FAQ](docs/faq.md).

Inside the panel:

| Key | Action |
|-----|--------|
| `↵` | jump to the agent (the popup closes; the docked panel keeps focus) |
| `y` | approve: sends Enter, and only to an agent that is waiting |
| `m` | type a message to it, right in the panel (↵ sends, esc cancels) |
| `n` | give it a name, starting from the one it shows (empty resets to the agent's own title) |
| `x` | interrupt: sends Escape (C-c to Copilot), and only to an agent that is working |
| `d` | kill its pane, once you confirm with ↵ (esc cancels); the last pane takes its window, the last window its session |
| `c` | start a new agent in a window of its own: pick a folder, a worktree if it's a git repo, the session to add it to, the agent, and a first prompt or none (see [Start a new agent](docs/new-agents.md)); not in the docked panel's key hints, but works there |
| `g` | group by tmux session (the session with the most urgent agent first, each heading counting its agents by state); not in the docked panel's key hints, but works there |
| `p` | toggle the live preview |
| `r` | refresh |
| `j` / `k` | move down / up |
| `q` / `Esc` | close |

To move one of the letter keys, name its action: `set -g @agents_panel_key_interrupt X` (the actions are `approve`, `message`, `rename`, `interrupt`, `kill`, `new`, `group`, `preview`, `close`, `reload`, `down` and `up`). The footer follows. An empty value unbinds one. `↵`, `Esc` and the arrows stay as they are.

The panel refreshes the moment an agent changes state, and every 10 seconds to keep the ages current. Visiting a finished agent's pane turns its `✓` into a quiet idle `○`. A `▲` stays until the agent gets its answer.

The docked panel moves into whichever window you switch to. Each window's layout is saved when the panel arrives and restored when it leaves, so your layouts never drift. It stays put in a zoomed window, or one narrower than 128 columns, and catches up on the next switch.

## Docs

| Page | What's in it |
|---|---|
| [Install details](docs/install.md) | What the installer changes, the tmux.conf block, `doctor`, uninstall |
| [Start a new agent](docs/new-agents.md) | The five steps `c` asks, and where worktrees go |
| [Configuration](docs/configuration.md) | Colours, folders for `c`, grouping, notifications, launch profiles, tmux hooks |
| [Scripting and other agents](docs/scripting.md) | The `agent-state` protocol, `wait`, `prompt`, `agents-new`, `agents --rows` |
| [Known limits](docs/known-limits.md) | What the hooks can't see |
| [FAQ](docs/faq.md) | Missing agents, stuck marks, SSH, rebinding the keys |
| [Development](docs/development.md) | Smoke test and re-recording the demo GIF |

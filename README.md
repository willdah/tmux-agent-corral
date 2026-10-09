<div align="center">

# tmux-agent-corral

*"Yeehaw!"* — You, soon

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![tmux 3.3+](https://img.shields.io/badge/tmux-3.3%2B-1bb91f.svg)](https://github.com/tmux/tmux)
[![Shell](https://img.shields.io/badge/shell-bash-4eaa25.svg)](#requirements)

[Features](#features) • [Install](#install) • [Use](#use) • [Configure](#configure) • [Other agents](#other-agents) • [FAQ](#faq)

</div>

<!-- TODO: screenshot / GIF -->

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
- At least one of: [Claude Code](https://claude.com/claude-code), [Copilot CLI](https://github.com/github/copilot-cli), [Pi](https://www.npmjs.com/package/@earendil-works/pi-coding-agent). Any other harness can join; see [Other agents](#other-agents).

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

### What the installer does

The installer puts the panel at `~/.config/tmux/agents`. Piped in, it clones the repo there; run from a clone, it links that clone. If a dependency is missing, it stops and prints the command to install it. Then it sets up the agents it finds:

- **Claude Code:** merges hooks into `~/.claude/settings.json`. Your other settings are left alone, a copy is kept as `settings.json.bak`, and re-running it doesn't add duplicates.
- **Copilot CLI:** links `~/.copilot/hooks/agent-state.json`.
- **Pi:** links the `~/.pi/agent/extensions/agent-state.ts` extension.

> [!NOTE]
> The `~/.config/tmux/agents` path is fixed: the hooks and key bindings call it.

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

### Uninstall

```sh
~/.config/tmux/agents/install.sh --remove
```

It takes out the hooks, the links and the tmux.conf block.

## Use

| Key | Action |
|-----|--------|
| `prefix + a` | agents panel as a popup; `↵` jumps to the agent and closes |
| `prefix + A` | toggle the docked panel: a full-height pane on the left that follows you to every window and session and keeps focus; `↵` shows the agent, the cursor stays in the panel |

Inside the panel:

| Key | Action |
|-----|--------|
| `↵` | jump to the agent (the popup closes; the docked panel keeps focus) |
| `y` | approve: sends Enter, and only to an agent that is waiting |
| `m` | type a message to it, right in the panel (↵ sends, esc cancels) |
| `n` | give it a name, starting from the one it shows (empty resets to the agent's own title) |
| `x` | interrupt: sends Escape (C-c to Copilot), and only to an agent that is working |
| `g` | group by tmux session (sessions in name order); not in the docked panel's key hints, but works there |
| `p` | toggle the live preview |
| `r` | refresh |
| `j` / `k` | move down / up |
| `q` / `Esc` | close |

The panel refreshes the moment an agent changes state, and every 10 seconds to keep the ages current. Visiting a finished agent's pane turns its `✓` into a quiet idle `○`. A `▲` stays until the agent gets its answer.

The docked panel moves into whichever window you switch to. Each window's layout is saved when the panel arrives and restored when it leaves, so your layouts never drift. It stays put in a zoomed window, or one narrower than 128 columns, and catches up on the next switch.

## Configure

Set any of these after the `source-file` line. Values are 256-colour indexes.

| Option | Default | Colours |
|---|---|---|
| `@agent_c_input` | `214` | `▲` needs you |
| `@agent_c_running` | `110` | `●` working |
| `@agent_c_done` | `108` | `✓` finished |
| `@agent_c_text`, `@agent_c_dim` | `250`, `247` | panel text; use about `236`/`240` on a light theme |

`set -g @agents_group on` starts the panel grouped by tmux session (`g` toggles it).

`@agents_notify` says how you hear that an agent needs you or finished while no client is looking at its pane: `tmux` (default: a message in every client looking elsewhere), `os` (a desktop notification, through `osascript` or `notify-send`), `off`, or a command of your own, run with the message (`▲ Fix login needs you`) as its one argument.

`NO_COLOR=1` turns the panel's colours off.

The hooks are registered at index `[40]` (`session-window-changed`, `client-session-changed`, `pane-focus-in`), so they sit alongside your own. `agents.tmux` also turns on `focus-events`.

## Other agents

The protocol is one script. `agent-state <input|running|done|idle|clear> [name]` tags the pane it runs in (`$TMUX_PANE`) with `@agent_state`, `@agent_since` and `@agent`. The state lives in pane options, so it disappears with the pane. Call it from any harness's hooks or a wrapper:

```sh
~/.config/tmux/agents/agent-state running codex
```

`copilot-hooks.json`, `pi-agent-state.ts` and `install-claude-hooks` show how the built-in ones do it.

### Scripting

Two more verbs drive agents from a script, a hook, or another agent:

```sh
agent-state wait PANE [STATE...] [--timeout SECONDS]   # block until PANE is in one of the states (default: input done)
agent-state prompt PANE TEXT                           # type TEXT into the agent in PANE and press Enter
```

`wait` exits 0 when the state is reached (`clear` means the agent has ended), 1 on the timeout, when the pane is gone, or when the agent ends first. `prompt` exits 1 when `PANE` is not an agent or is waiting on you, so a prompt never lands in a permission dialog; answer it first (`y` in the panel, or `tmux send-keys -t PANE Enter`). It marks the agent working as it sends, so a `wait` right after it waits for the new turn, not the last one. Together they hand work to a peer and wait for it:

```sh
agent-state prompt %7 "run the tests and fix what breaks" && agent-state wait %7
```

Pane ids are the first column of `agents --list`.

## Known limits

> [!WARNING]
> - Interrupting Claude with Escape fires no hook, so the pane keeps showing `●` until your next prompt.
> - Pi has no permission prompts of its own, so its `▲` only shows while an extension asks you something.
> - With two terminals attached, the docked panel follows whichever one switched windows last.

## FAQ

<details>
<summary><b>An agent isn't showing up.</b></summary>

Agents that were already running when you installed need a restart to pick up the hooks. The agent also has to run inside a tmux pane: `agent-state` reads `$TMUX_PANE`, and without it the script does nothing.

</details>

<details>
<summary><b>Can a broken hook break my agent?</b></summary>

No. `agent-state` always exits 0 and swallows its own errors, so the worst that can happen is a missing mark.

</details>

<details>
<summary><b>A pane is stuck on <code>●</code> (or anything else).</b></summary>

Usually that's an Escape interrupt in Claude (see [Known limits](#known-limits)); your next prompt fixes it. To clear it by hand, run `~/.config/tmux/agents/agent-state clear` in that pane. Closing the pane also clears it, because the state lives in the pane.

</details>

<details>
<summary><b>Does it work over SSH?</b></summary>

It works when tmux runs on the same machine as the agent. If you SSH out of a tmux pane and start an agent on the remote box, the remote shell has no `$TMUX_PANE` and nothing gets tracked. Run tmux on the remote side instead.

</details>

<details>
<summary><b>Is something running in the background all the time?</b></summary>

No. The status line and tabs are plain tmux formats that read pane options. The panel refreshes only while it's open (on each state change, and every 10 seconds), and the dock hooks do nothing while it's undocked.

</details>

<details>
<summary><b>Why does it need curl? Does it phone home?</b></summary>

No. curl only talks to fzf on `localhost` to refresh the open panel. Nothing leaves your machine.

</details>

<details>
<summary><b>What does <code>y</code> actually approve?</b></summary>

It sends one Enter, so you get whatever option the agent's prompt has highlighted. It only does that when the agent is waiting (`▲`), so a stray `y` can't submit a half-typed prompt to a working agent.

</details>

<details>
<summary><b>I already use <code>prefix + a</code> / <code>prefix + A</code>.</b></summary>

Rebind them after the `source-file` line:

```tmux
unbind a
unbind A
bind g display-popup -B -E -w 90% -h 85% "~/.config/tmux/agents/agents"
bind G run-shell "~/.config/tmux/agents/agents-dock toggle '#{window_id}'"
```

</details>

<details>
<summary><b>Was this built by AI?</b></summary>

Yes it was, but this response was artisanally crafted by a human with soft hands.

</details>

<details>
<summary><b>Is it coral, corral, or Carl?</b></summary>

It's corral, like the _golden_ one. Not like the reef or Rick Grimes shouting at his son during a zombie apocalypse.

</details>

## Development

```sh
./smoke-test   # runs everything on a throwaway tmux server; prints ok
```

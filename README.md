# tmux-agent-corral

Keep track of every coding agent you have running in tmux. Claude Code, Copilot CLI and Pi sessions, in any session, window or pane, report their state to tmux, so you can see which one is waiting on you without going looking:

- **Status line:** one mark per agent across all sessions, waiting first. `▲` (amber) needs you, `●` (blue) working, `✓` (green) finished and not yet looked at.
- **Window tabs:** each tab carries the marks of its own panes, so the window to go to is the one with the `▲`.
- **The panel:** every agent in one list, waiting ones first with the longest wait on top, and a live view of the selected pane. From the panel you can jump to an agent, approve it, message it or interrupt it.

<!-- TODO: screenshot / GIF -->

## Requirements

- tmux 3.3+ (tested on 3.7)
- [fzf](https://github.com/junegunn/fzf) 0.71+
- bash, jq, curl
- At least one of: [Claude Code](https://claude.com/claude-code), [Copilot CLI](https://github.com/github/copilot-cli), [Pi](https://www.npmjs.com/package/@earendil-works/pi-coding-agent). Any other harness can join; see [Other agents](#other-agents).

## Install

```sh
git clone https://github.com/willdah/tmux-agent-corral.git
cd tmux-agent-corral && ./install.sh
```

`install.sh` links the clone to `~/.config/tmux/agents` (that path is fixed: the hooks and key bindings call it). It also sets up the agents it finds:

- **Claude Code:** merges hooks into `~/.claude/settings.json`. Your other settings are left alone, a copy is kept as `settings.json.bak`, and re-running it doesn't add duplicates.
- **Copilot CLI:** links `~/.copilot/hooks/agent-state.json`.
- **Pi:** links the `~/.pi/agent/extensions/agent-state.ts` extension.

Then add the panel to `~/.tmux.conf`, put the marks in your status line and tabs, and reload with `tmux source ~/.tmux.conf`:

```tmux
source-file ~/.config/tmux/agents/agents.tmux

set -ag status-right "#{E:@agents_status}"
setw -ag window-status-format         "#{E:@agent_tab}"
setw -ag window-status-current-format "#{E:@agent_tab}"
```

The `-a` appends to whatever you have. If the marks land in the wrong place, put `#{E:@agents_status}` and `#{E:@agent_tab}` where you want them in your own formats instead. Restart any agents that are already running so they pick up the hooks.

To uninstall, run `./install.sh --remove` and delete those lines.

## Use

| Key | Action |
|-----|--------|
| `prefix + a` | agents panel as a popup; `↵` jumps to the agent and closes |
| `prefix + A` | toggle the docked panel: a full-height pane on the left that follows you to every window and session; `↵` jumps, the panel stays |

Inside the panel:

| Key | Action |
|-----|--------|
| `↵` | jump to the agent |
| `y` | approve: sends Enter, and only to an agent that is waiting |
| `m` | type a message to it |
| `n` | give it a name (empty resets to the agent's own title) |
| `x` | interrupt: sends Escape, and only to an agent that is working |
| `p` | toggle the live preview |
| `r` / `j` / `k` / `q` | refresh / move / close |

The panel refreshes itself every 2 seconds. Visiting a finished agent's pane turns its `✓` into a quiet idle `○`. A `▲` stays until the agent gets its answer.

The docked panel moves into whichever window you switch to. Each window's layout is saved when the panel arrives and restored when it leaves, so your layouts never drift. It stays put in a zoomed window, or one narrower than 128 columns, and catches up on the next switch.

## Configure

Set any of these after the `source-file` line. Values are 256-colour indexes.

| Option | Default | |
|---|---|---|
| `@agent_c_input` | `214` | `▲` needs you |
| `@agent_c_running` | `110` | `●` working |
| `@agent_c_done` | `108` | `✓` finished |
| `@agent_c_text`, `@agent_c_dim` | `250`, `247` | panel text; use about `236`/`240` on a light theme |

`NO_COLOR=1` turns the panel's colours off. The hooks are registered at index `[40]` (`session-window-changed`, `client-session-changed`, `pane-focus-in`), so they sit alongside your own. `agents.tmux` also turns on `focus-events`.

## Other agents

The protocol is one script. `agent-state <input|running|done|idle|clear> [name]` tags the pane it runs in (`$TMUX_PANE`) with `@agent_state`, `@agent_since` and `@agent`. The state lives in pane options, so it disappears with the pane. Call it from any harness's hooks or a wrapper:

```sh
~/.config/tmux/agents/agent-state running codex
```

`copilot-hooks.json`, `pi-agent-state.ts` and `install-claude-hooks` show how the built-in ones do it.

## Known limits

- Interrupting Claude with Escape fires no hook, so the pane keeps showing `●` until your next prompt.
- Pi has no permission prompts of its own, so its `▲` only shows while an extension asks you something.
- With two terminals attached, the docked panel follows whichever one switched windows last.

## FAQ

**Was this built by AI?**

Yes it was, but this response was artisanally crafted by a human with soft hands.

**Is it coral, corral, or Carl?**

It's corral, like the _golden_ one. Not like the reef or Rick Grimes shouting at his son during a zombie apocalypse.

**An agent isn't showing up.**
Agents that were already running when you installed need a restart to pick up the hooks. The agent also has to run inside a tmux pane: `agent-state` reads `$TMUX_PANE`, and without it the script does nothing.

**Can a broken hook break my agent?**
No. `agent-state` always exits 0 and swallows its own errors, so the worst that can happen is a missing mark.

**A pane is stuck on `●` (or anything else).**
Usually that's an Escape interrupt in Claude (see [Known limits](#known-limits)); your next prompt fixes it. To clear it by hand, run `~/.config/tmux/agents/agent-state clear` in that pane. Closing the pane also clears it, because the state lives in the pane.

**Does it work over SSH?**
It works when tmux runs on the same machine as the agent. If you SSH out of a tmux pane and start an agent on the remote box, the remote shell has no `$TMUX_PANE` and nothing gets tracked. Run tmux on the remote side instead.

**Is something running in the background all the time?**
No. The status line and tabs are plain tmux formats that read pane options. The panel refreshes every 2 seconds only while it's open, and the dock hooks do nothing while it's undocked.

**Why does it need curl? Does it phone home?**
No. curl only talks to fzf on `localhost` to refresh the open panel. Nothing leaves your machine.

**What does `y` actually approve?**
It sends one Enter, so you get whatever option the agent's prompt has highlighted. It only does that when the agent is waiting (`▲`), so a stray `y` can't submit a half-typed prompt to a working agent.

**I already use `prefix + a` / `prefix + A`.**
Rebind them after the `source-file` line:

```tmux
unbind a
bind g display-popup -B -E -w 90% -h 85% "~/.config/tmux/agents/agents"
```

## Test

```sh
./smoke-test   # runs everything on a throwaway tmux server; prints ok
```

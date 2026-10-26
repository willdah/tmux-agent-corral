# Configuration

[Back to the README](../README.md#docs)

Set any of these in your tmux.conf, before or after the `source-file` line: `agents.tmux` only fills in what you haven't set.

## Colours

A colour is `colourN` (0 to 255), `#rrggbb`, or one of the 16 names (`red`, `brightred`, …). A bare index from before 0.15.0 (`214`) gets its `colour` prefix when it's set before the `source-file` line; after it, write `colour214`.

| Option | Default | Colours |
|---|---|---|
| `@agent_c_input` | `colour214` | `▲` needs you |
| `@agent_c_running` | `colour110` | `●` working |
| `@agent_c_done` | `colour108` | `✓` finished |
| `@agent_c_text`, `@agent_c_dim` | `colour250`, `colour247` | panel text; use about `colour236`/`colour240` on a light theme |
| `@agent_c_border` | `colour238` | the panel's borders and group rules |
| `@agent_c_bg` | the terminal's | the panel's background |

`NO_COLOR=1` turns the panel's colours off.

## Panel

`set -g @agents_roots "~/Projects ~/work"` lists those folders' subfolders as places to [start an agent](new-agents.md) with `c`.

`set -g @agents_group on` starts the panel grouped by tmux session (`g` toggles it).

## Notifications

`@agents_notify` says how you hear that an agent needs you or finished while no client is looking at its pane:

- `tmux` (default): a message in every client looking elsewhere
- `os`: a desktop notification, through `osascript` or `notify-send`
- `off`
- a command of your own, run with the message (`▲ Fix login needs you`) as its one argument

## Launch profiles

What `c` offers to start is a list of profiles, one option each: `@agents_launch_<name>` holds a command, typed into the new window's shell as you'd type it. `claude`, `copilot` and `pi` are there by default; add your own, wrappers included:

```tmux
set -g @agents_launch_yolo    "claude --dangerously-skip-permissions"
set -g @agents_launch_hr      "headroom wrap claude"
set -g @agents_launch_default hr   # listed first, and what agents-new takes without --agent
set -g @agents_launch_pi      ""   # empty hides one
```

A profile's harness is the first word of its command, before any flag, that names one (`headroom wrap claude` is Claude; so is `claude --model opus`, whose flags and arguments never count), which decides how its first prompt is passed (`-i` for Copilot, else `--`). A command of no known harness still starts, with `-- PROMPT` after it. The list shows only profiles whose first word is on PATH, the default first, then the rest of its harness's, then the other harnesses', then those of none. Without `@agents_launch_default`, `claude` leads.

## tmux hooks

The hooks are registered at index `[40]` (`session-window-changed`, `client-session-changed`, `pane-focus-in`), so they sit alongside your own. `agents.tmux` also turns on `focus-events`.

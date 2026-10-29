# Scripting and other agents

[Back to the README](../README.md#docs)

## The protocol

The protocol is one script. `agent-state <input|running|done|idle|clear> [harness]` tags the pane it runs in (`$TMUX_PANE`) with `@agent_state`, `@agent_since` and `@agent`. The state lives in pane options, so it disappears with the pane. Call it from any harness's hooks or a wrapper:

```sh
~/.config/tmux/agents/src/agent-state running codex
```

The built-in ones live in `harnesses/<name>/`: an `adapter.sh` that says how to pass a first prompt, which key interrupts it and how the panel marks it (`ICON`, one single-width character, on `COLOR`, a `#rrggbb` brand colour; without them the panel shows the name's first letter, dimmed), next to the hook it installs (`copilot/hooks.json`, `pi/extension.ts`, and `claude/install`, which merges Claude's into `settings.json`). A new folder there is a new built-in harness.

## Wait for an agent and prompt it

Two more verbs drive agents from a script, a hook, or another agent:

```sh
agent-state wait PANE [STATE...] [--timeout SECONDS]   # block until PANE is in one of the states (default: input done)
agent-state prompt PANE TEXT                           # type TEXT into the agent in PANE and press Enter
```

`wait` exits 0 when the state is reached (`clear` means the agent has ended), 1 on the timeout, when the pane is gone, or when the agent ends first. `prompt` exits 1 when `PANE` is not an agent or is waiting on you, so a prompt never lands in a permission dialog; answer it first (`y` in the panel, or `tmux send-keys -t PANE Enter`). It marks the agent working as it sends, so a `wait` right after it waits for the new turn, not the last one. Together they hand work to a peer and wait for it:

```sh
agent-state prompt %7 "run the tests and fix what breaks" && agent-state wait %7
```

## Start an agent

`agents-new` starts one without asking, and prints its pane, so a script can start a peer and hand it work:

```sh
agents-new --dir DIR [--branch BRANCH] [--session SESSION] [--agent AGENT] [--prompt TEXT]
p=$(agents-new --dir ~/src/app --branch fix/flaky --agent claude --prompt "find and fix the flaky test") && agent-state wait "$p"
```

`--branch` makes or reuses a worktree as [`c`](new-agents.md) does. `--session` adds the window to that session, making it if there is none, or `--session new` gives it a session of its own; without it the window joins the caller's session (outside tmux, a new one). `AGENT` names a launch profile, else is a command of its own (`--agent "claude --model opus"`); without it, the default profile. It's typed into the session's shell with the prompt as its last argument (Copilot's with `-i`). `agents-new --profiles` lists the profiles `c` offers, in its order: name, harness, command, tab-separated.

## Find a pane

`agents --rows` prints one tab-separated record per agent in the panel's order: rank (0 needs you, 1 finished, 2 idle, 3 working), since (epoch), pane id, state, harness, project, name, session. With grouping on, a heading record leads each session: rank `H`, its counts by rank in the state field, `-<session>` as the id.

```sh
agents --rows | awk -F'\t' '$4 == "input" { print $3 }'   # every pane waiting on you
```

## Housekeeping

`agent-state seen PANE` dims a finished agent to idle (the focus hook and the panel's jump call it), and `agent-state sweep` clears every pane whose agent died without saying so (the panel runs it on open and every 10s).

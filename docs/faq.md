# FAQ

[Back to the README](../README.md#docs)

<details>
<summary><b>An agent isn't showing up.</b></summary>

Run `~/.config/tmux/agents/src/doctor`: it names agents that run but report nothing, and hooks that are missing. Agents that were already running when you installed need a restart to pick up the hooks. The agent also has to run inside a tmux pane: `agent-state` reads `$TMUX_PANE`, and without it the script does nothing.

</details>

<details>
<summary><b>Can a broken hook break my agent?</b></summary>

No. `agent-state` always exits 0 and swallows its own errors, so the worst that can happen is a missing mark.

</details>

<details>
<summary><b>A pane is stuck on <code>●</code> (or anything else).</b></summary>

Usually that's an Escape typed into Claude's pane (see [Known limits](known-limits.md)); your next prompt fixes it, and interrupting with `x` from the panel avoids it. To clear it by hand, run `~/.config/tmux/agents/src/agent-state clear` in that pane. Closing the pane also clears it, because the state lives in the pane.

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

Pick others **before** the `source-file` line (the keys are bound as it's read); an empty one binds nothing:

```tmux
set -g @agents_key      g
set -g @agents_key_dock G
source-file ~/.config/tmux/agents/agents.tmux
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

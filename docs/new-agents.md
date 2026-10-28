# Start a new agent

[Back to the README](../README.md#use)

`c` in the panel asks five things, one at a time:

1. **Where:** the folders your running agents work in (a repo by its main checkout), the subfolders of each folder in [`@agents_roots`](configuration.md), or a path you type, starting with `/`, `~` or `.`. As you type one, the list shows the folders in it (hidden ones once you type a `.`); `tab` goes into the chosen folder, and ↵ takes it. It doesn't have to be a repo.
2. **Worktree**, in a git repo only: the checkout itself (marked `(the checkout)`), one of its worktrees, or `+ new worktree`, which asks for a branch name. The new worktree goes at `<repo>-worktrees/<branch>` (with `/` as `-`), on a new branch made from origin's default branch (or `HEAD` without one), or on that branch if it exists. A worktree has only tracked files, so install dependencies there before building.
3. **Session:** the tmux session to add the agent's window to: the one you're in (first), any other, or `+ new session`.
4. **Agent:** a launch profile (see [Launch profiles](configuration.md#launch-profiles)) whose command is on PATH, by name, harness and command, the default first; skipped when there's only one.
5. **Prompt:** a first prompt to start it on, or ↵ to start it without one.

The agent starts in a new window named after its folder (a new session is named after it too), and you land on it (the docked panel follows). `esc` at any step goes back to the panel.

To do the same from a script, without the questions, see [`agents-new`](scripting.md#start-an-agent).

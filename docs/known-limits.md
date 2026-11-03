# Known limits

[Back to the README](../README.md#docs)

- Interrupting Claude with Escape in its own pane fires no hook, so the pane shows `●` until a panel notices its screen has stood still: within about 30s while a panel (popup or dock) is open, else once one opens. `x` in the panel marks it idle as it interrupts.
- Pi has no permission prompts of its own, so its `▲` only shows while an extension asks you something.
- With two terminals attached, the docked panel follows whichever one switched windows last.

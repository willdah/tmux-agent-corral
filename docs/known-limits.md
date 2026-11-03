# Known limits

[Back to the README](../README.md#docs)

- Interrupting Claude with Escape in its own pane fires no hook, so the pane shows `●` until a panel (popup or dock) has seen its screen stand still for about 30s. `s` in the panel marks it idle as it interrupts.
- Pi has no permission prompts of its own, so its `▲` only shows while an extension asks you something.
- With two terminals attached, the docked panel follows whichever one switched windows last.

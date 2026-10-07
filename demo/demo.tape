# The README GIF: `vhs demo/demo.tape` from the repo root writes demo/demo.gif
# (gitignored; the README links an uploaded copy). demo/setup stages the scene.
Output demo/demo.gif

Require tmux
Require fzf

Set Shell bash
Set FontSize 16
Set Width 1500
Set Height 900   # 140+ columns: the dock follows only where it fits
Set Padding 16
Set Theme "Catppuccin Mocha"
Set TypingSpeed 80ms

Hide
Type "demo/setup" Enter
Sleep 2.5s
Show

# Working in web; billing's agent in api stops on a permission prompt.
Sleep 4.5s

# The panel, grouped by session: select the waiting agent and approve it.
Ctrl+B
Type "a"
Sleep 1.5s
Type "j"
Sleep 2s
Type "y"
Sleep 2.5s

# Up to the finished one, and jump to it.
Type "k"
Sleep 1.5s
Enter
Sleep 3s

# Dock the panel: it keeps focus, and follows ↵ to another window, then
# to another session.
Ctrl+B
Type "A"
Sleep 2.5s
Type "jj"
Sleep 1s
Enter
Sleep 3s
Type "jjjj"
Sleep 1s
Enter
Sleep 4s

Hide
Ctrl+B
Type "d"
Sleep 1s

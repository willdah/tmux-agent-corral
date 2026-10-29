# shellcheck shell=bash disable=SC2034   # read by common.sh's adapter
# GitHub Copilot CLI.
PROMPT=-i         # its first prompt goes after -i
INTERRUPT=C-c     # it ignores Escape
HOOK=hooks.json   # linked to HOOK_LINK
HOOK_LINK="$HOME/.copilot/hooks/agent-state.json"
ICON=c
COLOR='#8534F3'

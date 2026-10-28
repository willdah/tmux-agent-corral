# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

New entries are written by the release workflow from the conventional commit
messages and PR titles merged since the previous release.

## [0.19.0](https://github.com/willdah/tmux-agent-corral/compare/0.18.0...0.19.0) - 2026-10-28

### Added

- the where step lists the folders in a path as you type it

### Fixed

- a state change shows even while an agent is working
- keys work while an agent is working
- ~ shows as ~, not \~, under bash 3.2

## [0.18.0](https://github.com/willdah/tmux-agent-corral/compare/0.17.0...0.18.0) - 2026-10-28

### Added

- a three-dot wave for working agents, and a still working bar
- the title's shine moves four letters a frame
- the title turns gold only on the shine's last pass
- the title's shine goes right, back left, and right again
- the title's gold shine sweeps three letters a frame
- sage replaces navy at the tail of the title's sweep
- the title sweeps mist to navy and settles sky
- the title sweeps cream to coral and settles apricot
- the title sweeps mauveine to pumpkin and settles orange peel
- a gold shine sweeps the title on focus, leaving corral gold
- idle agents show zᶻ

### Changed

- **Breaking:** mission control layout with live animation
- **Breaking:** fzf 0.73 or newer is required, for every(). --list no

### Fixed

- the title stays dim behind the shine until its last pass
- working rows hold still while you move through the list

## [0.17.0](https://github.com/willdah/tmux-agent-corral/compare/0.16.1...0.17.0) - 2026-10-26

### Added

- show only the state symbol in the State column

## [0.16.1](https://github.com/willdah/tmux-agent-corral/compare/0.16.0...0.16.1) - 2026-10-26

### Fixed

- keep the panel's resized width when it follows you

## [0.16.0](https://github.com/willdah/tmux-agent-corral/compare/0.15.0...0.16.0) - 2026-10-26

### Added

- @agent_c_bg sets the panel's background

## [0.15.0](https://github.com/willdah/tmux-agent-corral/compare/0.14.0...0.15.0) - 2026-10-25

### Added

- column headings on the agent step
- check the settings
- move the panel's keys with @agents_panel_key_<action>
- choose the prefix keys with @agents_key and @agents_key_dock
- launch profiles
- settings work before or after sourcing agents.tmux

### Changed

- **Breaking:** user settings for launch commands, keys and colours
- **Breaking:** colours take any tmux colour, and the border one is settable
- **Breaking:** a bare index such as `set -g @agent_c_input 214` no
- **Breaking:** one folder per harness under harnesses/
- **Breaking:** the Copilot and Pi hooks moved from hooks/ to

### Fixed

- address the settings review
- a hidden profile stays hidden, and 0 is a key

## [0.14.0](https://github.com/willdah/tmux-agent-corral/compare/0.13.0...0.14.0) - 2026-10-25

### Changed

- **Breaking:** group the scripts into src/, hooks/ and scripts/
- **Breaking:** group scripts into src/, hooks/ and scripts/
- **Breaking:** the hooks and links point at the old root paths; re-run

## [0.13.0](https://github.com/willdah/tmux-agent-corral/compare/0.12.0...0.13.0) - 2026-10-18

### Added

- c adds the new agent's window to a session you pick

## [0.12.0](https://github.com/willdah/tmux-agent-corral/compare/0.11.0...0.12.0) - 2026-10-18

### Added

- c starts a new agent in a session of its own

## [0.11.0](https://github.com/willdah/tmux-agent-corral/compare/0.10.1...0.11.0) - 2026-10-18

### Added

- doctor checks the setup and says what to fix

## [0.10.1](https://github.com/willdah/tmux-agent-corral/compare/0.10.0...0.10.1) - 2026-10-18

### Fixed

- x marks an interrupted Claude idle, not working until the next prompt

## [0.10.0](https://github.com/willdah/tmux-agent-corral/compare/0.9.0...0.10.0) - 2026-10-09

### Added

- d kills an agent's pane, once ↵ confirms it

## [0.9.0](https://github.com/willdah/tmux-agent-corral/compare/0.8.0...0.9.0) - 2026-10-09

### Added

- n on a group heading renames its tmux session

## [0.8.0](https://github.com/willdah/tmux-agent-corral/compare/0.7.0...0.8.0) - 2026-10-09

### Added

- grouped panel leads with the most urgent session
- grouped panel puts the most urgent session first, with headings that count each session's agents by state and a gap above every group

## [0.7.0](https://github.com/willdah/tmux-agent-corral/compare/0.6.2...0.7.0) - 2026-10-09

### Added

- notify when a background agent needs you, and wait/prompt verbs for scripts
- a message or desktop notification when a background agent needs you
- agent-state prompt hands text to an agent from a script or another agent
- agent-state wait blocks until an agent needs you or finishes

## [0.6.2](https://github.com/willdah/tmux-agent-corral/compare/0.6.1...0.6.2) - 2026-10-07

### Fixed

- the docked panel follows a jump into a window the client has not shown yet

## [0.6.1](https://github.com/willdah/tmux-agent-corral/compare/0.6.0...0.6.1) - 2026-10-07

### Fixed

- give the agent its own column and stop the session column sprawling
- roomier panel columns, and the dock keeps the project over the agent

## [0.6.0](https://github.com/willdah/tmux-agent-corral/compare/0.5.0...0.6.0) - 2026-10-07

### Added

- message and rename an agent inline, in the panel's input line
- message and rename an agent inline, in the panel's own input line

### Fixed

- an inline message reaches only the agent it was written to

## [0.5.0](https://github.com/willdah/tmux-agent-corral/compare/0.4.1...0.5.0) - 2026-10-07

### Added

- group the panel's agents by tmux session

### Fixed

- address review of the session grouping
- a panel under 44 columns lists its agents again

## [0.4.1](https://github.com/willdah/tmux-agent-corral/compare/0.4.0...0.4.1) - 2026-10-07

### Fixed

- a docked jump no longer flickers
- a docked jump survives a failing step and every fallback is tested

## [0.4.0](https://github.com/willdah/tmux-agent-corral/compare/0.3.3...0.4.0) - 2026-10-07

### Added

- column headings, agent-corral title, focus-aware docked title
- the docked panel's title shows when it has focus
- the panel names its columns and is called agent-corral

## [0.3.3](https://github.com/willdah/tmux-agent-corral/compare/0.3.2...0.3.3) - 2026-10-06

### Fixed

- The panel lists agents on tmux before 3.5.

## [0.3.2](https://github.com/willdah/tmux-agent-corral/compare/0.3.1...0.3.2) - 2026-10-06

### Fixed

- Install works when `~/.config/tmux` is a link.

## [0.3.1](https://github.com/willdah/tmux-agent-corral/compare/0.3.0...0.3.1) - 2026-10-06

### Fixed

- A docked jump can't hang on a stale lock or stop short.

## [0.3.0](https://github.com/willdah/tmux-agent-corral/compare/0.2.0...0.3.0) - 2026-10-06

### Added

- The docked panel keeps focus when it opens and when it jumps.

## [0.2.0](https://github.com/willdah/tmux-agent-corral/compare/0.1.0...0.2.0) - 2026-10-05

### Added

- One-line install that also wires up `tmux.conf`.

### Changed

- The panel refreshes on agent state change instead of every 2s.

### Fixed

- Copilot shows as working on its first prompt, and `x` interrupts it.

## [0.1.0](https://github.com/willdah/tmux-agent-corral/releases/tag/0.1.0) - 2026-10-05

### Added

- tmux agents panel for Claude Code, Copilot CLI and Pi.

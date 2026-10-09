# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

New entries are written by the release workflow from the conventional commit
messages and PR titles merged since the previous release.

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

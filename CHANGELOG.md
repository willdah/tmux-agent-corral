# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

New entries are written by the release workflow from the conventional commits
merged since the previous release.

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

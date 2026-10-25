# User settings in a bash tmux plugin

How tmux plugins let users set the launch command, the colours and the keys, and what tmux-agent-corral should copy. Sources are the tmux man page and source, TPM, and the plugins' own code, pinned to commits read on 2026-10-24 (tmux 3.8 and fzf 0.74.5 installed locally).

## 1. tmux user options

- **What they are.** Any option whose name starts with `@` is a user option and holds any string ([tmux.1 L4758](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/tmux.1#L4758)). tmux never checks the value, so the plugin has to.
- **Scope.** User options can be server, session, window or pane options. In a format, `#{@name}` checks the scopes in this order: server, pane, window, global window, session, global session ([format.c L4687-4697](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/format.c#L4687-L4697)). A plain `set -g @x` is a global session option. That is the right scope for settings, and every plugin below uses it. The pane-scoped `@agent_state` already in the repo fits the same order, because a pane option is found before a global one.
- **Reading.** `show -gv @x` exits 1 with `invalid option: @x` when `@x` is unset. `show -gqv @x` prints an empty string and exits 0 ([tmux.1 L4895](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/tmux.1#L4895); checked on 3.8). So `-q` cannot tell "unset" from "set to empty".
- **Defaults that do not overwrite.** `set -o` refuses to set an option that is already set, and `-q` turns off the error ([cmd-set-option.c L303-318](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/cmd-set-option.c#L303-L318), [tmux.1 L4826](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/tmux.1#L4826)). This means `set -goq @x default` in a sourced file keeps a value the user set *before* sourcing, and a value set *after* sourcing still wins.
- **Formats.** `set -F` expands formats in the value. `#{E:@x}` expands an option's value as a format a second time ([tmux.1 L7293](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/tmux.1#L7293)), which is how `@agents_status` already works. `if -F` evaluates a format and runs no shell ([tmux.1 L8877](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/tmux.1#L8877)). `run-shell` expands formats before it runs ([tmux.1 L8886](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/tmux.1#L8886)), and `run -C` runs a tmux command, not a shell command (added in 3.2, [CHANGES L1290](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/CHANGES#L1290)).
- **Environment variables in the config.** A `NAME=value` line in a tmux config file sets a variable in the global environment ([tmux.1 L675](https://github.com/tmux/tmux/blob/acee541d6ec53127ee34488a281e0b205890ef91/tmux.1#L675)). tmux-fzf is configured this way (section 3).

## 2. TPM's conventions

- [how_to_create_plugin.md](https://github.com/tmux-plugins/tpm/blob/e261deb1b47614eed3400089ce7197dc68acc4eb/docs/how_to_create_plugin.md) says nothing about options. It only shows an executable `*.tmux` file that runs `tmux bind-key T run-shell ...`, and says to pick a key that tmux does not use.
- The convention lives in TPM's code instead: `get_tmux_option NAME DEFAULT` = `show-option -gqv`, falling back to the default when the value is empty ([tpm L9-18](https://github.com/tmux-plugins/tpm/blob/e261deb1b47614eed3400089ce7197dc68acc4eb/tpm#L9-L18)). TPM uses it for its own keys, `@tpm-install` with default `I` ([variables.sh L1-2](https://github.com/tmux-plugins/tpm/blob/e261deb1b47614eed3400089ce7197dc68acc4eb/scripts/variables.sh#L1-L2), [tpm L60-66](https://github.com/tmux-plugins/tpm/blob/e261deb1b47614eed3400089ce7197dc68acc4eb/tpm#L60-L66)). resurrect ([helpers.sh L17](https://github.com/tmux-plugins/tmux-resurrect/blob/cff343cf9e81983d3da0c8562b01616f12e8d548/scripts/helpers.sh#L17)), yank and dracula ([utils.sh L3](https://github.com/dracula/tmux/blob/50b5fdfcbece52124c1ecfd5687469d163e05bf3/scripts/utils.sh#L3)) copy the same helper, and sessionx has its own copy, `tmux_option_or_fallback` ([sessionx.tmux L10-17](https://github.com/omerxx/tmux-sessionx/blob/8df6df56639acedb5343a6db02cf58120ff09ef7/sessionx.tmux#L10-L17)).
- **What this means for ordering:** TPM's `run` line goes at the very bottom of tmux.conf ([README L24-39](https://github.com/tmux-plugins/tpm/blob/e261deb1b47614eed3400089ce7197dc68acc4eb/README.md#L24-L39)). So under TPM the user always sets options *before* the plugin reads them. The defaults live in the plugin's code, not in tmux.

## 3. What established plugins do

### Defaults and overrides

| Plugin | Where the default lives | When the option is read |
|---|---|---|
| TPM, resurrect, yank, sessionx, dracula, thumbs | a bash fallback in `get_tmux_option` | keys at load time, everything else at load time or run time |
| catppuccin | `set -ogq @catppuccin_flavor "mocha"` in a sourced `.conf` ([catppuccin_options_tmux.conf L81](https://github.com/catppuccin/tmux/blob/32d0a8d95d562dd064a62a09d41af136561ae659/catppuccin_options_tmux.conf#L81)) | load time, in a separate options file sourced before the main one "so that options are set before parsing the rest of the config" ([L1-4](https://github.com/catppuccin/tmux/blob/32d0a8d95d562dd064a62a09d41af136561ae659/catppuccin_options_tmux.conf#L1-L4), [catppuccin.tmux L6-7](https://github.com/catppuccin/tmux/blob/32d0a8d95d562dd064a62a09d41af136561ae659/catppuccin.tmux#L6-L7)) |
| tmux-sensible | changes a built-in option only while it still has tmux's default value ([sensible.tmux L33-38, L87](https://github.com/tmux-plugins/tmux-sensible/blob/25cb91f42d020f675bb0a2ce3fbd3a5d96119efa/sensible.tmux#L33-L38)) | load time |
| tmux-fzf | `[ -z "$TMUX_FZF_LAUNCH_KEY" ] && TMUX_FZF_LAUNCH_KEY="F"`, an environment variable ([main.tmux L9-10](https://github.com/sainnhe/tmux-fzf/blob/2839d6bd0e13b7c5e385e131e4c217917fa73555/main.tmux#L9-L10)) | load time |

catppuccin's troubleshooting guide is clear about order: set every `@catppuccin_*` option *before* the plugin loads, and do not use `-o` in your own config ([troubleshooting.md L30-35](https://github.com/catppuccin/tmux/blob/32d0a8d95d562dd064a62a09d41af136561ae659/docs/guides/troubleshooting.md#L30-L35)).

### Key-binding options

Every plugin that lets users rebind keys does it the same way: it reads the key from an option when it loads, then runs `tmux bind-key "$key" ...`.

- resurrect: `@resurrect-save` and `@resurrect-restore` take a space-separated list of keys, and each one is bound ([resurrect.tmux L8-22](https://github.com/tmux-plugins/tmux-resurrect/blob/cff343cf9e81983d3da0c8562b01616f12e8d548/resurrect.tmux#L8-L22)). (The real option name is `@resurrect-save`, not `@resurrect-save-key`.)
- yank: `@copy_mode_yank` ([helpers.sh L10-11](https://github.com/tmux-plugins/tmux-yank/blob/acfd36e4fcba99f8310a7dfb432111c242fe7392/scripts/helpers.sh#L10-L11)). thumbs: `@thumbs-key` ([tmux-thumbs.tmux L7-11](https://github.com/fcsonline/tmux-thumbs/blob/ae91d5f7c0d989933e86409833c46a1eca521b6a/tmux-thumbs.tmux#L7-L11)). sessionx: `@sessionx-bind` ([sessionx.tmux L178](https://github.com/omerxx/tmux-sessionx/blob/8df6df56639acedb5343a6db02cf58120ff09ef7/sessionx.tmux#L178)). tmux-fzf: `TMUX_FZF_LAUNCH_KEY`.
- Names are `@<plugin>-<thing>` or `@<plugin>_<thing>`. No two plugins agree on a key suffix.

### Colour and theme options

- catppuccin: one `@catppuccin_flavor` picks a theme file ([catppuccin_tmux.conf L1](https://github.com/catppuccin/tmux/blob/32d0a8d95d562dd064a62a09d41af136561ae659/catppuccin_tmux.conf#L1)). The theme file sets palette options with `set -ogq @thm_bg "#1e1e2e"` and so on ([themes/catppuccin_mocha_tmux.conf L4](https://github.com/catppuccin/tmux/blob/32d0a8d95d562dd064a62a09d41af136561ae659/themes/catppuccin_mocha_tmux.conf#L4)), so the user can still override any one colour. `@catppuccin_reset` unsets them so that a `client-dark-theme` / `client-light-theme` hook can switch flavours ([options L6-21](https://github.com/catppuccin/tmux/blob/32d0a8d95d562dd064a62a09d41af136561ae659/catppuccin_options_tmux.conf#L6-L21)).
- tmux-power: `@tmux_power_theme` is a named preset or a hex colour ([README L48](https://github.com/wfxr/tmux-power/blob/d69c4d7ffc64828ac5ac4b3056dacdd7ef51997f/README.md#L48), [tmux-power.tmux L50-62](https://github.com/wfxr/tmux-power/blob/d69c4d7ffc64828ac5ac4b3056dacdd7ef51997f/tmux-power.tmux#L50-L62)). It reads all `@tmux_power_*` options with one `tmux show -g` and an `eval` whose input is escaped by awk ([L216](https://github.com/wfxr/tmux-power/blob/d69c4d7ffc64828ac5ac4b3056dacdd7ef51997f/tmux-power.tmux#L216)).
- dracula: `@dracula-colors` holds shell assignments (`white='#f8f8f2' ...`) that are `eval`ed ([dracula.sh L73-75](https://github.com/dracula/tmux/blob/50b5fdfcbece52124c1ecfd5687469d163e05bf3/scripts/dracula.sh#L73-L75), [color_theming/README.md L40](https://github.com/dracula/tmux/blob/50b5fdfcbece52124c1ecfd5687469d163e05bf3/docs/color_theming/README.md#L40)), plus one option per segment, such as `@dracula-git-colors "green dark_gray"`.
- thumbs has one option per colour (`@thumbs-bg-color` and so on, [README L99-104](https://github.com/fcsonline/tmux-thumbs/blob/ae91d5f7c0d989933e86409833c46a1eca521b6a/README.md#L99-L104)). This is the same shape as the existing `@agent_c_*`.

### Command-override options

- **tmux-open `@open-editor-command`** is the closest match to `agents-new`. It reads the option (falling back to `$EDITOR`) and *types* `$editor -- "file"` into the pane with `send-keys`, then sends `C-m` ([open.tmux L12, L82-87](https://github.com/tmux-plugins/tmux-open/blob/763d0a852e6703ce0f5090a508330012a7e6788e/open.tmux#L82-L87)). The user's string is shell code for the pane's shell. tmux-open does not quote it or split it.
- **tmux-yank `@custom_copy_command` / `@override_copy_command`** ([helpers.sh L37-41, L138-172](https://github.com/tmux-plugins/tmux-yank/blob/acfd36e4fcba99f8310a7dfb432111c242fe7392/scripts/helpers.sh#L138-L172)). The string goes straight to `copy-pipe`, and tmux runs it with `/bin/sh`.
- **tmux-thumbs `@thumbs-command`** contains a `{}` placeholder ([README L191-200](https://github.com/fcsonline/tmux-thumbs/blob/ae91d5f7c0d989933e86409833c46a1eca521b6a/README.md#L191-L200)). The code comment explains why the picked text is *never* put into the string itself: the matched text `foo;rm *` would run. Instead it runs `bash -c 'THUMB="$1"; eval "$2"' -- "$text" "$cmd"`, with `{}` changed to `${THUMB}` ([swapper.rs L369-405](https://github.com/fcsonline/tmux-thumbs/blob/ae91d5f7c0d989933e86409833c46a1eca521b6a/src/swapper.rs#L369-L405)).
- **tmux-resurrect hooks** (`@resurrect-hook-*`) run with `eval "$hook $args"`, and the arguments are first quoted with `printf %q` ([helpers.sh L145-157](https://github.com/tmux-plugins/tmux-resurrect/blob/cff343cf9e81983d3da0c8562b01616f12e8d548/scripts/helpers.sh#L145-L157), [docs/hooks.md](https://github.com/tmux-plugins/tmux-resurrect/blob/cff343cf9e81983d3da0c8562b01616f12e8d548/docs/hooks.md)).
- **tmux-fzf `TMUX_FZF_OPTIONS`** is expanded unquoted, so it is split on whitespace ([main.sh L18](https://github.com/sainnhe/tmux-fzf/blob/2839d6bd0e13b7c5e385e131e4c217917fa73555/main.sh#L18)). Quoted arguments are not possible. **sessionx `@sessionx-additional-options`** fixes this with `eval "fzf_opts=($opts)"` ([sessionx.tmux L153](https://github.com/omerxx/tmux-sessionx/blob/8df6df56639acedb5343a6db02cf58120ff09ef7/sessionx.tmux#L153)).

### Separate config files

None of the plugins examined reads its own config file under `~/.config/...`. The only XDG paths they use point to tmux's *own* `tmux.conf`: TPM and sensible locate it ([plugin_functions.sh L23](https://github.com/tmux-plugins/tpm/blob/e261deb1b47614eed3400089ce7197dc68acc4eb/scripts/helpers/plugin_functions.sh#L23), [sensible.tmux L68](https://github.com/tmux-plugins/tmux-sensible/blob/25cb91f42d020f675bb0a2ce3fbd3a5d96119efa/sensible.tmux#L68)), and dracula re-sources it ([compact_alt.sh L30](https://github.com/dracula/tmux/blob/50b5fdfcbece52124c1ecfd5687469d163e05bf3/scripts/compact_alt.sh#L30)). tmux options are the standard way to configure a plugin.

## 4. Ordering pitfalls

- **Read at load time vs at run time.** A binding, or anything else `agents.tmux` evaluates, sees only the options set *before* `source-file`. A script in `src/` reads the option each time it runs, so it sees values set either before or after. The repo's documented rule, "set any of these after the `source-file` line", is only true for values read at run time.
- **`set -g` defaults overwrite earlier user values.** Today `agents.tmux` uses `set -g @agent_c_input 214`, which overwrites a value the user set *before* sourcing. `set -goq` keeps that value, and a later plain `set -g` still wins (verified on tmux 3.8, where `set -go` printed `already set: @agent_c_input` and kept the user's value). With `-o`, both orders work.
- **A binding can read an option while the file is parsed**, without bash. This was tested on 3.8 and the result was `C-b M-a Agents panel`:
  ```tmux
  set -goq @agents_key a
  run -C "bind -N 'Agents panel' '#{@agents_key}' display-popup -B -E -w 90% -h 85% '~/.config/tmux/agents/src/agents'"
  ```
  `run -C` expands formats, so any `#{...}` that should reach the bound command unexpanded must be written `##{...}` (for example `##{window_id}` in the `A` binding). The option must be set before sourcing. Changing it later needs a re-source, and the old key stays bound until the user unbinds it.
- **Reloads.** Re-sourcing with `set -go` does not reset a value. That is why catppuccin needs `@catppuccin_reset` before it can change themes at run time.

## 5. Running a user-supplied command string

- **Splitting on whitespace** (`$cmd args`, as in tmux-fzf) breaks quoting (`--flag "a b"`), and globs are expanded.
- **`eval` / `sh -c "$cmd"`** treats the string as shell code. That is right when the user writes the string in their own tmux.conf. Anyone who can write a tmux option can already run commands through `run-shell`, so `eval` gives no new power. The real danger is putting *untrusted data* (prompt text, paths) into the string. thumbs and resurrect pass data as separate, quoted arguments and never splice it in.
- **agents-new already follows tmux-open.** It types the command into the window's shell ([src/agents-new `spawn`](../../src/agents-new)), and the prompt text is quoted with `sq`. So a user command such as `headroom wrap claude --model x` needs no extra work: put it in unquoted as shell code, and keep quoting only the prompt. The pane's shell (zsh, fish, ...) parses the string. Document that it must be valid in the user's shell.
- **Problems this exposes in the current code** (not fixed here):
  - In the scripted form, `command -v "$agent"` rejects a command with more than one word, although the help text says "AGENT can be any command".
  - The copilot `-i` check looks at `${agent##*/}`. A wrapper string such as `headroom wrap copilot` would get `--` instead. The prompt style should be chosen by the *harness name*, not by the command string.
- **The sweep still works with a wrapper.** `stale()` only clears a pane whose foreground process is a bare shell with no children ([src/agent-state L61-64](../../src/agent-state)). A wrapper process is not a bare shell, so the sweep keeps the agent.

## 6. fzf key customisation

- **`FZF_DEFAULT_OPTS`** (and `FZF_DEFAULT_OPTS_FILE`) are read *first*, then the command-line options ([options.go L3906-3944](https://github.com/junegunn/fzf/blob/b412a450538e5f4a1d7057732e75d945dafa18a6/src/options.go#L3906-L3944), [fzf.1 L1440-1448](https://github.com/junegunn/fzf/blob/b412a450538e5f4a1d7057732e75d945dafa18a6/man/man1/fzf.1#L1440-L1448)). A later `--bind` for the same key replaces the earlier one ([options.go L2050](https://github.com/junegunn/fzf/blob/b412a450538e5f4a1d7057732e75d945dafa18a6/src/options.go#L2050)). So:
  - The user's `FZF_DEFAULT_OPTS` *cannot* override the panel's keys, because the panel's own `--bind`s come later.
  - It *can* add options the panel does not set (for example `--multi`, or `--bind` on a key the panel does not use). Those leak into the panel. tmux-fzf relies on this deliberately ([README L138-140](https://github.com/sainnhe/tmux-fzf/blob/2839d6bd0e13b7c5e385e131e4c217917fa73555/README.md#L138-L146)).
- **sessionx is the only plugin examined with per-key fzf options.** It has about 15 `@sessionx-bind-*` options, and builds both the `--bind` strings and its header from them ([sessionx.tmux L41-94](https://github.com/omerxx/tmux-sessionx/blob/8df6df56639acedb5343a6db02cf58120ff09ef7/sessionx.tmux#L41-L94)). It also has a catch-all for extra options, `@sessionx-additional-options`, which goes after its own options.
- **Costs for this panel.** The panel's keys are tied together:
  - The `lock` list unbinds `y,x,m,n,d,c,r,g,p,j,k,q,...` by name while an input is open ([src/agents ~L426](../../src/agents)).
  - The footer names the keys.
  - `agents-new` has its own steps.

  Per-key options would have to feed all three places. One "extra fzf options" option appended last is cheap. But a user who rebinds `y` there would get around the lock list.

## 7. Validation and doctor checks

- tmux validates nothing in a user option. A bad key fails at `bind` time with `unknown key`, and on a config load that error is shown once.
- The plugins examined do not validate. They fall back to the default only on an *empty* value, and anything else goes through as it is (`get_tmux_option` above).
- `src/doctor` already checks `@agents_notify` (`command -v "$how"`, [src/doctor L95-102](../../src/doctor)). Checks with the same style would cost little:
  - `@agent_c_*` is an integer from 0 to 255.
  - The first word of each launch command resolves with `command -v`.
  - The bound keys exist (`tmux list-keys -T prefix <key>`).

## Recommendation for tmux-agent-corral

**Build:**

1. **Launch command, one option per harness:** `@agents_cmd_claude`, `@agents_cmd_copilot`, `@agents_cmd_pi`. Each is unset by default and falls back to the harness name. `spawn` reads `tmux show -gqv "@agents_cmd_$harness"` at run time, types it unquoted as shell code (as tmux-open does), and quotes only the prompt with `sq` as it does now.
   - Choose the prompt style (`-i` vs `--`) by harness name, not by the command string.
   - Keep `installed()` checking the harness binary, so that choices are still listed by harness.
   - Optionally add an `@agents_cmd` fallback that applies to all harnesses. Leave it out unless someone asks for it.
2. **Colours:** keep `@agent_c_*` as 256-colour indexes. Change the defaults in `agents.tmux` from `set -g` to `set -goq`, so a value set before *or* after sourcing is kept.
   - Do not add theme presets or a flavour system. `@agent_c_text` and `@agent_c_dim` already cover a light theme.
   - Fix the hard-coded panel greys (`fc=238`, `fg+:255`, `bg+:236` in `src/agents` / `src/agents-new`) only if users report a problem, through one more `@agent_c_*` option each.
3. **Prefix keys:** add `@agents_key` (default `a`) and `@agents_key_dock` (default `A`), set with `set -goq` and bound through `run -C "bind ... '#{@agents_key}' ..."` (section 4; write `##{window_id}` in the dock binding). Document that these two keys, unlike the rest, must be set *before* the `source-file` line. Users who want more can already `unbind a` and write their own `bind`, because the README can show the two commands.
4. **Doctor:** add the three checks from section 7.

**Don't build:**

- **A separate config file under `~/.config/agents/`.** None of the plugins examined uses one, it would split settings into two places, and tmux options already work from scripts and formats.
- **Per-key fzf options for the panel.** The lock list and the footer would have to follow every rebind, and sessionx shows how big that surface becomes. If someone asks for it, the most to add is `@agents_fzf_opts`, appended after the built-in options and parsed with `eval "extra=($opts)"` as sessionx does. Document that it replaces keys at the user's own risk.
- **Environment-variable settings** (the tmux-fzf style). They do not match the existing `@agents_*` style.

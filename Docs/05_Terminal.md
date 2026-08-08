# Terminal

This document covers my terminal setup: Fish shell, Starship prompt, Konsole, btop, fastfetch, and the CLI tool stack that replaces several coreutils/default tools day to day.

---

## Table of Contents

- [Overview](#overview)
- [Fish](#fish)
- [Starship](#starship)
- [Konsole](#konsole)
- [btop](#btop)
- [fastfetch](#fastfetch)
- [CLI Tool Stack](#cli-tool-stack)
- [Verification](#verification)
- [Notes](#notes)
- [Conclusion](#conclusion)

---

## Overview

### My Terminal Philosophy

- **Fish over bash/zsh**: sane defaults out of the box (syntax highlighting, autosuggestions) without needing a plugin manager just to get there.
- **Modern replacements over coreutils, applied narrowly**: only `ls` and `cat` are aliased over — the tools that get typed dozens of times a day. Not a wholesale coreutils replacement.
- **A Nerd Font is a hard requirement**: Starship's icons, `eza`'s file-type glyphs, and the Konsole profile font all depend on **JetBrains Mono Nerd Font** being installed. Without it, prompts and listings render with broken/missing glyphs instead of icons (see [`04_rice.md#font`](04_rice.md#font) for the install command).
- **Not everything follows the Tokyo Night palette from [`04_rice.md`](04_rice.md)**: `bat` uses Catppuccin Frappe (see [Notes](#notes)) — kept as a deliberate exception, not an oversight.

---

## Fish

Config file: `~/.config/fish/config.fish` — deliberately short:

```fish
starship init fish | source

alias ls="eza -lah --icons --group-directories-first"

alias cat="bat --paging=never --theme='Catppuccin Frappe'"

alias ..="cd .."


fastfetch
```

- `starship init fish | source` wires up the prompt (see [Starship](#starship)).
- The two aliases replace `ls`/`cat` with `eza`/`bat` unconditionally — no fallback to stock coreutils since both tools are always installed on this system (see [CLI Tool Stack](#cli-tool-stack)).
- `fastfetch` runs on every new shell as the startup banner (see [fastfetch](#fastfetch)).

---

## Starship

Config file: `~/.config/starship.toml` — this is the stock **Nerd Font Symbols** preset (`starship preset nerd-font-symbols -o ~/.config/starship.toml`), not a hand-built config. It only overrides the icon (`symbol`) used per language/tool module (Rust, Node, Docker, Git, etc.) so each context shows a recognizable glyph instead of the plain-text default.

Depends on JetBrains Mono Nerd Font — without it, module icons show as boxes or missing glyphs instead of symbols.

---

## Konsole

Custom profile: `~/.local/share/konsole/Inmemorialake.profile`

```ini
[Appearance]
ColorScheme=TokyoNightStormCustom
Font=JetBrainsMono Nerd Font,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1

[Cursor Options]
CursorShape=2

[General]
Environment=TERM=xterm-256color,COLORTERM=truecolor
Name=Inmemorialake
Parent=FALLBACK/

[Terminal Features]
BlinkingCursorEnabled=true
```

- `ColorScheme=TokyoNightStormCustom` — a custom `.colorscheme` also stored under `~/.local/share/konsole/`, part of the same Tokyo Night/Storm thread as the KDE color scheme in [`04_rice.md`](04_rice.md).
- `COLORTERM=truecolor` is what makes `bat`'s syntax highlighting and `eza`'s colors render correctly — without it some terminal apps fall back to a reduced 256-color palette.
- `CursorShape=2` sets an I-beam cursor instead of the default block.

---

## btop

```bash
sudo pacman -S btop
```

Config file: `~/.config/btop/btop.conf`

```ini
color_theme = "/usr/share/btop/themes/tokyo-storm.theme"
theme_background = true
```

Same palette family as the rest of the system, kept as the bundled `tokyo-storm` theme rather than a hand-edited one.

---

## fastfetch

```bash
sudo pacman -S fastfetch
```

Config file: `~/.config/fastfetch/config.jsonc`. Runs automatically at the end of `config.fish` as the shell startup banner. Two things worth calling out:

- **Custom logo**: instead of the default Arch Linux logo, it points at a Konsole asset:
  ```jsonc
  "logo": {
      "source": "/home/Inmemorialake/.local/share/konsole/Arch Terminal Logo.png"
  }
  ```
- **Colored, icon-led modules**: each section (System, etc.) uses a colored header and a Nerd Font icon per field (`key: "󰣇"` for OS, `""` for kernel, and so on) instead of fastfetch's plain-text default labels.

---

## CLI Tool Stack

Installed via `pacman`/`paru`, used daily:

| Tool | Replaces / role | Config |
|---|---|---|
| `eza` | `ls` (aliased) | none — flags passed inline (`-lah --icons --group-directories-first`) |
| `bat` | `cat` (aliased) | theme forced to `Catppuccin Frappe` inline (see [Notes](#notes)) |
| `ripgrep` (`rg`) | `grep` | none, used with defaults |
| `fd` | `find` | none, used with defaults |
| `zoxide`/`fzf` | — | not installed; plain `cd`/history is enough so far |
| `Yazi` | file manager (TUI) | no config folder — stock defaults |
| `lazygit` | git TUI | `~/.config/lazygit/config.yml`, theme left on `default` |
| `lazydocker` | Docker/Compose TUI | `~/.config/lazydocker/config.yml`, empty — stock defaults |
| `delta` | git/diff pager | configured via `~/.gitconfig` (`core.pager`, `side-by-side`, `navigate`), not a standalone config file |
| `httpie` | `curl` for quick manual requests | none |

`delta` specifically, from `~/.gitconfig`:

```ini
[core]
	pager = delta
[interactive]
	diffFilter = delta --color-only
[delta]
	navigate = true
	line-numbers = true
	hyperlinks = true
	side-by-side = true
	syntax-theme = none
	light = false
```

`syntax-theme = none` is intentional — it lets delta inherit terminal colors instead of imposing its own syntax theme on top of Konsole's.

---

## Verification

```bash
fish -c "starship --version"        # prompt renders on shell start
eza -lah --icons                    # icons show as glyphs, not boxes/question marks
bat --list-themes | grep Frappe     # Catppuccin Frappe available
btop                                 # tokyo-storm theme visible
fastfetch                            # custom logo + colored sections on launch
```

---

## Notes

- `bat`'s `Catppuccin Frappe` theme is the one intentional break from the Tokyo Night/Storm thread used everywhere else ([`04_rice.md`](04_rice.md), Konsole, btop) — kept because it read better for syntax highlighting specifically, not swapped out for consistency's sake.
- `lazygit` and `lazydocker` are both installed but left on their default/`default` theme — no color-matching done there yet.
- `zoxide`/`fzf` are deliberately not installed; revisit if `cd`-ing around gets painful enough to justify it.

---

## Conclusion

The terminal setup is intentionally light-touch: a 10-line Fish config, a stock Starship preset with icon overrides, and a handful of TUI tools used with mostly default configs. The only two places with real customization are Konsole's color scheme/font and fastfetch's banner — everything else rides on sane upstream defaults.

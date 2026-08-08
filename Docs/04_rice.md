# Rice (Visual Customization)

This document covers the visual customization ("rice") of my Arch Linux + KDE Plasma (Wayland) system: color scheme, window decoration, icons, cursors, panel/dock layout, wallpaper, font, SDDM, and GRUB theming. It does not repeat Konsole or btop, both already covered in [`05_Terminal.md`](05_Terminal.md) — they're cross-linked from here since they share the same color thread.

---

## Table of Contents

- [Overview](#overview)
- [Color Palette](#color-palette)
- [KDE Color Scheme](#kde-color-scheme)
- [Window Decoration and Effects](#window-decoration-and-effects)
- [Icon Theme](#icon-theme)
- [Cursor Theme](#cursor-theme)
- [Panel and Dock](#panel-and-dock)
- [Wallpaper](#wallpaper)
- [Font](#font)
- [SDDM Theme](#sddm-theme)
- [GRUB Theme](#grub-theme)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Notes](#notes)
- [Conclusion](#conclusion)

---

## Overview

### My Rice Philosophy

- **One palette, everywhere it's cheap to apply it**: Tokyo Night/Storm is the base for the KDE color scheme, Konsole ([`05_Terminal.md`](05_Terminal.md#konsole)), btop ([`05_Terminal.md`](05_Terminal.md#btop)), MangoHud's blue accent ([`06_Gaming.md`](06_Gaming.md#mangohud)), SDDM, and GRUB. `bat` is the one deliberate exception (see [Notes](#notes)).
- **Native Plasma over third-party tools**: the panel/dock setup is built entirely with Plasma's own panel editor — no Latte Dock, no third-party compositor add-ons beyond the KWin effects already bundled upstream.
- **Manually-fetched assets are still tracked**: the SDDM theme and GRUB theme were not installed as pacman/AUR packages — they were downloaded and vendored directly into this repo (`configs/sddm/`, `configs/grub/`), since they live under `/usr/share/...` and can't ride the `~/.config`/`~/.local` symlink mechanism the rest of the dotfiles use (see [SDDM Theme](#sddm-theme), [GRUB Theme](#grub-theme), and [`architecture.md#dotfiles`](architecture.md#dotfiles) for the mechanism itself).
- **Precision over completeness**: every section below is read directly from the live config files on this system. Where something turned out to be stock/default rather than customized (widget style, Plasma theme, Konsole/btop already covered elsewhere), that's stated explicitly rather than glossed over.

![Desktop overview](assets/rice/desktop-overview.png)

---

## Color Palette

Source of truth: `~/.local/share/color-schemes/TokyoNigthStormBlue.colors`, the active KDE color scheme (`ColorScheme=TokyoNigthStormBlue` in `~/.config/kdeglobals`).

> **Filename typo**: the file is genuinely named `TokyoNigthStormBlue.colors` ("Nigth", not "Night") on disk. Left as-is intentionally — it's what's actually installed and referenced by `kdeglobals` on this system, not a documentation typo. Every reference to this file below reproduces the typo on purpose.

The `Blue` suffix marks this as a custom accent variant of the Tokyo Night Storm family — the same "accent everything in blue" idea shows up again in MangoHud's `text_color=2E86FF` ([`06_Gaming.md`](06_Gaming.md#mangohud)). The two blues aren't the same hex (the KDE scheme's accent is `#7AA2F7`, MangoHud's is a punchier `#2E86FF`), but they're the same design decision applied in two different tools.

| Section | Role | RGB | Hex |
|---|---|---|---|
| `Colors:Window` / `Colors:View` | Base background | 31,35,53 | `#1F2335` |
| `Colors:Window` / `Colors:View` | Base foreground | 192,202,245 | `#C0CAF5` |
| `Colors:Window` / `Colors:View` | Accent (focus/hover decoration) | 122,162,247 | `#7AA2F7` |
| `Colors:Window` / `Colors:View` | Inactive foreground | 86,95,137 | `#565F89` |
| `Colors:Window` / `Colors:View` | Negative (errors) | 247,118,142 | `#F7768E` |
| `Colors:Window` / `Colors:View` | Neutral (warnings) | 224,175,104 | `#E0AF68` |
| `Colors:Window` / `Colors:View` | Positive (success) | 158,206,106 | `#9ECE6A` |
| `Colors:Window` / `Colors:View` | Visited link | 187,154,247 | `#BB9AF7` |
| `Colors:Button` | Background | 41,46,66 | `#292E42` |
| `Colors:Button` | Background alternate | 30,87,116 | `#1E5774` |
| `Colors:Selection` | Selection background | 122,162,247 | `#7AA2F7` |
| `Colors:Selection` | Selection foreground | 31,35,53 | `#1F2335` |
| `WM` | Active titlebar background | 39,44,49 | `#272C31` |
| `WM` | Inactive titlebar background | 32,36,40 | `#202428` |

Full section-by-section breakdown, straight from the `.colors` file:

```ini
[Colors:Window]
BackgroundNormal=31,35,53
ForegroundNormal=192,202,245
DecorationFocus=122,162,247
DecorationHover=122,162,247
ForegroundInactive=86,95,137
ForegroundNegative=247,118,142
ForegroundNeutral=224,175,104
ForegroundPositive=158,206,106
ForegroundVisited=187,154,247

[Colors:Button]
BackgroundNormal=41,46,66
BackgroundAlternate=30,87,116
DecorationFocus=122,162,247

[Colors:Selection]
BackgroundNormal=122,162,247
ForegroundNormal=31,35,53

[WM]
activeBackground=39,44,49
activeForeground=252,252,252
inactiveBackground=32,36,40
inactiveForeground=161,169,177
```

`Colors:View`, `Colors:Tooltip`, and `Colors:Header` all mirror `Colors:Window` value-for-value on this scheme — not duplicated here, see the file directly for the exact byte-for-byte confirmation.

---

## KDE Color Scheme

Active scheme, confirmed from `~/.config/kdeglobals`:

```ini
[General]
ColorScheme=TokyoNigthStormBlue
ColorSchemeHash=1743995135d7e805fc5b61d77f933578c1fbbf87
LastUsedCustomAccentColor=122,162,247

[KDE]
contrast=4
widgetStyle=Breeze
```

`LastUsedCustomAccentColor` matches the scheme's own `DecorationFocus`/`Colors:Selection` value (`122,162,247` / `#7AA2F7`) — the accent color picked in System Settings and the scheme file agree, as expected.

The scheme's own `[General]` block is worth calling out too, since it explains where the "Blue" variant name comes from:

```ini
[General]
ColorScheme=BreezeDark
Name=Tokyo Nigth Storm Blue
TitlebarIsAccentColored=false
```

It's built on top of `BreezeDark` (the `ColorScheme=` key here refers to the *base* scheme it inherits layout/behavior from, not a separate active scheme), with `Name=Tokyo Nigth Storm Blue` as the human-readable label shown in System Settings — same typo, same reasoning as the filename above.

**Konsole cross-check**: `~/.local/share/konsole/TokyoNightStormCustom.colorscheme` (documented in [`05_Terminal.md`](05_Terminal.md#konsole), not repeated here) uses `Background=31,35,53`, `Foreground=192,202,245`, and `Color4=122,162,247` — an exact match against `Colors:Window`'s background, foreground, and accent above. Same Tokyo Night/Storm thread, confirmed byte-for-byte, not just "the same idea."

---

## Window Decoration and Effects

**Widget style and Plasma style**: `widgetStyle=Breeze` in `kdeglobals` (see [KDE Color Scheme](#kde-color-scheme) above) and `~/.config/plasmarc`:

```ini
[Theme]
name=default
```

Both are stock — neither the Qt widget style nor the Plasma panel/plasmoid style (which `default` resolves to, i.e. Breeze) were customized. The visual customization on this system is concentrated in the color scheme, window decoration, icons, cursors, and panel layout below, not in the widget/Plasma style itself.

**Window decoration**: a custom Aurorae theme, `Carl`, vendored at `~/.local/share/aurorae/themes/Carl/` (tracked via the `~/.local` symlink, same reproducibility mechanism as everything else under [`architecture.md#dotfiles`](architecture.md#dotfiles)).

`~/.config/kwinrc`:

```ini
[org.kde.kdecoration2]
BorderSize=Tiny
BorderSizeAuto=false
ButtonsOnLeft=MXAI
ButtonsOnRight=
library=org.kde.kwin.aurorae.v2
theme=__aurorae__svg__Carl
```

`ButtonsOnLeft=MXAI` decodes (KDE's standard decoration button letters: `M`=Menu, `X`=Close, `A`=Maximize, `I`=Minimize) to **Menu, Close, Maximize, Minimize, all on the left** — mac-style placement, but with a different button order and nothing on the right (`ButtonsOnRight=` is empty). `BorderSize=Tiny` keeps the window border thin.

The theme itself, `~/.local/share/aurorae/themes/Carl/Carlrc`:

```ini
[General]
ActiveTextColor=201,201,205,255
InactiveTextColor=149,165,166,255
TitleAlignment=Center
LeftButtons=XIA

[Layout]
BorderLeft=2
BorderRight=2
BorderBottom=7
TitleHeight=15
ButtonWidth=12
ButtonHeight=12
```

`Carlrc`'s own `LeftButtons=XIA` is overridden by `kwinrc`'s `ButtonsOnLeft=MXAI` above — the global kwinrc setting wins over the theme's shipped default.

**KWin effects** enabled beyond the Plasma defaults, from `~/.config/kwinrc`:

```ini
[Plugins]
blurEnabled=true
glideEnabled=true
magiclampEnabled=true
translucencyEnabled=true
wobblywindowsEnabled=true

[Effect-blur]
BlurStrength=13

[Effect-diminactive]
Strength=10

[Effect-wobblywindows]
Drag=92
MoveFactor=20
Stiffness=3
WobblynessLevel=3
```

Blur (menus/panels), wobbly windows (drag physics), glide and magic lamp (open/minimize animations), and dim-inactive-windows are all on.

---

## Icon Theme

`~/.config/kdeglobals`:

```ini
[Icons]
Theme=Slot-Nord-Dark-Icons
```

Installed manually under `~/.local/share/icons/Slot-Nord-Dark-Icons/` — **not** a pacman or AUR package (confirmed: no `pacman -Qo`/`paru -Qm` hit owns that path). Its `index.theme`:

```ini
[Icon Theme]
Name=Slot-Nord-Dark-Icons
Comment=Slot Nord Dark Icon For Dark Themes
Inherits=breeze-dark,Adwaita,hicolor
FollowsColorScheme=true
```

A sibling variant, `Slot-Nord-Dark-Colorize-Icons`, is also present under the same directory but is **not** the active theme — `kdeglobals` points at the plain `-Icons` build, not `-Colorize-Icons`.

---

## Cursor Theme

`~/.config/kdedefaults/kcminputrc`:

```ini
[Mouse]
cursorTheme=breeze_cursors
```

`breeze_cursors` is the internal theme ID for what KDE's Spanish locale displays as **"Brisa oscuro"** — confirmed directly from the package's own `index.theme` (`/usr/share/icons/breeze_cursors/index.theme`):

```ini
Name=Breeze Dark
Name[es]=Brisa oscuro
Comment=Breeze Dark by the KDE VDG
Comment[es]=Brisa oscuro, por KDE VDG
```

So "Brisa oscuro" seen in System Settings is just the localized name of the stock **Breeze Dark** cursor theme, package `breeze-cursors` (official repo, confirmed via `pacman -Qo /usr/share/icons/breeze_cursors`) — not a custom cursor set. A separate `Sweet-cursors` theme is installed under `~/.icons/` but is **not** the active one; it sits unused.

---

## Panel and Dock

Built entirely through Plasma's native panel configuration — "Edit Mode" → add panel → add widgets. No Latte Dock, no third-party dock tool. The panel layout lives in `~/.config/plasma-org.kde.plasma.desktop-appletsrc` and `~/.config/plasmashellrc`, both under the `~/.config` symlink into this repo — already version-controlled and reproduced automatically on a fresh clone, exactly like `kwinrc`/`kdeglobals` (see [`architecture.md#dotfiles`](architecture.md#dotfiles)). No manual "how to rebuild the panel" steps are needed here.

The config also contains a second, mirrored set of panel containments tagged `lastScreen=1` — a leftover from a previously-connected external monitor. The description below covers the primary laptop panel set (`lastScreen=0`), which is what's actually visible in the screenshot above.

Three panels on the primary screen, all **floating** style:

**Bottom dock** — fit-content width, center-aligned, 44px thick, visibility set to *Dodge windows* (`panelVisibility=2`; a maximized window can dodge over it — this is not the same as *Auto hide*, which would be `panelVisibility=1`). One applet, Icon Tasks, with these pinned launchers (`~/.config/plasma-org.kde.plasma.desktop-appletsrc`):

```ini
[Containments][102][Applets][105][Configuration][General]
launchers=applications:systemsettings.desktop,applications:org.kde.konsole.desktop,preferred://filemanager,preferred://browser,applications:code.desktop,applications:tidal-hifi.desktop,applications:whatsdesk.desktop,applications:discord.desktop,applications:obsidian.desktop
```

System Settings, Konsole, file manager, browser, VS Code, Tidal Hi-Fi, WhatsApp (`whatsdesk`), Discord, Obsidian — in that order. Steam is **not** in this list; it's a desktop icon (see [Wallpaper](#wallpaper) containment below), not pinned to the dock.

**Top bar** — full width (default length mode), 32px thick, `panelOpacity=0` (transparent background), always visible (no visibility override). Applet order left to right:

```ini
[Containments][122][General]
AppletOrder=103;214;152;211;217;209;156
```

Kickoff (application launcher, custom icon) → Application Title Bar (`com.github.antroids.application-title-bar`, showing the focused window's close/maximize/minimize buttons plus icon and title, styled with the Carl Aurorae theme — a global-menu-style title bar) → spacer → Digital Clock (24h, week numbers, holiday calendar) → spacer → KdeControlStation (quick-settings widget) → System Tray, with weather (Cali, Colombia), notifications, and clipboard shown directly; camera indicator, input method, keyboard layout, KDE Connect, device notifier, network manager, volume, brightness, battery, Bluetooth, and kscreen collapsed into the tray's overflow, and Easy Effects explicitly hidden from it.

**Third panel** — a small floating bar, left-aligned, 44px thick, same Dodge-windows visibility, dedicated to music controls:

```ini
[Containments][219][General]
AppletOrder=227;223
```

Plasmusic Toolbar (`plasmusic-toolbar`, now-playing track/album art) followed by a Cava-style audio visualizer (`luisbocanegra.audio.visualizer`) that hides itself after 2 seconds of silence (`hideWhenIdle=true`, `idleTimer=2`).

---

## Wallpaper

Active wallpaper on the primary screen, from `~/.config/plasma-org.kde.plasma.desktop-appletsrc`:

```ini
[Containments][101][Wallpaper][org.kde.image][General]
Image=file:///home/Inmemorialake/GDrive/Fondos de Pantalla PC/sushi_colors_upscayl_realesrgan-x4plus_x3.jpg
```

An AI-upscaled image (Real-ESRGAN x4plus, per the filename), stored in a Google Drive-synced folder outside this repo — the wallpaper file itself is **not** version-controlled, only its path is referenced by the config that is. The leftover second-screen containment mentioned in [Panel and Dock](#panel-and-dock) points at a different image (`~/Downloads/tokyo-night23CATP.jpg`), but that containment isn't part of the active single-screen layout.

---

## Font

`JetBrains Mono Nerd Font` is a hard requirement per [`05_Terminal.md`](05_Terminal.md#overview) (Starship icons, `eza` glyphs, Konsole profile font), but no doc previously covered installing it. Confirmed present via:

```bash
fc-list | grep -i "nerd"
```

which lists the full JetBrains Mono Nerd Font family (regular, mono, propo, and the NL variants). Owning package:

```bash
sudo pacman -S ttf-jetbrains-mono-nerd
```

`kdeglobals` also sets it as the fixed-width system font:

```ini
[General]
fixed=JetBrainsMono Nerd Font,11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
font=Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
```

The general UI font (`font=`) is `Inter`, not the Nerd Font — only the fixed-width/monospace slot uses JetBrains Mono Nerd Font.

---

## SDDM Theme

`/etc/sddm.conf.d/kde_settings.conf`:

```ini
[Theme]
Current=sugar-dark
CursorTheme=breeze_cursors
Font=Inter,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1
```

This goes beyond the stock SDDM setup from [`01_Installation.md`](01_Installation.md#441-install-sddm-and-configure-it) (which only sets `DisplayServer=wayland` / `CompositorCommand=kwin_wayland`) — **Sugar Dark** is a real theme choice, vendored at `configs/sddm/sugar-dark/` in this repo. Unlike `~/.config`/`~/.local`, this path is not symlinked automatically (SDDM themes live under `/usr/share/sddm/themes/`, outside `$HOME`) — reproducing it needs a manual copy: `sudo cp -r configs/sddm/sugar-dark /usr/share/sddm/themes/`.

`theme.conf` (defaults) and `theme.conf.user` (this system's overrides):

```ini
# theme.conf
MainColor="#c0caf5"
AccentColor="#7aa2f7"
RoundCorners=20
ForceLastUser=true
ForcePasswordFocus=true
HeaderText="Welcome Inmemorialake"

# theme.conf.user
[General]
background=background-sidebar.jpg
showClock=true
type=image
```

`MainColor`/`AccentColor` are an exact match against the KDE scheme's foreground (`#C0CAF5`) and accent (`#7AA2F7`) from [Color Palette](#color-palette) — the login screen carries the same Tokyo Night Storm Blue thread all the way through boot.

---

## GRUB Theme

`/etc/default/grub`:

```bash
GRUB_THEME="/usr/share/grub/themes/Particle-circle-window/theme.txt"
```

A real custom theme is set — not the stock GRUB text menu from installation. Note the install path: `/usr/share/grub/themes/`, not the more commonly-referenced `/boot/grub/themes/` — this is where the theme actually lives on this system. Like the SDDM theme, it's vendored in this repo (`configs/grub/Particle-circle-window/`) but sits outside the `~/.config`/`~/.local` symlink mechanism, so reproducing it needs a manual copy plus a `grub-mkconfig` regen: `sudo cp -r configs/grub/Particle-circle-window /usr/share/grub/themes/ && sudo grub-mkconfig -o /boot/grub/grub.cfg`.

`theme.txt`:

```config
title-text: "Welcome, Inmemorialake"
title-color: "#c0caf5"
desktop-image: "background.png"
desktop-color: "#c0caf5"
terminal-font: "Terminus Regular 14"

+ boot_menu {
  left = 19%
  top = 18%
  width = 28%
  height = 54%
  item_font = "Unifont Regular 16"
  item_color = "#c0caf5"
  selected_item_color = "#FFF"
  icon_width = 32
  icon_height = 32
}
```

`title-color`/`desktop-color`/`item_color` all use `#c0caf5` — the same foreground color as the KDE scheme and the SDDM theme. This is unrelated to `grub-btrfs`/snapshot boot entries, already covered in [`02_Btrfs_and_snapshots.md`](02_Btrfs_and_snapshots.md) — this section is purely about the visual theme.

---

## Verification

```bash
kreadconfig6 --file kdeglobals --group General --key ColorScheme   # TokyoNigthStormBlue
kreadconfig6 --file kdeglobals --group Icons --key Theme            # Slot-Nord-Dark-Icons
kreadconfig6 --file kdedefaults/kcminputrc --group Mouse --key cursorTheme   # breeze_cursors

fc-list | grep -i "nerd"                     # JetBrains Mono Nerd Font family present
pacman -Qo /usr/share/icons/breeze_cursors    # owned by breeze-cursors
pacman -Qo "$(fc-list | grep -i 'JetBrainsMono Nerd Font,' -m1 | cut -d: -f1)"   # owned by ttf-jetbrains-mono-nerd

grep GRUB_THEME /etc/default/grub             # Particle-circle-window theme set
grep Current /etc/sddm.conf.d/kde_settings.conf   # sugar-dark theme set
```

---

## Troubleshooting

### Icon or cursor theme not picked up after cloning the repo

`Slot-Nord-Dark-Icons` and `Sweet-cursors` live under `~/.local/share/icons/` and `~/.icons/` respectively — both reproduce automatically via the `~/.local` symlink ([`architecture.md#dotfiles`](architecture.md#dotfiles)), **but only the config pointer does, not necessarily a cold icon cache**. If icons look wrong right after a fresh clone, rebuild the cache:

```bash
kbuildsycoca6 --noincremental
```

### SDDM/GRUB theme "missing" on a fresh install

Expected — these two are vendored copies (`configs/sddm/`, `configs/grub/`) that sit outside the `~/.config`/`~/.local` symlink mechanism because they install under `/usr/share/...`, not `$HOME`. They need the manual `cp` steps in [SDDM Theme](#sddm-theme) and [GRUB Theme](#grub-theme) — this is the one place in the rice setup that isn't "clone and go."

---

## Notes

- `bat`'s Catppuccin Frappe theme is the one deliberate break from the Tokyo Night/Storm thread used everywhere else in this document — already explained in [`05_Terminal.md#notes`](05_Terminal.md#notes), not repeated here.
- The second-screen panel/wallpaper containments (`lastScreen=1`) found in `plasma-org.kde.plasma.desktop-appletsrc` are leftovers from a previously-connected external monitor, not part of the current single-screen layout — left in place rather than cleaned up, since Plasma itself doesn't surface them when only one screen is connected.
- `Slot-Nord-Dark-Colorize-Icons` and `Sweet-cursors` are both installed alongside their active counterparts but unused — kept on disk in case either gets tried again later, not a config error.

---

## Conclusion

The rice on this system is one deliberate color decision (Tokyo Night Storm Blue) applied consistently from the KDE color scheme down through the window decoration, panel, SDDM, and GRUB — with Konsole, btop, and MangoHud picking up the same thread from their own docs. The only real config debt is that the SDDM and GRUB themes, unlike everything else, can't ride the automatic `~/.config`/`~/.local` symlink and need a manual copy step to reproduce — everything else on this page is "clone the repo and it's already there."

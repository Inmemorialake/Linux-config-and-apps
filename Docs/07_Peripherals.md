# Peripherals & Power Management

This document covers three pieces of hardware-adjacent configuration that don't fit into any other doc: the Legion keyboard RGB profile, KDE's power management (battery), and EasyEffects (audio). Each was configured through a different mechanism (a CLI tool, KDE System Settings, and a GUI app respectively), so each section documents its own source of truth.

---

## Table of Contents

- [Overview](#overview)
- [Legion Keyboard RGB](#legion-keyboard-rgb)
- [Power Management (Battery)](#power-management-battery)
- [Audio (EasyEffects)](#audio-easyeffects)
- [Verification](#verification)
- [Quick Reference](#quick-reference)
- [Notes](#notes)
- [Conclusion](#conclusion)

---

## Overview

None of the three items here were previously documented in detail — `architecture.md` and `01_Installation.md` only name `power-profiles-daemon` and `EasyEffects` in passing, with no actual configuration recorded. This document exists to close that gap.

---

## Legion Keyboard RGB

### Why this needs a service at all

`legion-kb-rgb` (from [L5P-Keyboard-RGB](https://github.com/4JX/L5P-Keyboard-RGB)) runs entirely in userspace. The BIOS only controls the lighting state visible *before* the OS boots — once Linux is running, nothing re-applies a profile unless something explicitly tells the driver to run. There is no persistent "profile" concept at the driver level beyond whatever `set` command you give it, so autostart has to replay that exact command on every boot.

### Profile

Built from the GUI, exported profile (`Perfil de Teclado 1`):

```json
{"name":"Untitled","rgb_zones":[{"rgb":[0,18,255],"enabled":true},{"rgb":[0,18,255],"enabled":true},{"rgb":[0,18,255],"enabled":true},{"rgb":[57,0,255],"enabled":true}],"effect":"Static","direction":"Left","speed":1,"brightness":"High"}
```

Translated to the documented CLI syntax (`set -e <effect> -c <r,g,b,...> -b <1|2>`):

```bash
legion-kb-rgb set -e Static -c 0,18,255,0,18,255,0,18,255,57,0,255 -b High
```

Binary location: `/usr/bin/legion-kb-rgb`.

> The README documents `-b` as taking `1`/`2` (low/high), but the installed build actually expects the text values `Low`/`High` — confirmed via `legion-kb-rgb set --help` on this system after the numeric value failed with `error: invalid value '2' for '--brightness <BR...>'`. Check `--help` on your own install before trusting the README literally.

### Autostart via systemd

A `oneshot` system service replays the command above on every boot, independent of login/GUI:

```bash
sudo tee /etc/systemd/system/legion-kb-profile.service > /dev/null << 'EOF'
[Unit]
Description=Cargar perfil de teclado Legion RGB
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/bin/legion-kb-rgb set -e Static -c 0,18,255,0,18,255,0,18,255,57,0,255 -b High
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now legion-kb-profile.service
```

> **fish shell note:** `tee ... << 'EOF'` is bash heredoc syntax and fails in fish (`Se esperaba a string, pero se encontró a redirection`). Either write the unit file with `nano`/your editor directly, or use fish's own syntax — see the `printf '%s\n' ... | sudo tee` pattern already used for `zram-generator.conf` in [`06_Gaming.md`](06_Gaming.md#zram).

> If `legion-kb-rgb` requires `sudo` to talk to the keyboard (no udev rule installed), this service needs to run as root — which it does by default, since it's a system (not user) unit.

---

## Power Management (Battery)

### Backend

`power-profiles-daemon` exposes and applies power profiles (power-saver, balanced, performance) over D-Bus. It's the backend KDE's Powerdevil talks to when you change the power profile — Powerdevil doesn't implement that switching logic itself, it delegates to `power-profiles-daemon`. The package also ships `powerprofilesctl`, a CLI for querying/setting the active profile manually (`/usr/bin/powerprofilesctl`), though it isn't used manually here — all profile switching is automatic, driven by Powerdevil below.

### Powerdevil configuration

Configured directly in KDE System Settings → Energy (three tabs: AC, Battery, Low Battery).

**With AC power:**

| Setting | Value |
|---|---|
| Suspend when idle | Sleep, after 15 minutes |
| Power button | Show logout screen |
| Lid close | Sleep |
| Sleep state | Suspend to RAM |
| Screen brightness | 70% |
| Auto-dim | After 5 minutes |
| Screen off | After 10 minutes (1 minute if locked) |
| Keyboard brightness | 50% |
| **Power profile** | **Performance** |

**With battery:**

| Setting | Value |
|---|---|
| Suspend when idle | Sleep, after 2 minutes |
| Power button | Show logout screen |
| Lid close | Sleep |
| Sleep state | Suspend to RAM |
| Screen brightness | 70% |
| Auto-dim | After 1 minute |
| Screen off | After 2 minutes (20 seconds if locked) |
| Keyboard brightness | 50% |
| **Power profile** | **Power Saver** |

**With low battery:** left at KDE defaults — not customized.

No scripts, no `powerprofilesctl` automation, no TLP. The profile switch (Performance ↔ Power Saver) happens automatically based on AC/battery state, entirely through Powerdevil's own settings.

---

## Audio (EasyEffects)

### Config layout

This system runs EasyEffects 8.x, the Qt/Kirigami rewrite (KDE Frameworks, not the older GTK4/PipeWire-filter version). As of that rewrite, config is split across two XDG locations:

| Path | Contents |
|---|---|
| `~/.config/easyeffects/db/` | Live/active state only — one KConfig `rc` file per plugin (`equalizerrc`, `compressorrc`, etc.) plus `easyeffectsrc`. This is *not* where presets live. |
| `~/.local/share/easyeffects/` | Presets (`output/`, `input/`), impulse responses (`irs/`), rnnoise models (`rnnoise/`), and autoload profiles (`autoload/`) |

### Presets

**Output** (`~/.local/share/easyeffects/output/`) — community presets, installed but not otherwise modified:

- `Advanced Auto Gain.json`
- `Bass Boosted.json`
- `Bass Enhancing + Perfect EQ - Low Latency.json`
- `Bass Enhancing + Perfect EQ.json`
- `Boosted.json`
- `Dolby Atmos.json`
- `Laptop.json`
- `Loudness+Autogain.json`
- `Perfect EQ.json`
- `Speaker Sync.json`

**Input** (`~/.local/share/easyeffects/input/`):

- `voz_natural.json` — **the one in active use**, self-tuned for the KZ Castor microphone (last touched 4 Aug alongside `gaterc`, `echoCancellerrc`, `deepfilternetrc`, and `rnnoiserc` — a real hands-on tuning session, not a preset load).
- `EasyEffects Microphone Preset: Masc NPR Voice + Noise Reduction.json` — a downloaded community preset, kept but not the one in use.

### Autoload

The `autoload/` folder is empty — no preset is bound to auto-activate on device connect (e.g. Castor plugged in → `voz_natural`). Presets are applied manually from the app.

### Startup

EasyEffects is set to launch automatically at login ("Launch Service at System Startup" in Preferences) — it does not need to be opened manually.

---

## Verification

```bash
# Keyboard RGB service is enabled and applied
systemctl status legion-kb-profile.service

# Power profile backend running, current profile
systemctl status power-profiles-daemon
powerprofilesctl get

# EasyEffects presets present
ls ~/.local/share/easyeffects/output/
ls ~/.local/share/easyeffects/input/
```

---

## Quick Reference

```bash
# Reapply keyboard profile manually
legion-kb-rgb set -e Static -c 0,18,255,0,18,255,0,18,255,57,0,255 -b High

# Check/set power profile manually (normally automatic via Powerdevil)
powerprofilesctl get
powerprofilesctl set performance   # or power-saver / balanced

# EasyEffects preset files
~/.local/share/easyeffects/output/   # speaker/headphone presets
~/.local/share/easyeffects/input/    # microphone presets (voz_natural.json in use)
```

---

## Notes

- The keyboard profile was originally saved from the GUI as a standalone JSON export (`Perfil de Teclado 1`), not as the app's own `settings.json` — that's why the systemd service replays it via the documented `set` CLI syntax instead of pointing `LEGION_KEYBOARD_CONFIG` at the exported file.
- Battery-low thresholds were deliberately left at KDE defaults rather than customized — revisit if that ever becomes an issue.
- `voz_natural.json` is the working mic preset; the `Masc NPR Voice + Noise Reduction.json` preset is kept on disk but unused — remove it if it turns out to just be clutter.

---

## Conclusion

Keyboard, battery, and audio are each configured through different tools (a Rust CLI, KDE's own settings, and a Qt app's preset system), but all three shared the same problem: nothing was written down. This document fixes that — the keyboard now also has a systemd unit ensuring the profile survives a reboot, which none of the other two needed since Powerdevil and EasyEffects's autorun already persist their own state.

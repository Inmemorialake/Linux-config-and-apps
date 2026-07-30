# Gaming Setup

This document covers the gaming setup on my Arch Linux system: Steam, Proton-GE, Heroic Games Launcher (for Epic/EA titles), GameMode, MangoHud, and zram. It builds on the NVIDIA Optimus/PRIME configuration already covered in [`01_Installation.md`](01_Installation.md#43-set-up-nvidia-drivers-if-applicable) — this document does not repeat that setup, only how gaming tools hook into it.

---

## Table of Contents

- [Overview](#overview)
- [Steam and Proton-GE](#steam-and-proton-ge)
- [Heroic Games Launcher (Epic / EA)](#heroic-games-launcher-epic--ea)
- [GameMode](#gamemode)
- [MangoHud](#mangohud)
- [zram](#zram)
- [Wrapper Commands Reference](#wrapper-commands-reference)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Quick Reference](#quick-reference)
- [Notes](#notes)

---

## Overview

### My Configuration Philosophy

- **NVIDIA stays off by default**: the RTX 3050 only activates via `prime-run` (`NVreg_DynamicPowerManagement=0x02`, fine-grained power management — see `01_Installation.md`). Games are launched through wrappers that force the offload explicitly, nothing runs on the dedicated GPU by accident.
- **Proton-GE over stock Proton**: better compatibility with EA/Frostbite titles specifically.
- **Heroic over a native EA client**: there is no native EA App for Linux. For EA titles bought through Epic (like Star Wars Battlefront II 2017), Heroic detects this automatically and manages the EA App under the same Proton prefix — no manual Lutris/Wine setup needed.
- **Minimal HUD**: MangoHud is configured FPS-only, styled after the NVIDIA overlay on Windows — clean, no clutter, one corner of the screen.

### Hardware Context

- CPU: Intel i5-12450H (Alder Lake, `intel_pstate` active mode)
- GPU: Intel iGPU (default) + NVIDIA RTX 3050 (Optimus, on-demand)
- RAM: 8GB — this is why zram is not optional in this setup, see below

---

## Steam and Proton-GE

```bash
sudo pacman -S steam
```

In Steam → Settings → Compatibility, enable **Steam Play for all titles** (not just unsupported ones). This makes any EA game bought directly on Steam run through Proton without extra configuration.

Install Proton-GE via ProtonPlus (AUR):

```bash
paru -S protonplus
```

Open it, go to the Proton-GE tab, and download the latest version. It becomes available automatically in Steam's compatibility dropdown and in Heroic.

---

## Heroic Games Launcher (Epic / EA)

```bash
paru -S heroic-games-launcher-bin
```

Log in with the Epic account. For EA titles bought through Epic (Star Wars Battlefront II 2017 in my case), Heroic detects this on install and manages the EA App automatically inside the same Wine/Proton prefix — pick the Proton-GE version installed above under the game's **Wine Settings**.

No kernel-level anticheat on Battlefront II 2017 (confirmed via AreWeAntiCheatYet), so it runs clean through Proton without extra anticheat configuration.

---

## GameMode

```bash
sudo pacman -S gamemode lib32-gamemode
```

GameMode is a daemon that, while a game runs, temporarily requests system-level optimizations (CPU governor to `performance`, I/O priority, screensaver/compositor inhibition) and reverts everything automatically on exit. `lib32-gamemode` is needed because Proton's internal helper processes are sometimes 32-bit even when the game itself is 64-bit.

### Verification

```bash
gamemoded -t
```

Should pass all tests. See [Troubleshooting](#troubleshooting) if the CPU governor test fails — it did on this system and required a group membership fix.

---

## MangoHud

```bash
sudo pacman -S mangohud lib32-mangohud
```

Config file: `~/.config/MangoHud/MangoHud.conf`. Tried a detailed config first (GPU name/temp/clock, CPU stats, RAM, frametime graph) to confirm the PRIME offload was working — useful for verification, but too busy for actual play. Settled on this minimal, NVIDIA-overlay-style config instead:

```ini
### Solo FPS, estilo minimalista (como el overlay de NVIDIA en Windows)
fps
fps_only
legacy_layout=0

### Apagar todo lo demás explícitamente
cpu_stats=0
gpu_stats=0
frame_timing=0
frametime=0

### Estilo
position=top-right
font_size=24
background_alpha=0.3
round_corners=8
text_color=2E86FF

### Atajos
toggle_hud=Shift_L+F12
toggle_logging=Shift_L+F2
```

### Verification

```bash
mangohud glxgears          # sin offload, debería mostrar la Intel si se agrega gpu_name temporalmente
prime-run mangohud glxgears  # con offload, debería mostrar la RTX 3050
```

---

## zram

With only 8GB of RAM, Frostbite-based games (shader compilation, texture streaming) can push into swap. Without zram, that swap goes straight to the NVMe partition — noticeably slower than RAM, causes stutter. zram compresses pages in RAM itself (zstd, ~2-3:1 ratio) before ever touching disk swap.

```bash
sudo pacman -S zram-generator
```

Config file: `/etc/systemd/zram-generator.conf`. **Write this with `printf | tee`, not copy-paste into an editor** — pasting the block below directly from a chat or a rendered markdown page can merge all lines into one, which the INI parser silently rejects (`invalid outside-of-section key`, no device gets created). In fish:

```fish
printf '%s\n' '[zram0]' 'zram-size = min(ram, 8192)' 'compression-algorithm = zstd' | sudo tee /etc/systemd/zram-generator.conf > /dev/null
```

Verify it actually has 3 separate lines before continuing:

```bash
cat -A /etc/systemd/zram-generator.conf
# Debe verse:
# [zram0]␊
# zram-size = min(ram, 8192)␊
# compression-algorithm = zstd␊
```

Activate:

```bash
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
```

No `systemctl enable` needed — the generator creates the unit automatically on every boot once the config file exists.

### Verification

```bash
zramctl
swapon --show
```

`swapon --show` should list both `/dev/zram0` (priority 100 by default) and the disk swap partition (priority -1 or -2) — the kernel always prefers the higher-priority device, so zram gets used first.

---

## Wrapper Commands Reference

The offload chain (`prime-run` → `gamemoderun` → `mangohud`) has to be applied per-launcher, syntax differs:

**Steam** — Properties → General → Launch Options:

```bash
prime-run gamemoderun mangohud %command%
```

**Heroic** — game Settings → Advanced → Wrapper Command(s), add each as a separate entry via the `+` button, no arguments, no `%command%`:

```bash
prime-run
gamemoderun
mangohud
```

Order matters in both: `prime-run` has to be outermost so it wraps the entire process (including MangoHud's Vulkan layer loading) under the offload environment variables.

---

## Verification

Full end-to-end check after setup:

```bash
gamemoded -t                              # todos los tests deben pasar
zramctl && swapon --show                  # zram activo con prioridad alta
prime-run mangohud glxgears               # overlay visible, confirma offload
```

In-game: launch through the configured wrapper, confirm the FPS overlay appears top-right, no visible stutter on shader compilation loads.

---

## Troubleshooting

### GameMode: "Governor was not set to performance (was actually powersave)"

`gamemoded -t` fails this specific test while everything else passes. The Arch package builds GameMode with `-Dwith-privileged-group=gamemode`, meaning its polkit rule (`/usr/share/polkit-1/rules.d/gamemode.rules`) only authorizes users who belong to the `gamemode` group. Creating the group isn't enough — you have to actually join it, and it doesn't apply to your current session:

```bash
sudo usermod -aG gamemode $USER
# cerrar sesión y volver a entrar (o reiniciar)
groups $USER      # debe listar "gamemode"
gamemoded -t       # todos los tests pasan
```

Confirm via `journalctl -b | grep -iE "gamemode|cpugovctl|polkit"` if you see `pkexec ... Not authorized` errors — that's the exact symptom of this issue.

### zram: "Error: Device zram0 not found"

There are two separate phases: the **generator phase** (runs on `daemon-reload` or boot) does `modprobe zram` and creates the actual device; the **service's ExecStart** (`systemctl start systemd-zram-setup@zram0.service`) only *configures* a device that must already exist. If you manually `modprobe`/`modprobe -r` the module between attempts, the generator phase needs to re-run — just retrying `systemctl start` won't recreate the device:

```bash
sudo modprobe -r zram   # limpia cualquier dispositivo suelto de intentos manuales
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
```

### zram-generator.conf: "invalid outside-of-section key ini [zram0]"

The config file got mangled into a single line during copy-paste (`ini [zram0] zram-size = ...` all on one line — note the stray `ini` from a markdown code fence tag getting pasted in too). The INI parser needs `[zram0]` alone on its own line. Fix: rewrite with `printf '%s\n' ... | sudo tee <path>` (see [zram](#zram) above), and confirm with `cat -A` that each line actually ends in `␊`.

### fish: heredoc syntax doesn't work

`<< 'EOF'` is bash syntax. In fish, use `printf '%s\n' 'line1' 'line2' ... | sudo tee <path>` instead — same result, portable across shells.

---

## Quick Reference

```bash
# Instalación completa
sudo pacman -S steam gamemode lib32-gamemode mangohud lib32-mangohud zram-generator
paru -S protonplus heroic-games-launcher-bin

# Verificación rápida
gamemoded -t
zramctl && swapon --show
prime-run mangohud glxgears

# Activar zram sin reiniciar
sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service
```

---

## Notes

- Battlefront II (2017) via Heroic/EA App runs noticeably better than on Windows on this same hardware — no kernel-level anticheat is a big part of why this was low-friction.
- The 8GB RAM ceiling is the main constraint driving both the zram setup and the choice of a minimal MangoHud config (less overhead than a full stats overlay).
- If a future game needs GPU verification again (offload not confirmed), temporarily add `gpu_name` back to `MangoHud.conf` rather than keeping it on permanently — it was useful for diagnosis, not for regular play.

---

## Conclusion

This setup gets NVIDIA PRIME offload, GameMode, and MangoHud working together per-game through Steam and Heroic, with zram compensating for the 8GB RAM ceiling. Every fix documented here (the `gamemode` polkit group, the zram-generator two-phase mechanism, the INI parsing gotcha) came from real errors hit while setting this up, not from the general documentation online — worth checking here first before re-diagnosing from scratch.

# System Architecture

This document provides a comprehensive overview of my Arch Linux system architecture, detailing all major components, their relationships, and configuration approach.

---

## Table of Contents

- [System Overview](#system-overview)
- [Hardware](#hardware)
- [Core System](#core-system)
- [Desktop Environment](#desktop-environment)
- [Development Tools](#development-tools)
- [System Management](#system-management)
- [Network and Security](#network-and-security)
- [Architecture Diagram](#architecture-diagram)

---

## System Overview

**Distribution**: Arch Linux (rolling release)  
**Philosophy**: Minimalist, customizable, fully documented and reproducible  
**Approach**: Manual configuration with automated maintenance scripts  
**Backup Strategy**: Btrfs snapshots with grub-btrfs integration

---

## Hardware

### Primary Components

- **CPU**: Intel (with integrated GPU)
- **GPU**:
  - Intel iGPU (primary for desktop and battery efficiency)
  - NVIDIA RTX 3050 (Optimus configuration, on-demand via `prime-run`)
- **Storage**: NVMe SSD with Btrfs filesystem
- **Memory**: 8GB DDR5 RAM (single module, single channel — one DIMM slot populated, running at 4800 MT/s)
- **Form Factor**: Laptop (optimized for battery life and performance)

### Power Management

- **Default GPU**: Intel iGPU (Wayland session)
- **NVIDIA Power Management**: Dynamic (off by default, activated with `prime-run`)
- **Battery Optimization**: `power-profiles-daemon` for power state management

---

## Core System

### Bootloader

**GRUB** with UEFI support

- EFI System Partition: 1 GiB (FAT32)
- Boot directory: `/boot/efi`
- Integration with Btrfs snapshots via `grub-btrfs`
- Kernel parameters: `nvidia-drm.modeset=1`

### Kernel

**linux** (mainline kernel)

- Microcode: `intel-ucode`
- Modules: `nvidia`, `nvidia_modeset`, `nvidia_uvm`, `nvidia_drm`
- initramfs: Generated with `mkinitcpio`

### Filesystem

**Btrfs** (B-tree File System)

Subvolume layout:

```C++
/dev/nvme0n1p2 (Btrfs root)
├── @                → /              (snapshotted)
├── @home            → /home          (not snapshotted)
├── @snapshots       → /.snapshots    (snapshot storage)
├── @var_log         → /var/log       (not snapshotted)
├── @var_cache       → /var/cache     (not snapshotted)
└── @tmp             → /tmp           (not snapshotted)
```

**Snapshot Strategy**:

- Tool: `snapper` with `snap-pac` integration
- Automatic snapshots: Before/after package operations
- Manual snapshots: Before risky operations
- Retention: Keep last 10 snapshots, 5 important ones
- Cleanup: Automated via `snapper-cleanup.timer`

### Partition Scheme

```C++
/dev/nvme0n1p1    1G        EFI System Partition (ESP), mounted at /efi
/dev/nvme0n1p2    455.9G    Root (Btrfs with subvolumes)
/dev/nvme0n1p3    20G       Swap
```

Grew from the original layout in [`01_Installation.md`](01_Installation.md#16-partition-the-disk) (170G root, 8G swap) after the root partition was extended into space left unpartitioned at install time, and swap was resized separately. `01_Installation.md` documents the install process as it happened and is left as-is; this section reflects current sizes.

### Init System

systemd

- Service manager and system initialization
- Timer-based automation (replaces cron)
- Journal logging with `journald`

---

## Desktop Environment

### Display Server

**Wayland** (default)

- Compositor: KWin (KDE's Wayland compositor)
- Session type: Native Wayland (not XWayland)
- NVIDIA: Uses `nvidia-drm` for Wayland compatibility

### DE

KDE Plasma (Latest version)

- Session: Wayland
- Display Manager: SDDM (configured for Wayland)
- Theme and widgets: see [`04_rice.md`](04_rice.md)

#### Core KDE Applications

Dolphin, Konsole, Kate, Spectacle, KDE Connect, Gwenview, Okular, Elisa — see [`05_Terminal.md`](05_Terminal.md) for the terminal/shell stack specifically.

#### System Integration

- **Audio**: PipeWire + WirePlumber
  - PulseAudio compatibility layer
  - Low-latency audio processing
  - EasyEffects for audio enhancement
- **Bluetooth**: BlueZ (if enabled)
- **Network**: NetworkManager with plasma-nm frontend
- **Power**: Powerdevil (KDE power management)

---

## Development Tools

### Shell

**Fish** (Friendly Interactive Shell)

- Path: `/usr/bin/fish`
- Config: `~/.config/fish`
- Features: Syntax highlighting, autosuggestions, web-based configuration
- Prompt: Starship — see [`05_Terminal.md`](05_Terminal.md#starship)

### Editors and IDEs

- **VS Code**: Primary code editor, the config is synced in my account
- **Sublime Text**: Alternative text editor
- **JetBrains Toolbox**: IDE manager (IntelliJ, PyCharm, etc.)

### Version Control

#### Git

- Global config: `~/.gitconfig`
- Credential helper: `git-credential-libsecret` (integrates with KWallet)
- Authentication: GitHub tokens (classic)

### Containers and Virtualization

**Docker** + **Docker Compose**

- Network: Custom bridge networks
- User: Added to `docker` group (no sudo required)
- Buildkit: Enabled by default

---

## System Management

### Package Management

**Pacman** (official repositories)

- Config: `/etc/pacman.conf`
- Features: Parallel downloads, colored output, ILoveCandy animation
- Multilib: Enabled (32-bit support)
- Cache: Managed by `paccache` (keep last 2-3 versions)

**Paru** (AUR helper)

- AUR packages: Installed from source
- Development packages: `--devel` flag for git packages
- Integration: Works alongside pacman

### Maintenance Scripts

All scripts live under `~/Linux-config-and-apps/configs/home/.local/bin/`, live under `~/.local/bin/` automatically via the top-level `~/.local` symlink (see [Dotfiles](#dotfiles)) — no per-script symlink needed. All of them derive from `script-template.sh`, the shared template providing standard logging functions, header, and sudo self-elevation conventions.

Full script-by-script breakdown, organized by category (`sys/`, `pkg/`, `keyring/`, `log/`, `systemd/`, `btrfs/`, `disk/`), is in [`maintenance.md`](maintenance.md).

### Automation

#### Systemd Timers/Services

- `snapper-cleanup.timer`: Automatic snapshot cleanup — **active**
- `grub-btrfsd.service`: GRUB menu updates with snapshots — **active**
- `tailscaled.service`: Tailscale VPN daemon — **active**
- `fstrim.timer`: Weekly SSD TRIM — **disabled** (TRIM is handled continuously via `discard=async` instead, see [Performance Optimizations](#performance-optimizations))
- `reflector.timer`: Mirror list updates — **disabled** (run manually via `mirrors-update` when needed)
- `paccache.timer`: Pacman cache cleanup — **disabled** (run manually via `pkg-clean-cache` instead)

---

## Network and Security

### Network Manager

- Frontend: `plasma-nm` (KDE integration)
- Profiles: Saved network connections
- VPN: Supports various protocols

### Tailscale VPN

- Service: `tailscaled.service`
- Interface: `tailscale0` (virtual)
- Purpose: Secure mesh network between devices
- Firewall: Allowed on tailscale0 interface

### Firewall

**UFW** (Uncomplicated Firewall)

- Status: Active and enabled
- Default policy: Deny incoming, allow outgoing, deny routed
- Logging: Disabled (performance optimization)

**Allowed Services**:

- KDE Connect: Ports 1714-1764 (TCP/UDP)
- Docker: Networks 172.17.0.0/16, 172.18.0.0/16, interface docker0
- Tailscale: Interface tailscale0 (bidirectional)
- SSH: Port 22, active with rate limiting (`ufw limit`)
- Samba can be enabled temporarily when needed

### Phone Integration with KDE Connect

- Protocol: Custom over TCP/UDP
- Features: File sharing, notifications sync, clipboard, media control
- Firewall: Ports 1714-1764 open on local network

---

## Architecture Diagram

### System Stack (Bottom to Top)

```ASSCII
┌─────────────────────────────────────────────────────────────┐
│                     USER APPLICATIONS                       │
│  Browser (Opera) │ VS Code │ Discord │ Docker │ Games       │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                   DESKTOP ENVIRONMENT                       │
│              KDE Plasma 6 (Wayland Session)                 │
│  ┌──────────┬──────────┬──────────┬──────────┬───────────┐  │
│  │ Dolphin  │ Konsole  │  Kate    │Spectacle │KDE Connect│  │
│  └──────────┴──────────┴──────────┴──────────┴───────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    DISPLAY SERVER                           │
│                  Wayland (KWin compositor)                  │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    GRAPHICS DRIVERS                         │
│  Intel iGPU (mesa, vulkan-intel) │ NVIDIA RTX 3050          │
│         Default for desktop        │  On-demand (prime-run) │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    AUDIO SUBSYSTEM                          │
│          PipeWire + WirePlumber + EasyEffects               │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    SYSTEM SERVICES                          │
│  NetworkManager │ Docker │ Tailscale │ UFW │ Snapper        │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      INIT SYSTEM                            │
│                        systemd                              │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                    LINUX KERNEL                             │
│              linux (mainline) + intel-ucode                 │
│           Modules: nvidia, nvidia_drm, btrfs                │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      BOOTLOADER                             │
│              GRUB (UEFI) + grub-btrfs                       │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                      FILESYSTEM                             │
│  EFI (1G) │ Btrfs (455.9G with subvolumes) │ Swap (20G)     │
└─────────────────────────────────────────────────────────────┘
                              │
┌─────────────────────────────────────────────────────────────┐
│                       HARDWARE                              │
│  Intel CPU + iGPU │ NVIDIA RTX 3050 │ NVMe SSD │ DDR5 RAM   │
└─────────────────────────────────────────────────────────────┘
```

---

## Configuration Management

### Dotfiles

**Mechanism**: The repo lives inside `$HOME` (`~/Linux-config-and-apps/`). A handful of top-level symlinks point from `$HOME` into `configs/home/` inside the repo, so the tracked files *are* the live configuration directly — there is no separate `dotfiles/` folder and no sync/copy step.

> **Exception**: SDDM and GRUB themes are the one part of the setup that
> doesn't ride this mechanism — they install under `/usr/share/...`,
> outside `$HOME`, so they're vendored in the repo (`configs/sddm/`,
> `configs/grub/`) but need a manual copy step. See
> [`04_rice.md#sddm-theme`](04_rice.md#sddm-theme) and
> [`04_rice.md#grub-theme`](04_rice.md#grub-theme) for the exact commands.

```bash
~/.config      -> Linux-config-and-apps/configs/home/.config
~/.local       -> Linux-config-and-apps/configs/home/.local
~/.gitconfig   -> Linux-config-and-apps/configs/home/.gitconfig
~/.fonts.conf  -> Linux-config-and-apps/configs/home/.fonts.conf
```

- Fish shell: `~/.config/fish/` (via the `~/.config` symlink)
- Konsole: `~/.local/share/konsole/` (via the `~/.local` symlink)
- KDE Plasma: `~/.config/` (various files, via the `~/.config` symlink)

### Reproducibility

The system is designed to be fully reproducible:

1. Install Arch Linux following `01_Installation.md`
2. Configure Btrfs snapshots per `02_Btrfs_and_snapshots.md`
3. Install packages from package lists
4. Clone this repo into `$HOME` and recreate the top-level symlinks (`.config`, `.local`, `.gitconfig`, `.fonts.conf`) described in [Dotfiles](#dotfiles) — this also brings the maintenance scripts under `~/.local/bin/` live, with no separate install step
5. Vendor the SDDM and GRUB themes manually (the one step that isn't "clone and go" — see [`04_rice.md#troubleshooting`](04_rice.md#troubleshooting))
6. Configure firewall with `03_firewall.md`

**Estimated time to reproduce**: 2-3 hours (excluding personalization)

### Versioning

The repository — including `.obsidian/` — is version-controlled with plain Git. Commits are made manually as configuration changes; there's no automated commit or push mechanism running against this tree.

---

## Performance Optimizations

### Boot Time

- **Target**: < 15 seconds to login screen
- **Optimizations**:
  - Minimal services enabled
  - SSD TRIM via `discard=async` mount option (continuous, not the weekly `fstrim.timer` — that timer is present but disabled on this system)
  - Btrfs mounted with `relatime` (not `noatime`)
  - Systemd analyze for bottleneck detection

### Disk Space Management

- **Cleanup**:
  - Pacman cache: manual, via `pkg-clean-cache` (keeps last 2 versions per package) — not the `paccache.timer` systemd timer, which is disabled on this system
  - Snapshots: `snapper-cleanup.timer` (retention policy, active)
  - Journal logs: `journald` with size limits
  - Docker: Manual cleanup with `docker system prune`

---

## Security Posture

### Threat Model

**Primary Concerns**:

- Unauthorized network access
- Malicious packages from AUR
- Physical access (laptop)

**Mitigations**:

- UFW firewall (deny incoming by default)
- Package verification (signatures)
- Screen lock after inactivity

### Security Layers

1. **Network**: UFW firewall + Tailscale VPN
2. **Packages**: Official repos + verified AUR builds
3. **System**: Regular updates, snapshots for rollback
4. **User**: Standard user account (not root)
5. **Physical**: Screen lock, optional disk encryption

---

## Monitoring and Health Checks

### Regular Checks (via scripts)

- **Daily**: `sys-update` (keep system current)
- **Weekly**: `sys-maintain` (comprehensive maintenance)
- **Monthly**: `disk-health-check`, `sys-full-update`

### Health Indicators

- Systemd services: No failed units
- Disk space: < 85% usage
- SMART status: PASSED
- Snapshot count: Within retention policy
- Orphaned packages: Minimal or zero

---

## Future Improvements

### Documentation Updates

- [x] Create comprehensive README.md
- [x] Complete `05_Terminal.md` (shell configuration)
- [x] Complete `04_rice.md` (visual customization)

---

## Notes

- This architecture prioritizes **stability**, **performance**, and **reproducibility**
- All configurations are version-controlled in the `Linux-config-and-apps` repository
- The system is designed for both **daily use** and **development work**
- Battery efficiency is balanced with performance (NVIDIA on-demand)
- Snapshots provide safety net for experimentation

---

## References

- [Arch Linux Installation Guide](01_Installation.md)
- [Btrfs and Snapshots](02_Btrfs_and_snapshots.md)
- [Firewall and Security](03_firewall.md)
- [Rice](04_rice.md)
- [Terminal](05_Terminal.md)
- [Gaming](06_Gaming.md)
- [System Maintenance](maintenance.md)
- [Arch Wiki](https://wiki.archlinux.org/)

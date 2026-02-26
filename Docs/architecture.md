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
- **Memory**: DDR5 RAM
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
/dev/nvme0n1p3 (Btrfs root)
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
/dev/nvme0n1p1    1G      EFI System Partition (ESP)
/dev/nvme0n1p2    8G        Swap
/dev/nvme0n1p3    170G      Root (Btrfs with subvolumes)
```

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
- Theme: [To be customized]
- Widgets: [To be documented after personalization]

#### Core KDE Applications

- **Dolphin**: File manager
- **Konsole**: Terminal emulator (with Fish shell)
- **Kate**: Text editor
- **Spectacle**: Screenshot tool
- **KDE Connect**: Phone integration
- **Gwenview**: Image viewer
- **Okular**: Document viewer
- **Elisa**: Music player

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
- Prompt: [Starship/Custom - to be documented]

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

All scripts located in `~/Linux-config-and-apps/bin/` and symlinked to `~/.local/bin/`

#### System (`sys/`)

- `sys-update`: Standard system update (pacman -Syu)
- `sys-full-update`: Full update (keyrings, mirrors, AUR)
- `sys-maintain`: Periodic maintenance orchestrator

#### Packages (`pkg/`)

- `pkg-clean-cache`: Clean pacman cache (paccache)
- `pkg-check-orphans`: Detect orphaned packages
- `pkg-clean-orphans`: Remove orphaned packages
- `mirrors-update`: Update mirror list with reflector

#### Keyrings (`keyring/`)

- `keyring-update`: Refresh archlinux-keyring

#### Logs (`log/`)

- `log-usage`: Check journald disk usage
- `log-vacuum`: Clean old journal entries

#### Systemd (`systemd/`)

- `system-health`: Audit failed services
- `timer-audit`: Review active timers

#### Btrfs (`btrfs/`)

- `btrfs-maintain`: Routine Btrfs maintenance (balance, defrag)
- `btrfs-disk-usage`: Detailed space usage report

#### Disk (`disk/`)

- `disk-health-check`: SMART status and disk health
- `disk-space-monitor`: Monitor disk usage thresholds
- `disk-cleanup`: Safe cleanup (cache, trash)

### Automation

**Systemd Timers** (active)

- `snapper-cleanup.timer`: Automatic snapshot cleanup
- `grub-btrfsd.service`: GRUB menu updates with snapshots
- `fstrim.timer`: Weekly SSD TRIM
- `reflector.timer`: Mirror list updates (optional)
- `paccache.timer`: Pacman cache cleanup (optional)

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
- Default policy: Deny incoming, allow outgoing
- Logging: Disabled (performance optimization)

**Allowed Services**:

- KDE Connect: Ports 1714-1764 (TCP/UDP)
- Docker: Networks 172.17.0.0/16, 172.18.0.0/16, interface docker0
- Tailscale: Interface tailscale0 (bidirectional)
- SSH (if enabled): Port 22 (customizable)
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
│  EFI (1G) │ Swap (8G) │ Btrfs (170G with subvolumes)        │
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

**Location**: `~/Linux-config-and-apps/dotfiles/` (to be created)

- Fish shell: `~/.config/fish/`
- Konsole: `~/.local/share/konsole/`
- KDE Plasma: `~/.config/` (various files)

### Reproducibility

The system is designed to be fully reproducible:

1. Install Arch Linux following `01_Installation.md`
2. Configure Btrfs snapshots per `02_Btrfs_and_snapshots.md`
3. Install packages from package lists
4. Apply dotfiles
5. Run maintenance scripts setup
6. Configure firewall with `04_firewall.md`

**Estimated time to reproduce**: 2-3 hours (excluding personalization)

---

## Performance Optimizations

### Boot Time

- **Target**: < 15 seconds to login screen
- **Optimizations**:
  - Minimal services enabled
  - SSD with TRIM enabled
  - Btrfs with `noatime` mount option
  - Systemd analyze for bottleneck detection

### Disk Space Management

- **Automatic cleanup**:
  - Pacman cache: `paccache.timer` (keep last 2-3 versions)
  - Snapshots: `snapper-cleanup.timer` (retention policy)
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

- [ ] Complete `05_rice.md` (visual customization)
- [ ] Complete `06_Terminal.md` (shell configuration)
- [ ] Create comprehensive README.md
- [ ] Document all application configurations

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
- [System Maintenance](03_maintenance.md)
- [Firewall and Security](04_firewall.md)
- [Arch Wiki](https://wiki.archlinux.org/)

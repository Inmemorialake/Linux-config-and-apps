# System Maintenance Plan

This document defines a **comprehensive system maintenance plan** aligned with the final scripts architecture shown below. It preserves the original guidelines (updates, packages, logs, systemd, Btrfs, and disks) while reorganizing them in a **coherent, modular, and automatable** way, using `Linux-config-and-apps/configs/home/.local/bin/` as the single *source of truth*.

---

## Plan objectives

* Keep the system **up to date, stable, and reproducible**.
* Minimize risk during large or sensitive updates.
* Detect issues early (broken packages, failing services, disk degradation).
* Centralize all logic in **version-controlled scripts** that are easy to audit and execute.

---

## Update policy

Two clearly differentiated update levels are defined, each with a specific purpose.

### 1. Standard update

Intended for daily usage.

* Updates official repositories.
* Does not explicitly touch mirrors or keyrings.
* Low risk.

**When to use:**

* Daily or frequent use.
* Before installing new software.

**Script:**

* `sys/sys-update`

---

### 2. Full (major) update

Intended for deeper system changes.

Includes:

* Keyring refresh.
* Mirror list update.
* AUR updates (via `paru`).

**When to use:**

* Every few weeks.
* Before or after major upgrades.
* When signature or package validation issues appear.

**Script:**

* `sys/sys-full-update`

---

### Periodic orchestration

Used for global, non-interactive maintenance.

* Runs safe system checks.
* Does not perform destructive actions without confirmation.

**Script:**

* `sys/sys-maintain`

---

## Package management and cleanup

### Cache policy

* `paccache` is used with a defined retention policy (e.g., keep the last 2–3 versions).
* Prevents uncontrolled cache growth.
* **Fixed**: `pkg-clean-cache` and `disk-cleanup` (see [Disk health and space](#disk-health-and-space)) both now run `paccache -r -k2` (keeps 2 versions). Previously `disk-cleanup` called bare `paccache -r` with no `-k` flag, falling back to paccache's own default (3 versions), so the two scripts touched the same cache with different retention counts — now unified.

### Orphaned packages

* Reviewed periodically.
* Removal is **explicit and separated** from detection.

### Package integrity

* Installed files are checked to detect corruption or inconsistencies.

### Associated scripts

* `pkg/pkg-clean-cache`
* `pkg/pkg-check-orphans`
* `pkg/pkg-clean-orphans`

---

## Keyring management

Keyrings are critical to avoid signature errors during upgrades.

* Refresh is performed in a controlled manner.
* Integrated into full system updates.

**Known duplication**: `sys-full-update` runs its own inline keyring refresh (`pacman -Sy`, `pacman -S archlinux-keyring`, `pacman-key --init/--populate`) instead of calling the standalone `keyring-update` script below — they implement the same steps independently, so a change to one (e.g. `keyring-update`'s `--dry-run`/`--yes` flags) doesn't propagate to the other. **Fixed**: `mirrors-update` and `sys-full-update`'s inline `reflector` call previously used slightly different country lists (`mirrors-update` included `Worldwide` as a fallback, `sys-full-update` didn't) — both now use the same list.

### Associated scripts for keyring

* `keyring/keyring-update`

---

## Logs and disk usage (journald)

### Objectives

* Prevent uncontrolled log growth.
* Maintain visibility into real disk usage.

### Policy

* Periodic inspection of log size.
* Manual or automated cleanup by size or time.

### Associated scripts for logs

* `log/log-usage`
* `log/log-vacuum`

---

## Services and timers (systemd)

### Services

* Audit failed services.
* Identify problematic or unnecessary units.

### Timers

* Review active timers.
* Detect redundant or misconfigured scheduled tasks.

### Associated scripts for systemd

* `systemd/system-health`
* `systemd/timer-audit`

---

## Btrfs maintenance

> **Note:** Snapshots, scrub, and `btrfs-grub` are automated and **explicitly excluded** from this plan.

### Objectives for Btrfs

* Monitor real data and metadata usage.
* Perform safe maintenance actions only.

### Associated scripts for Btrfs

* `btrfs/btrfs-maintain`

  * Runs a light balance (`-dusage=75 -musage=75`) and defragments `/var/log`, `/var/cache`, `/home` — none of which are snapshotted subvolumes, so this is safe with respect to snapshot space usage.
  * Does **not** take a snapshot before or after running. If you want a rollback point before a maintenance pass, create one manually first: `sudo snapper -c root create -d "pre-btrfs-maintain"`.
* `btrfs/btrfs-disk-usage`

---

## Disk health and space

### Disk health (SMART)

* Periodic SMART status checks.
* Early detection of physical disk failures.

### Disk space

* Monitor usage thresholds.
* Alert when critical limits are reached.

### Cleanup

* Safe cleanup of unnecessary files: user cache (`~/.cache`), trash, and pacman cache.
* No automatic snapshot is taken before or after — `disk-cleanup` runs directly with no confirmation prompt when called from `sys-maintain`. If you want a rollback point, create one manually first: `sudo snapper -c root create -d "pre-disk-cleanup"`.

### Associated scripts for disk health and space

* `disk/disk-health-check`
* `disk/disk-space-monitor`
* `disk/disk-cleanup`

---

## Scripts architecture

All scripts live in a version-controlled repository with a clear structure:

```bash
Linux-config-and-apps/
│
├── configs/home/.local/bin/        # User system scripts (source of truth)
│   ├── sys/
│   ├── pkg/
│   ├── keyring/
│   ├── log/
│   ├── systemd/
│   ├── btrfs/
│   └── disk/
│
└── .gitignore
```

### Principles

* `configs/home/.local/bin/` is the **single source of truth**.
* `~/.local` is a single top-level symlink pointing into `configs/home/.local/` (see `Docs/architecture.md#dotfiles`), so anything placed under `configs/home/.local/bin/` is live under `~/.local/bin/` automatically — no per-script symlink or install step needed.
* `~/.local/bin` is included in the user `PATH`.
* No critical script lives outside the repository.
* New scripts start from `configs/home/.local/bin/script-template.sh`, which all current scripts derive from — it provides the standard logging functions, header, and the commented sudo self-elevation / `REAL_HOME` patterns.

---

## Expected outcome

With this structure:

* Maintenance becomes **predictable and reproducible**.
* Each action has a clear, isolated script.
* The system remains healthy with minimal friction.
* Everything is auditable, versionable, and extensible.

---

## Final Script Architecture Diagram

```bash
Linux-config-and-apps/
│
├── configs/home/.local/bin/        # User system scripts (source of truth, live under ~/.local/bin via symlink)
│
│   ├── sys/                        # System updates & global maintenance
│   │   ├── sys-update              # Standard system update (pacman -Syu)
│   │   ├── sys-full-update         # Full system update (keyrings, mirrors, AUR via paru)
│   │   └── sys-maintain            # Periodic system-wide maintenance orchestrator
│   │
│   ├── pkg/                        # Package management & integrity
│   │   ├── pkg-clean-cache         # Clean pacman cache (paccache retention policy)
│   │   ├── pkg-check-orphans       # Detect orphaned packages
│   │   ├── mirrors-update          # Update mirror list safely
│   │   └── pkg-clean-orphans       # Remove orphaned packages safely
│   │
│   ├── keyring/                    # Pacman keyring management
│   │   └── keyring-update          # Update / refresh archlinux-keyring
│   │
│   ├── log/                        # Journald & log management
│   │   ├── log-usage               # Inspect journald disk usage
│   │   └── log-vacuum              # Cleanup logs by size/time policy
│   │
│   ├── systemd/                    # systemd services & timers
│   │   ├── system-health           # Audit failed or unhealthy services
│   │   └── timer-audit             # Review active systemd timers
│   │
│   ├── btrfs/                      # Btrfs maintenance (no snapshots / scrub)
│   │   ├── btrfs-maintain          # Routine safe Btrfs maintenance
│   │   └── btrfs-disk-usage        # Detailed Btrfs space & metadata usage
│   │
│   └── disk/                       # Disk health & space monitoring
│       ├── disk-health-check       # SMART status & disk health
│       ├── disk-space-monitor      # Monitor disk usage & thresholds
│       └── disk-cleanup            # Safe disk cleanup (cache, trash, logs)
│
└── .gitignore
```

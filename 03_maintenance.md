# System maintenance

Create a comprehensive maintenance plan for the system, covering updates, package management, logs, services, Btrfs maintenance, and disk health.
Create also bassic scripts/commands and specific ones to automate and facilitate these tasks.

## Updates Policy

Create a first command/script to update the system, and document when to use it.

Create a second command/script to update the system at a bigger scale (keyrings, mirrors, AUR, etc), and document when to use it.

### Commands/Scripts for Updates

* `sys-update`: Standard system update command/script.
* `sys-full-update`: Full system update command/script for major updates.

## Package Management and Cleanup

Define a cache cleanup policy using `paccache`.
Review orphaned packages regularly and verify the integrity of installed packages.

### Commands/Scripts for Package Management and Cleanup

* `pkg-clean-cache`: Cleans package cache based on defined policy.
* `pkg-check-orphans`: Checks for orphaned packages.
* `pkg-clean-orphans`: Removes orphaned packages.
* `pkg-health`: Verifies the integrity of installed packages.

## Keyrings Check

Create a command/script to check and update keyrings as needed.

### Commands/Scripts for Keyrings

* `keyring-check`: Checks and updates keyrings.
* `keyring-update`: Updates keyrings if necessary.

## Logs and Disk Usage

Monitor journald usage and set maximum log sizes. Document manual log cleanup procedures.

### Commands/Scripts to Manage Logs

* `log-usage`: Reviews journald log usage.
* `log-vacuum`: Cleans up logs to free disk space.

## Services and Timers (systemd)

Audit failed services and active timers. Disable unnecessary services to optimize system performance.

### Commands/Scripts for Services and Timers

* `system-health`: Checks the health of system services.
* `timer-audit`: Audits active systemd timers.

## Btrfs Maintenance

Establish a routine for Btrfs maintenance, this excludes snapshots, scrub and btrfs-grub because I have it automaticed.

### Commands/Scripts for Btrfs Maintenance

* `btrfs-maintain`: Performs routine Btrfs maintenance tasks.
  * **requires pre and post snapshots**.
* `btrfs-check`: Checks Btrfs filesystem integrity.
* `btrfs-disk-usage`: Reviews Btrfs disk usage statistics.

## Disk Health and Space

Set up regular checks for disk health using SMART tools and monitor disk space usage to prevent issues.

### Commands/Scripts for Disk Health and Space

* `disk-health-check`: Monitors disk health using SMART.
* `disk-space-monitor`: Monitors disk space usage and alerts when thresholds are reached.
* `disk-cleanup`: Cleans up unnecessary files to free disk space.
  * Requires pre and post snapshots.

## Scripts and Commands

The Scripts and commands mentioned above should be created into executable files or shell scripts, it will be placed in a dedicated scripts direcotory `~/.local/bin/` for easy access and to mantain organization.

The scripts directory should be added to the user's PATH environment variable to allow execution from any location in the terminal.

Its arqitecture should be as follows:

```bash
~/.local/bin/
│
├── sys/                        # System updates & global health
│   ├── sys-update              # Standard system update (pacman -Syu)
│   └── sys-full-update         # Full update (keyrings, mirrors, AUR, etc.)
│
├── pkg/                        # Package management & integrity
│   ├── pkg-clean-cache         # paccache cleanup (defined retention policy)
│   ├── pkg-check-orphans       # Detect orphaned packages
│   ├── pkg-clean-orphans       # Remove orphaned packages
│   └── pkg-health              # Verify installed packages integrity
│
├── keyring/                    # Keyring management
│   ├── keyring-check           # Verify keyring status and validity
│   └── keyring-update          # Update and reinitialize keyrings if needed
│
├── log/                        # Journald & logs
│   ├── log-usage               # Inspect journald disk usage
│   └── log-vacuum              # Cleanup logs based on size/time policy
│
├── systemd/                    # systemd services & timers
│   ├── system-health           # Audit failed or unhealthy services
│   └── timer-audit             # Review active systemd timers
│
├── btrfs/                      # Btrfs maintenance (no snapshots/scrub)
│   ├── btrfs-maintain          # Routine Btrfs maintenance checks
│   ├── btrfs-check             # Read-only filesystem integrity check
│   └── btrfs-disk-usage        # Detailed Btrfs space and metadata usage
│
├── disk/                       # Disk health & space
│   ├── disk-health-check       # SMART status and disk health
│   ├── disk-space-monitor      # Monitor disk usage and thresholds
│   └── disk-cleanup            # Cleanup unnecessary files safely
│
└── README.md                   # (Optional) Scripts overview & usage policy
```

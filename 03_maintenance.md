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
* `btrfs-check`: Checks Btrfs filesystem integrity.
* `btrfs-disk-usage`: Reviews Btrfs disk usage statistics.

## Disk Health and Space

Set up regular checks for disk health using SMART tools and monitor disk space usage to prevent issues.

### Commands/Scripts for Disk Health and Space

* `disk-health-check`: Monitors disk health using SMART.
* `disk-space-monitor`: Monitors disk space usage and alerts when thresholds are reached.
* `disk-cleanup`: Cleans up unnecessary files to free disk space.

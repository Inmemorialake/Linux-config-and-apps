# Btrfs and snapshots

Btrfs (B-tree File System) is a modern copy-on-write (COW) file system for Linux that offers advanced features such as snapshots, subvolumes, and built-in RAID support. One of its most powerful features is the ability to create snapshots, which are read-only or read-write copies of the file system at a specific point in time.

In my system, I use Btrfs for the root file system and take advantage of its snapshot capabilities to maintain system backups and facilitate easy rollbacks in case of issues.

In my system configuration, I have set up Btrfs with the following features:

* Snapshots only for the root file system (not for user data)
* Rollback from GRUB (pre-boot, system inconsistent → functional system)
* Avoid snapshots of volatile or large data
* Maintain clear separation between:
  * system state
  * user data
  * variable data

I did use Garuda Linux as inspiration for this setup, particularly their approach to Btrfs snapshots and system management, mainly because I used Garuda Linux before switching to Arch Linux.

## Subvolumes

Btrfs allows you to create subvolumes, which are separate file system trees within a Btrfs file system. Subvolumes can be used to organize data and manage snapshots more effectively.

This is a diagram of the subvolumes I have created in my Btrfs setup:

```bash
| Subvolume    | Mount point   | Snapshots |
|--------------|---------------|-----------|
| @            | /             | ✅ Yes    |
| @home        | /home         | ❌ No     |
| @snapshots   | /.snapshots   | ❌ No     | # Used to store snapshots, but not snapshotted itself
| @var_log     | /var/log      | ❌ No     |
| @var_cache   | /var/cache    | ❌ No     |
| @tmp         | /tmp          | ❌ No     |

```

In my case I only take snapshots of the `@` subvolume, which contains the system files. The other subvolumes are excluded from snapshots to avoid capturing volatile or large data that changes frequently. This are the only things that I'm getting into btrfs snapshots: I don't make btrfs or snapshots of kernel or bootloader files, user data, or variable data.

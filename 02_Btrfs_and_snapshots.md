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

In my case I only take snapshots of the `@` subvolume, which contains the system files. The other subvolumes are excluded from snapshots to avoid capturing volatile or large data that changes frequently. This are the only things that I'm getting into btrfs snapshots: Snapshots include the root filesystem (/) and therefore system binaries and kernel modules, but exclude the EFI System Partition (/boot) and the bootloader itself.

## Btrfs setup and initial configuration

As part of my installation process, I have a script that sets up the Btrfs subvolumes and configures the system to use them. This script is executed during the installation process to ensure that the Btrfs file system is properly configured from the start.

[Installation Guide, Btrfs subvolumes section](01_Installation.md#18-create-btrfs-subvolumes)

Now that I have my Btrfs setup, I can take advantage of its snapshot capabilities to maintain system backups and facilitate easy rollbacks in case of issues.

## Snapper

To manage Btrfs snapshots, I use a tool called Snapper. Snapper is a command-line utility that simplifies the process of creating, managing, and restoring Btrfs snapshots.

At first, I have to install Snapper:

```bash
sudo pacman -S snapper
```

Now, I need to create a Snapper configuration for my root subvolume:

```bash
sudo snapper -c root create-config /
```

This command creates a Snapper configuration named "root" for the root subvolume. The configuration file is located at `/etc/snapper/configs/root`, his content is as follows:

```ini
# subvolume to snapshot
SUBVOLUME="/"

# filesystem type
FSTYPE="btrfs"


# btrfs qgroup for space aware cleanup algorithms
QGROUP=""


# fraction or absolute size of the filesystems space the snapshots may use
SPACE_LIMIT="0.5"

# fraction or absolute size of the filesystems space that should be free
FREE_LIMIT="0.2"


# users and groups allowed to work with config
ALLOW_USERS=""
ALLOW_GROUPS=""

# sync users and groups from ALLOW_USERS and ALLOW_GROUPS to .snapshots
# directory
SYNC_ACL="no"


# start comparing pre- and post-snapshot in background after creating
# post-snapshot
BACKGROUND_COMPARISON="yes"


# run daily number cleanup
NUMBER_CLEANUP="yes"

# limit for number cleanup
NUMBER_MIN_AGE="3600"
NUMBER_LIMIT="10"
NUMBER_LIMIT_IMPORTANT="5"


# create hourly snapshots
TIMELINE_CREATE="no"

# cleanup hourly snapshots after some time
TIMELINE_CLEANUP="no"

# limits for timeline cleanup
TIMELINE_MIN_AGE="3600"
TIMELINE_LIMIT_HOURLY="0"
TIMELINE_LIMIT_DAILY="5"
TIMELINE_LIMIT_WEEKLY="2"
TIMELINE_LIMIT_MONTHLY="1"
TIMELINE_LIMIT_QUARTERLY="0"
TIMELINE_LIMIT_YEARLY="0"


# cleanup empty pre-post-pairs
EMPTY_PRE_POST_CLEANUP="yes"

# limits for empty pre-post-pair cleanup
EMPTY_PRE_POST_MIN_AGE="3600"
```

With this configuration, Snapper will create and manage snapshots for the root subvolume, while adhering to the specified limits and cleanup policies.

To create a snapshot using Snapper, I can use the following command:

```bash
sudo snapper -c root create -d "Snapshot description"
```

This command creates a new snapshot of the root subvolume with the specified description.

To list all snapshots managed by Snapper, I can use:

```bash
sudo snapper -c root list
```

To restore a snapshot, I can use the following command:

```bash
sudo snapper -c root rollback <snapshot_number>
```

>Replace `<snapshot_number>` with the number of the snapshot you want to restore. This command will roll back the root subvolume to the specified snapshot.
> Note: Although `snapper rollback` can be executed from a running system,
> the recommended and safest workflow is to boot into a snapshot via GRUB
> and then perform a rollback from a known-good state.

## Grub integration

To enable rollback from GRUB, I need to install the `grub-btrfs` package:

```bash
sudo pacman -S grub-btrfs
```

After installing `grub-btrfs`, I need to enable its systemd service to automatically update the GRUB menu with available Btrfs snapshots:

```bash
sudo systemctl enable --now grub-btrfsd.service
```

Now I can update the GRUB configuration to include the Btrfs snapshots:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

With this setup, I can now select a Btrfs snapshot from the GRUB menu during boot, allowing me to roll back to a previous system state if needed.

## Package snapshots

Whit snap-pac I can create snapshots automatically before and after package operations (install, upgrade, remove) using Pacman. This allows me to easily roll back to a previous system state if a package operation causes issues.

To install snap-pac, I can use the following command:

```bash
sudo pacman -S snap-pac
```

Now, snap-pac is integrated with Pacman, and it will automatically create snapshots before and after package operations.

## Snapshot types

This system uses the following snapshot types:

* **pre/post snapshots**  
  Automatically created by `snap-pac` before and after pacman transactions.

* **manual snapshots**  
  Created explicitly by the user before risky operations.

* **important snapshots**  
  Snapshots marked with `userdata=important=yes`, excluded from automatic cleanup
  and intended to represent known stable system states.

## Conclusion

By using Btrfs with Snapper and GRUB integration, I have a robust system for managing snapshots and rolling back to previous states when necessary. This setup provides an additional layer of protection for my system, allowing me to recover from potential issues quickly and easily.

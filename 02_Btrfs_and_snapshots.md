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

In my case I only take snapshots of the `@root` subvolume, which contains the system files. The other subvolumes are excluded from snapshots to avoid capturing volatile or large data that changes frequently. This are the only things that I'm getting into btrfs snapshots: I don't make btrfs or snapshots of kernel or bootloader files, user data, or variable data.

### Creating subvolumes (post-installation)

This section describes how the Btrfs subvolumes were created **after the base system was already installed**.
This approach avoids reinstalling the system while still achieving a clean and structured Btrfs layout.

> ⚠️ **Important**
> These steps must be performed from a live environment (Arch ISO or similar), because the root filesystem cannot be safely restructured while mounted as `/`.

#### 1. Boot into a live environment

Boot using the Arch Linux installation ISO and gain root access.

Ensure the system disk is **not mounted automatically**.

#### 2. Mount the top-level Btrfs filesystem

Mount the Btrfs partition **without specifying a subvolume**, in order to access the top-level (`subvolid=5`):

```bash
mount -o subvolid=5 /dev/nvme0n1p3 /mnt
```

> Replace `/dev/nvme0n1p3` with your actual Btrfs partition.

At this point, `/mnt` represents the **top-level of the Btrfs filesystem**, not the current system root.

#### 3. Create the subvolumes

Create the desired subvolumes:

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_cache
btrfs subvolume create /mnt/@tmp
```

Each subvolume is independent and can be mounted separately.

#### 4. Migrate existing data into subvolumes

Mount the current system root temporarily:

```bash
mount /dev/nvme0n1p3 /mnt_old
```

Then move the data into their corresponding subvolumes:

```bash
mv /mnt_old/* /mnt/@/
mv /mnt_old/home /mnt/@home
mv /mnt_old/var/log /mnt/@var_log
mv /mnt_old/var/cache /mnt/@var_cache
mv /mnt_old/tmp /mnt/@tmp
```

> This preserves permissions, ownerships, and system state.

#### 5. Mount subvolumes properly

Unmount everything:

```bash
umount -R /mnt_old
umount -R /mnt
```

Now mount the system using the new subvolume layout:

```bash
mount -o subvol=@ /dev/nvme0n1p3 /mnt
mkdir -p /mnt/{home,.snapshots,var/log,var/cache,tmp}

mount -o subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o subvol=@snapshots /dev/nvme0n1p3 /mnt/.snapshots
mount -o subvol=@var_log /dev/nvme0n1p3 /mnt/var/log
mount -o subvol=@var_cache /dev/nvme0n1p3 /mnt/var/cache
mount -o subvol=@tmp /dev/nvme0n1p3 /mnt/tmp
```

#### 6. Update `/etc/fstab`

Chroot into the system:

```bash
arch-chroot /mnt
```

Edit `/etc/fstab` and define the subvolumes explicitly:

```fstab
UUID=xxxx  /              btrfs  subvol=@,compress=zstd,noatime  0 0
UUID=xxxx  /home          btrfs  subvol=@home,compress=zstd,noatime  0 0
UUID=xxxx  /.snapshots    btrfs  subvol=@snapshots,compress=zstd,noatime  0 0
UUID=xxxx  /var/log       btrfs  subvol=@var_log,noatime  0 0
UUID=xxxx  /var/cache     btrfs  subvol=@var_cache,noatime  0 0
UUID=xxxx  /tmp           btrfs  subvol=@tmp,noatime  0 0
```

> `compress=zstd` is intentionally **not used** on volatile directories.

#### 7. Final checks

Exit chroot, unmount, and reboot:

```bash
exit
umount -R /mnt
reboot
```

After rebooting, verify:

```bash
mount | grep btrfs
btrfs subvolume list /
```

---

### Design rationale (summary)

* Only `@` (system root) is snapshotted
* `/home` and `/var` are excluded to avoid:

  * snapshot bloat
  * inconsistent rollbacks
* `.snapshots` exists solely as a **snapshot container**
* This layout is compatible with:

  * `snapper`
  * GRUB rollback
  * manual recovery

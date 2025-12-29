# My system's installation Guide

This document provides a step-by-step guide to installing and configuring my system from scratch. It covers the installation of Arch Linux, setting up the Btrfs filesystem with subvolumes, installing the KDE Plasma desktop environment, and configuring various system components.

## Installation Guide

This process is guided by the [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide) and adapted to my specific setup.

## Steps

### 1. Pre-Installation

#### 1.1 Prepare Installation Media

Download the latest Arch Linux ISO and create a bootable USB drive, in my case i did use Ventoy.

#### 1.2 Boot from Installation Media

Boot your computer from the USB drive.

#### 1.3 Set the console keyboard layout and font

Set the console keyboard layout and font to Spanish_latinamerican (the one i use bc i am from Colombia):

```bash
loadkeys la-latin1
```

In my case i did not change the font, but if you want to change it you can use the following command:

```bash
setfont [the font you want to use]
```

#### 1.4 Set Up Networking

Ensure you have an active internet connection. You can use `iwctl` for wireless connections or `ip` commands for wired connections.

```bash
iwctl
```

Then inside iwctl prompt:

```bash
device list
```

Usually the device is named wlan0, then:

```bash
station wlan0 scan
station wlan0 get-networks
station wlan0 connect YOUR_SSID
```

It will ask for the wifi password, enter it and you should be connected.
Then you can exit iwctl prompt by typing:

```bash
exit
```

And you can check your connection with:

```bash
ping archlinux.org
```

If you are using a wired connection, it should be active by default. You can check it with:

```bash
ping archlinux.org
```

If you get responses, your internet connection is working.

#### 1.5 Update System Clock

Use timedatectl(1) to ensure the system clock is synchronized

```bash
timedatectl
```

If the "NTP synchronized" field is set to "no", enable it with:

```bash
timedatectl set-ntp true
```

You can set your timezone with the following command (replace REGION and CITY with your actual timezone):

```bash
timedatectl set-timezone REGION/CITY
```

And verify the change with:

```bash
timedatectl
```

If everything is correct, proceed to the next step.

#### 1.6 Partition the Disk

Use `cfdisk` to create the necessary partitions, in my case I started whit a clean nvme disk (/dev/nvme0n1 or the name it has in your system).

```bash
cfdisk /dev/nvme0n1
```

Create the following partitions:

- EFI System Partition (ESP): 512 MiB or more, Type: EFI System
- Swap Partition: 8 GiB (or as needed), Type: Linux swap
- Root Partition: Remaining space (or the size you want, in my case I gave Linux 170 GiB and left the rest for other uses), Type: Linux filesystem

#### 1.7 Format the Partitions

Format the partitions as follows (the names may vary depending on your disk and partitioning scheme):

```bash
mkfs.fat -F32 /dev/nvme0n1p1          # Format EFI System Partition
mkswap /dev/nvme0n1p2                  # Format Swap Partition
mkfs.btrfs /dev/nvme0n1p3               # Format Root Partition
```

#### 1.8 Mount the Filesystems

Mount the root partition:

```bash
mount /dev/nvme0n1p3 /mnt
```

Mount the EFI System Partition:

```bash
mount /dev/nvme0n1p1 /mnt/boot/efi --mkdir
```

Enable the swap partition:

```bash
swapon /dev/nvme0n1p2
```

### 2. Installation

#### 2.1 Select Mirrors

Edit the mirrorlist to prioritize faster mirrors. You can use `reflector` to do this automatically:

First, install reflector if it's not already available:

```bash
pacman -Sy reflector
```

Then, run the following command to update the mirrorlist (replace `YOUR_COUNTRY` with your actual country):

```bash
reflector --country YOUR_COUNTRY --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

Replace `YOUR_COUNTRY` with your actual country.

#### 2.2 Install Base System

Install the base system and essential packages:

```bash
pacstrap /mnt base base-devel linux linux-firmware intel-ucode networkmanager nano git btrfs-progs grub
```

This command installs the base system along with additional packages like `networkmanager`, `nano`, `git`, `btrfs-progs`, and `grub`, this is my selection of packages, you can modify it as you want, but these are the ones i feel comfortable with.

### 3. Configure the System

#### 3.1 Generate fstab

Generate the fstab file to define how disk partitions, block devices, or remote filesystems are mounted into the filesystem:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

#### 3.2 Chroot into the New System

```bash
arch-chroot /mnt
```

#### 3.3 Set Timezone

Set your timezone (replace REGION and CITY with your actual timezone):

```bash
ln -sf /usr/share/zoneinfo/REGION/CITY /etc/localtime
hwclock --systohc
```

#### 3.4 Localization

To use the correct region and language specific formatting (like dates, currency, decimal separators), edit /etc/locale.gen and uncomment the UTF-8 locales you will be using.

Then generate the locales by running:

```bash
locale-gen
```

Create the locale.conf file, and set the LANG variable accordingly:

```bash
nano /etc/locale.conf
# Add the following line
LANG=en_US.UTF-8
```

If you set the console keyboard layout, make the changes persistent in vconsole.conf:

```bash
nano /etc/vconsole.conf
# Add the following line
KEYMAP=la-latin1 # or the layout you want
```

#### 3.5 Set Hostname

Choose a hostname for your system and set it:

```bash
echo "myhostname" > /etc/hostname # Replace "myhostname" with your desired hostname
```

#### 3.6 Initramfs

Regenerate the initramfs:

```bash
mkinitcpio -P
```

#### 3.7 Set Root Password

Set the root password:

```bash
passwd
```

Now you can set the root password to whatever you want.

#### 3.8 Install Bootloader

Install GRUB bootloader:

```bash
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

In this case, I am using UEFI boot mode. If you are using BIOS, the installation command will be different, also im using GRUB as bootloader, you can choose another one if you want.

#### 3.9 Reboot

Now, the installation is complete. Exit the chroot environment, unmount the partitions(optional), and reboot:

```bash
exit
umount -R /mnt
swapoff -a
reboot
```

### 4. Post-Installation

After rebooting, you can log in as root and start installing and configuring additional packages and the desktop environment as per your requirements.
In my case, after rebooting I proceed to set up the Nvidia drivers (also for prime-run), KDE Plasma desktop environment, and other tools and applications that I use regularly.

#### 4.1 Enable NetworkManager

Enable NetworkManager to manage network connections:

```bash
systemctl enable NetworkManager
systemctl start NetworkManager
```

#### 4.2 Set Up User Account

Create a new user account and set a password:

```bash
useradd -m -G wheel username  # Replace "username" with your desired username
passwd username
```

#### 4.3 Set Up Nvidia Drivers (if applicable)

In my case, I have an NVIDIA RTX 3050 GPU, so I install the necessary drivers for Optimus support:

- Intel iGPU handles the desktop and Wayland session
- NVIDIA GPU stays powered off by default
- Applications can be offloaded using `prime-run`
- This setup maximizes battery life while preserving performance when needed

```bash
sudo pacman -S mesa lib32-mesa intel-media-driver vulkan-intel lib32-vulkan-intel nvidia-open nvidia-utils lib32-nvidia-utils nvidia-prime
```

This command installs the required packages for NVIDIA Optimus support, now is important to create the following file:

```bash
sudo nano /etc/modprobe.d/nvidia.conf
# Add the following lines to enable NVIDIA DRM modeset
options nvidia NVreg_PreserveVideoMemoryAllocations=1
options nvidia_drm modeset=1
```

Now is **very important** the mkinitcpio, in to the line MODULES=() you have to add the following modules:

```bash
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

Then regenerate the initramfs:

```bash
sudo mkinitcpio -P
```

Now we have to enable the **nvidia-drm kms**:

```bash
sudo nano /etc/default/grub
```

Find the line starting with GRUB_CMDLINE_LINUX_DEFAULT and add `nvidia-drm.modeset=1` to the parameters. It should look something like this:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=7 nvidia-drm.modeset=1"
```

(Here you can also add other parameters you want, like `quiet` to reduce boot messages, splash to show a splash screen during boot or use a different loglevel; even delete them or make it a minor number to reduce verbose).

Then update GRUB configuration:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

and redo the mkinitcpio:

```bash
sudo mkinitcpio -P
```

In my case, **I want Nvidia to be used only when I use `prime-run`**, so I configured it that way.

```bash
sudo nano /etc/modprobe.d/nvidia-power.conf
# Add the following line to disable NVIDIA by default
options nvidia NVreg_DynamicPowerManagement=0x02
```

Regenerate the initramfs again:

```bash
sudo mkinitcpio -P
```

Just in case, also the grub configuration:

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

If you want to test if everything is working correctly, you can use the following command to run an application using the NVIDIA GPU(of course it should be used only after installing a desktop environment and a graphical application):

```bash
prime-run [application] # Replace [application] with the name of the application you want to run
```

If everything is set up correctly, the application should run using the NVIDIA GPU, to see if it is working you can use:

```bash
nvidia-smi
```

This command should show you the NVIDIA GPU usage and confirm that the drivers are working properly.

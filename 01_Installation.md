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

#### 1.8 Create Btrfs Subvolumes

Mount the root partition temporarily:

```bash
mount /dev/nvme0n1p3 /mnt
```

Create the Btrfs subvolumes:

```bash
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@var_log
btrfs subvolume create /mnt/@var_cache
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@tmp
```

Unmount the root partition:

```bash
umount /mnt
```

Mount the root subvolume:

```bash
mount -o subvol=@ /dev/nvme0n1p3 /mnt
```

Now create the necessary directories for the other subvolumes and mount them:

```bash
mkdir -p /mnt/{home,.snapshots,var/log,var/cache,tmp}
mount -o subvol=@home /dev/nvme0n1p3 /mnt/home
mount -o subvol=@snapshots /dev/nvme0n1p3 /mnt/.snapshots
mount -o subvol=@var_log /dev/nvme0n1p3 /mnt/var/log
mount -o subvol=@var_cache /dev/nvme0n1p3 /mnt/var/cache
mount -o subvol=@tmp /dev/nvme0n1p3 /mnt/tmp
```

#### 1.9 Mount the other Filesystems

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
pacman -S reflector
```

Then, run the following command to update the mirrorlist (replace `YOUR_COUNTRY` with your actual country):

```bash
reflector --country YOUR_COUNTRY --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

Replace `YOUR_COUNTRY` with your actual country.

#### 2.2 Install Base System

Install the base system and essential packages:

```bash
pacstrap /mnt base base-devel linux linux-firmware intel-ucode networkmanager nano git btrfs-progs grub efibootmgr
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
LANG=es_CO.UTF-8 # or the locale you want
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

#### 3.9 Enable Multilib (if needed)

If you plan to use 32-bit applications on your 64-bit system, enable the multilib repository:

```bash
nano /etc/pacman.conf
# Uncomment the following lines
[multilib]
Include = /etc/pacman.d/mirrorlist
```

Then update the package database:

```bash
pacman -Sy # Update package database, this is a partial upgrade, so be careful and only do it when you have enabled multilib or made changes to pacman.conf
```

Here you have enabled the multilib repository, but in this file you can enable other repositories if you want and make other changes to pacman.conf according to your needs (in my case I touched the miscelaneos section, I activated the colors for pacman and ILoveCandy, because I like it).

#### 3.10 Reboot

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
pacman -S sudo
EDITOR=nano visudo
# descomentar:
%wheel ALL=(ALL:ALL) ALL
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

Now is **very important** the mkinitcpio:

```bash
sudo nano /etc/mkinitcpio.conf
# In the MODULES section, add the following modules:
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
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

In my case, **I want Nvidia to be used only when I use `prime-run`**, so I configured it that way.

```bash
sudo nano /etc/modprobe.d/nvidia-power.conf
# Add the following line to disable NVIDIA by default
options nvidia NVreg_DynamicPowerManagement=0x02
```

Regenerate the initramfs and update GRUB:

```bash
sudo mkinitcpio -P
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

#### 4.4 Install KDE Plasma Desktop Environment

Install KDE Plasma and SDDM display manager (remember, this is my choice, you can choose another DE and DM if you want, also, this is a minimal installation of KDE Plasma, you can install more packages if you want):

##### 4.4.1 Install SDDM and configure it

```bash
sudo pacman -S sddm
sudo nano /etc/sddm.conf

# Add the following lines
[General]
DisplayServer=wayland

[Wayland]
CompositorCommand=kwin_wayland
```

This configuration sets SDDM to use Wayland with the KWin compositor and is necessary for KDE Plasma on Wayland(who is now the default session in KDE Plasma).

Then enable SDDM to start at boot:

```bash
sudo systemctl enable sddm.service
sudo systemctl status sddm
reboot
```

##### 4.4.2 Install KDE Plasma and essential applications

Move to a TTY (for example, Ctrl + Alt + F2), log in with your user, and install KDE Plasma and essential applications:

```bash
sudo pacman -S plasma-desktop # Minimal Plasma installation
sudo pacman -S dolphin konsole kate spectacle kdeconnect # Essential KDE applications
sudo pacman -S plasma-pa plasma-nm powerdevil # Essential Plasma components
sudo pacman -S ksystemlog kcalc filelight partitionmanager # Additional useful KDE applications
reboot
```

After rebooting, you should be greeted by the SDDM login screen. Log in to your new KDE Plasma desktop environment.

#### 4.5 Additional Configurations

From here, you can proceed to customize your KDE Plasma environment, install additional applications, and configure system settings according to your preferences.

##### 4.5.1 Git Configuration

If you use Git, you can set up your user information:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Now you can start using Git with your configured identity, in case you need to set up your github keys(I use tokens(classic ones) for authentication), you can generate the token from your github account settings and then use it when prompted for a password during git operations. To avoid entering the token every time, you can use a credential helper like `git-credential-manager` and the `git-credential-libsecret` to store your credentials securely, in my case i use `git-credential-libsecret` and kwallet integration (because I use KDE Plasma).

```bash
sudo pacman -S kwalletmanager libsecret # Assure you have these packages installed
git config --global credential.helper /usr/lib/git-core/git-credential-libsecret # Configure git to use libsecret
git config --global --get credential.helper # Verify the configuration
```

Now Git will use the libsecret helper to store your credentials securely in your KDE wallet.

If you don't understand why I needed to set this up, it's because I use GitHub for version control and I wanted a secure way to manage my credentials without having to enter them every time I interact with remote repositories.

Documentation for `GCM` can be found [in the git-credential-manager repository](https://github.com/git-ecosystem/git-credential-manager/tree/main).

##### 4.5.2 OS-prober (if dual booting)

If you are dual-booting with another operating system, you may want to enable `os-prober` to detect other OS installations during GRUB configuration.

```bash
sudo pacman -S os-prober
sudo nano /etc/default/grub
# Uncomment or add the following line
GRUB_DISABLE_OS_PROBER=false
# Then update GRUB configuration
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## Conclusion

This installation guide provides a comprehensive overview of setting up my system from scratch. Feel free to adapt the steps to suit your specific needs and preferences. Enjoy your new Arch Linux system with KDE Plasma!

In a personal note, this installation process took me several attempts to perfect, I like the challenge of setting up my system exactly how I want it, and I hope this guide helps others who wish to do the same. Happy computing!

## Notes

- btrfs subvolumes and snapshots setup will be covered in a separate document.
- If you encounter any issues during the installation or configuration process, refer to the [Arch Wiki](https://wiki.archlinux.org/) for troubleshooting and additional information.
- If you want to improve your battery life, consider installing `power-profiles-daemon` and configuring it according to your needs, also the KDE Powerdevil settings can help you manage power consumption effectively.

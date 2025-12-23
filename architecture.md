# Architecture Overview

This document provides an overview of the architecture of my system, detailing its main components, it will be updated regularly to reflect any changes or improvements.

## Components

```ASCII
Arch Linux (base)
│
├── Kernel: linux
│
├── Filesystem: Btrfs
│   ├── @        → /
│   ├── @home    → /home
│   ├── @snapshots
│   └── @log / @cache (opcional)
│
├── Bootloader: GRUB + grub-btrfs
│
├── Desktop: KDE Plasma 6
│   └── Wayland session
│
├── GPU:
│   ├── Intel iGPU (default)
│   └── NVIDIA RTX 3050 (Optimus / prime-run)
│
├── Audio: PipeWire + WirePlumber
│
├── Network: NetworkManager
│
└── Userland:
    ├── fish
    ├── starship (nuevo)
    ├── terminal (a decidir)
    └── dotfiles versionados
```

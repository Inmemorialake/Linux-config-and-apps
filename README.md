# Linux-config-and-apps

Full configuration of my Arch Linux + KDE Plasma system: installation, Btrfs with snapshots, firewall, rice, terminal, gaming, and the maintenance scripts I use daily.

This repository **lives inside `$HOME`**, it is not an external copy. A handful of top-level symlinks point from `$HOME` into `configs/home/` inside the repo (`~/.config`, `~/.local`, `~/.gitconfig`, `~/.fonts.conf`), so the tracked files *are* the live configuration — there is no sync or copy step. Full detail in [`Docs/architecture.md`](Docs/architecture.md#dotfiles).

## Documentation

| Document | Content |
|---|---|
| [`Docs/architecture.md`](Docs/architecture.md) | System overview: hardware, stack, security, reproducibility |
| [`Docs/01_Installation.md`](Docs/01_Installation.md) | Arch Linux installation from scratch, Btrfs, NVIDIA Optimus, KDE Plasma |
| [`Docs/02_Btrfs_and_snapshots.md`](Docs/02_Btrfs_and_snapshots.md) | Subvolumes, Snapper, rollback from GRUB |
| [`Docs/03_firewall.md`](Docs/03_firewall.md) | UFW, per-service rules (KDE Connect, Docker, Tailscale, Samba) |
| [`Docs/04_rice.md`](Docs/04_rice.md) | KDE, SDDM, and GRUB theming |
| [`Docs/05_Terminal.md`](Docs/05_Terminal.md) | Fish, Starship, Konsole, btop, and the CLI tool stack |
| [`Docs/06_Gaming.md`](Docs/06_Gaming.md) | Steam, Proton-GE, Heroic, GameMode, MangoHud, zram |
| [`Docs/maintenance.md`](Docs/maintenance.md) | System maintenance plan and the scripts that implement it |

## Structure

```
Linux-config-and-apps/
├── configs/
│   ├── home/          # = $HOME (via symlinks: .config, .local, .gitconfig, .fonts.conf)
│   ├── grub/           # Vendored GRUB themes
│   └── sddm/           # Vendored SDDM themes
└── Docs/               # All documentation
```

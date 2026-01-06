# 🧭 System TODO-List (Post-install, Arch + Btrfs)

## ✅ Estado actual (baseline confirmado)

* [x] Arch Linux base instalado
* [x] Btrfs con subvolúmenes bien definidos (`@`, `@home`, `@snapshots`, etc.)
* [x] Snapper configurado para `/`
* [x] Snapshots automáticos con pacman (snap-pac)
* [x] GRUB + grub-btrfs (rollback desde GRUB)
* [x] NVIDIA Optimus funcionando
* [x] KDE Plasma operativo
* [x] Red, usuarios, sudo, git OK

---

## 1️⃣ Btrfs: mantenimiento y salud (PRIORIDAD ALTA)

### 1.1 Scrub periódico

* [x] Habilitar scrub automático
* [x] Verificar estado con `btrfs scrub status`

```bash
sudo systemctl enable --now btrfs-scrub@-.timer
```

---

### 1.2 Balance (manual, documentado)

* [ ] Documentar cuándo hacer balance
* [ ] Crear comando/script para balance seguro

```bash
sudo btrfs balance start -dusage=75 -musage=75 /
```

---

### 1.3 Verificación de espacio

* [x] Comando estándar para revisar uso
* [ ] Documentarlo

```bash
btrfs filesystem usage /
```

---

## 2️⃣ Snapper: políticas finales de snapshots

### 2.1 Política clara

* [ ] Definir qué es un snapshot **normal**
* [ ] Definir qué es un snapshot **importante**
* [ ] Definir cuándo se crean manualmente

---

### 2.2 Limpieza automática (verificar)

* [ ] Confirmar que `snapper-cleanup.timer` borra snapshots
* [ ] Verificar límites reales (`NUMBER_LIMIT`, `IMPORTANT`)
* [ ] Forzar limpieza de prueba

```bash
sudo snapper cleanup number
```

---

### 2.3 Rollback consciente

* [ ] Documentar rollback desde GRUB
* [ ] Documentar rollback desde CLI
* [ ] Advertencias claras (qué se pierde, qué no)

---

## 3️⃣ Scripts personalizados ⭐ (AUTOMATIZACIÓN)

### 3.1 Infraestructura de scripts

* [ ] Elegir ubicación (`~/.local/bin` o `/usr/local/bin`)
* [ ] Asegurar que esté en `$PATH`
* [ ] Convención de nombres clara

---

### 3.2 Scripts de snapshots

* [ ] `snap-create` → snapshot normal
* [ ] `snap-important` → snapshot importante
* [ ] `snap-list` → lista legible
* [ ] `snap-clean` → limpieza manual

---

### 3.3 Scripts de sistema

* [ ] `system-pre-upgrade`
* [ ] `system-post-upgrade`
* [ ] `system-status`
* [ ] (opcional) `system-health`

---

### 3.4 Documentación de scripts

* [ ] Qué hace cada uno
* [ ] Cuándo usarlo
* [ ] Ejemplos reales

---

## 4️⃣ Backups reales (NO snapshots)

> Snapshots ≠ backups.

### 4.1 Elegir estrategia

* [ ] `btrfs send | receive` **o**
* [ ] `restic` / `borg`

---

### 4.2 Destino externo

* [ ] Disco USB / NAS / nube
* [ ] Prueba de restauración

---

### 4.3 Automatización mínima

* [ ] Script de backup
* [ ] (Opcional) timer semanal

---

## 5️⃣ Seguridad básica (sin paranoia)

* [ ] firewall (ufw o firewalld)
* [ ] revisar servicios activos
* [ ] ssh solo si se usa

---

## 6️⃣ Ergonomía y calidad de vida

* [ ] aliases útiles
* [ ] prompt informativo
* [ ] historial saneado
* [ ] logs mínimos

---

## 7️⃣ Rice (ÚLTIMO)

* [ ] Tema KDE
* [ ] Iconos
* [ ] Fuentes
* [ ] Animaciones
* [ ] Wallpaper
* [ ] Exportar configuración

---

## 8️⃣ Documentación final

* [ ] Guía de instalación ✔️
* [ ] Guía Btrfs + Snapper ✔️
* [ ] Guía de scripts personalizados
* [ ] Checklist de mantenimiento
* [ ] README general del sistema

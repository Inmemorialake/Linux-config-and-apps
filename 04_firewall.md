# Firewall and Network Security

This document covers the firewall configuration and network security setup for my Arch Linux system. It includes UFW (Uncomplicated Firewall) configuration, security policies, and integration with services like Docker, Tailscale, and KDE Connect.

---

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Initial Configuration](#initial-configuration)
- [Service-Specific Rules](#service-specific-rules)
- [Management Commands](#management-commands)
- [Troubleshooting](#troubleshooting)
- [Security Best Practices](#security-best-practices)
- [Advanced Configuration](#advanced-configuration)

---

## Overview

UFW (Uncomplicated Firewall) is a frontend for `iptables`/`nftables` that simplifies firewall management on Linux systems. It provides a user-friendly interface to configure network security rules without sacrificing power or flexibility.

### My Configuration Philosophy

- **Default deny incoming**: Block all incoming connections unless explicitly allowed
- **Default allow outgoing**: Allow all outgoing connections (applications can connect freely)
- **Service-specific rules**: Only open ports/interfaces needed for specific services
- **Minimal logging**: Disabled for better performance (can be enabled for debugging)
- **Zero impact on performance**: Properly configured UFW has negligible overhead

---

## Installation

Install UFW from the official repositories:

```bash
sudo pacman -S ufw
```

Verify installation:

```bash
ufw --version
```

---

## Initial Configuration

### Basic Setup

```bash
# Reset UFW (clean slate)
sudo ufw --force reset

# Set default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Disable logging (better performance)
sudo ufw logging off

# Enable UFW
sudo ufw --force enable

# Enable systemd service (start on boot)
sudo systemctl enable --now ufw

# Verify status
sudo ufw status verbose
```

### Expected Output

```bash
Status: active
Logging: off
Default: deny (incoming), allow (outgoing), disabled (routed)
```

---

## Service-Specific Rules

### KDE Connect

KDE Connect allows integration between my phone and PC (file sharing, notifications, clipboard sync, etc.).

**Ports needed**: 1714-1764 (TCP and UDP)

```bash
sudo ufw allow 1714:1764/udp comment "KDE Connect"
sudo ufw allow 1714:1764/tcp comment "KDE Connect"
```

**Verification**:

- Open KDE Connect on phone and PC
- Both devices should appear and pair successfully
- Test file transfer and notifications

---

### Docker

Docker needs access to its internal networks to function properly. By default, Docker bypasses UFW rules, but we configure UFW to explicitly allow Docker traffic for consistency.

**Networks to allow**:

- `172.17.0.0/16` - Docker default bridge network
- `172.18.0.0/16` - Docker custom networks
- `docker0` interface - Docker bridge interface

```bash
sudo ufw allow from 172.17.0.0/16 comment "Docker default network"
sudo ufw allow from 172.18.0.0/16 comment "Docker custom networks"
sudo ufw allow in on docker0 comment "Docker bridge interface"
```

**Important Notes**:

- Docker manipulates iptables directly, so it works even without these rules
- These rules make the configuration explicit and easier to audit
- If you expose Docker containers to the internet, configure port-specific rules
- Docker Compose networks use custom subnets (usually 172.18+)

**Verification**:

```bash
# Test Docker connectivity
docker run --rm -p 8080:80 nginx:alpine

# Access from browser
curl http://localhost:8080
# Should return nginx welcome page

# Clean up
docker stop $(docker ps -q)
```

---

### Tailscale

Tailscale creates a secure VPN mesh network between my devices. It uses the WireGuard protocol and manages its own encrypted tunnels.

**Interface**: `tailscale0` (virtual network interface)

```bash
sudo ufw allow in on tailscale0 comment "Tailscale VPN"
sudo ufw allow out on tailscale0 comment "Tailscale VPN"
```

**Why this works**:

- Tailscale creates a virtual network interface (`tailscale0`)
- All Tailscale traffic goes through this interface
- By allowing traffic on this interface, we trust all devices in our Tailscale network
- Tailscale handles authentication and encryption separately

**Verification**:

```bash
# Check Tailscale status
tailscale status

# Verify interface exists
ip a show tailscale0

# Test connectivity to another Tailscale device
ping [tailscale-device-ip]
```

---

### SSH (Optional)

If you use SSH to access your system remotely, enable this rule with rate limiting to prevent brute-force attacks.

```bash
sudo ufw limit 22/tcp comment "SSH (rate limited)"
```

**Rate limiting**:

- Denies connections from an IP that attempts 6+ connections in 30 seconds
- Helps prevent brute-force attacks
- No impact on legitimate usage

**Security recommendations**:

- Use SSH keys instead of passwords
- Change default port (security through obscurity)
- Consider fail2ban for additional protection
- Disable root login in `/etc/ssh/sshd_config`

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy to remote server
ssh-copy-id user@remote-server
```

---

## Samba (Optional)

Samba allows sharing files with Windows and Linux devices using the SMB/CIFS protocol.  
In this configuration, Samba is **disabled by default** and only enabled temporarily when file sharing is required.

### Usage Model

- **Client mode (default)**:  
  This system connects to external Samba servers (NAS, Windows PCs, other Linux machines).
  - No UFW rules required
  - Outgoing connections are allowed by default
  - Samba services do not need to be running

- **Server mode (optional, temporary)**:  
  This system shares files with other devices on the local network.
  - Requires explicit UFW rules
  - Services should be started only when needed
  - Access is restricted to the local network (LAN-only)

### Client Mode (Default — No Firewall Changes Required)

When connecting **to** a remote Samba server, this system acts as a client.

- All connections are **outgoing**
- `ufw default allow outgoing` already permits this traffic
- No Samba-related firewall rules are necessary

**Examples**:

- Connecting to a NAS
- Accessing a Windows shared folder
- Mounting a remote SMB share with `mount.cifs`
- Browsing SMB shares via Dolphin

[x]Works with UFW enabled  
[x]Works without any Samba UFW rules  
[x]Secure by default

### Server Mode (Optional — LAN Only)

Enable this section **only when this system needs to share files** with other devices.

#### UFW Configuration (Local Network Only)

Determine your local subnet first:

```bash
ip route | grep default
```

Example subnet:

```text
192.168.0.0/24
```

Allow Samba **only from the local network**:

```bash
sudo ufw allow from 192.168.0.0/24 to any app Samba comment "Samba (LAN only)"
```

#### Services Management

Start Samba services only when required:

```bash
sudo systemctl start smb nmb
```

Stop them when file sharing is no longer needed:

```bash
sudo systemctl stop smb nmb
```

#### Verification

```bash
# Verify firewall rules
sudo ufw status | grep Samba

# Verify services
systemctl status smb nmb
```

From another device on the same network:

- Access `\\hostname` or `\\IP`
- Verify read/write access as configured

#### Additional Hardening (Recommended)

Restrict Samba at the application level as well.

Edit `/etc/samba/smb.conf`:

```ini
[global]
   interfaces = lo wlan0
   bind interfaces only = yes
   hosts allow = 192.168.0.0/24
```

This provides defense-in-depth:

- UFW filters incoming network traffic
- Samba rejects unauthorized hosts at the application level

### Cleanup (Return to Secure Default State)

After finishing file sharing:

```bash
sudo systemctl stop smb nmb
sudo ufw delete allow from 192.168.0.0/24 to any app Samba
```

This restores the system to its default, secure posture:

- No Samba services running
- No Samba ports exposed
- Outgoing SMB connections remain unaffected

### Security Notes

- Samba should **never** be exposed to the internet
- Always restrict access to trusted networks only
- Prefer temporary activation over permanent exposure
- Use strong user authentication and avoid guest shares unless necessary
- Combine UFW rules with Samba internal restrictions for best security

---

## Management Commands

### Viewing Status

```bash
# Basic status
sudo ufw status

# Verbose status (shows policies)
sudo ufw status verbose

# Numbered list (useful for deletion)
sudo ufw status numbered
```

### Adding Rules

```bash
# Allow specific port
sudo ufw allow 3000/tcp comment "Development server"

# Allow port range
sudo ufw allow 8000:8100/tcp comment "Dev range"

# Allow from specific IP
sudo ufw allow from 192.168.1.100 comment "Trusted device"

# Allow from subnet
sudo ufw allow from 192.168.1.0/24 comment "Local network"

# Allow specific port from specific IP
sudo ufw allow from 192.168.1.100 to any port 22
```

### Deleting Rules

```bash
# Show numbered rules
sudo ufw status numbered

# Delete by number
sudo ufw delete [number]

# Delete by rule specification
sudo ufw delete allow 3000/tcp
```

### Enabling/Disabling

```bash
# Enable firewall
sudo ufw enable

# Disable firewall (rules preserved)
sudo ufw disable

# Reload rules (after manual changes)
sudo ufw reload

# Reset (delete all rules)
sudo ufw --force reset
```

---

## Troubleshooting

### General Diagnostic Steps

1. **Check if UFW is active**:

   ```bash
   sudo ufw status
   systemctl status ufw
   ```

2. **Check for blocked connections** (if logging enabled):

   ```bash
   sudo journalctl -u ufw -n 50
   sudo grep UFW /var/log/syslog  # If using syslog
   ```

3. **Test by temporarily disabling**:

   ```bash
   sudo ufw disable
   # Test your application
   sudo ufw enable
   ```

### Common Issues

#### KDE Connect Not Connecting

**Symptoms**: Phone doesn't see PC or vice versa

**Solutions**:

```bash
# Verify rules exist
sudo ufw status | grep 1714

# Verify both devices on same network
ip a | grep -E "192.168|10\."

# Temporarily disable to test
sudo ufw disable
# Try KDE Connect
sudo ufw enable

# If it works when disabled, rules are missing
sudo ufw allow 1714:1764/udp
sudo ufw allow 1714:1764/tcp
sudo ufw reload
```

#### Docker Containers Can't Communicate

**Symptoms**: Containers can't reach each other or host

**Solutions**:

```bash
# Check Docker interface exists
ip a show docker0

# Verify Docker rules
sudo ufw status | grep docker

# Add explicit Docker rules
sudo ufw allow in on docker0
sudo ufw allow from 172.17.0.0/16
sudo ufw reload

# Restart Docker
sudo systemctl restart docker
```

#### Tailscale Devices Unreachable

**Symptoms**: Can't ping or connect to Tailscale devices

**Solutions**:

```bash
# Check Tailscale interface
ip a show tailscale0

# Verify UFW rules
sudo ufw status | grep tailscale

# Add Tailscale rules
sudo ufw allow in on tailscale0
sudo ufw allow out on tailscale0
sudo ufw reload

# Restart Tailscale
sudo systemctl restart tailscaled
```

#### Application Can't Bind to Port

**Symptoms**: "Address already in use" or "Permission denied"

**Solutions**:

```bash
# Check what's using the port
sudo ss -tulpn | grep :[port]

# This is usually NOT a firewall issue
# UFW doesn't prevent applications from binding to ports
# It only filters incoming connections from network

# If you can access locally but not remotely:
sudo ufw allow [port]/tcp
```

---

## Security Best Practices

### 1. Principle of Least Privilege

Only open ports that are actively used:

```bash
# Bad: Opening unnecessary ports
sudo ufw allow 1:65535/tcp  # DON'T DO THIS

# Good: Specific ports only
sudo ufw allow 80/tcp comment "HTTP"
sudo ufw allow 443/tcp comment "HTTPS"
```

### 2. Use Comments

Always comment your rules for future reference:

```bash
sudo ufw allow 3000/tcp comment "React dev server"
sudo ufw allow from 192.168.1.50 comment "Raspberry Pi"
```

### 3. Limit SSH Access

Use rate limiting and consider IP restrictions:

```bash
# Rate limit SSH
sudo ufw limit 22/tcp

# Or restrict to specific IPs
sudo ufw allow from 192.168.1.0/24 to any port 22
```

### 4. Regular Audits

Periodically review your rules:

```bash
# Review all rules
sudo ufw status numbered

# Remove unused rules
sudo ufw delete [number]
```

### 5. Logging (When Needed)

Enable logging temporarily for debugging:

```bash
# Enable logging
sudo ufw logging on

# Check logs
sudo journalctl -u ufw -f

# Disable when done (better performance)
sudo ufw logging off
```

### 6. Backup Your Configuration

UFW rules are stored in `/etc/ufw/`:

```bash
# Backup
sudo tar -czf ufw-backup-$(date +%Y%m%d).tar.gz /etc/ufw/

# Restore
sudo tar -xzf ufw-backup-*.tar.gz -C /
sudo ufw reload
```

---

## Advanced Configuration

### Custom Application Profiles

Create custom application profiles in `/etc/ufw/applications.d/`:

```bash
sudo nano /etc/ufw/applications.d/myapp

# Add:
[MyApp]
title=My Custom Application
description=My application server
ports=3000,3001/tcp
```

```bash
# Use the profile
sudo ufw allow MyApp
```

### Network Interface-Specific Rules

```bash
# Allow only on specific interface
sudo ufw allow in on eth0 to any port 80

# Deny on specific interface
sudo ufw deny in on wlan0 to any port 22
```

### IP-Specific Rules

```bash
# Allow from specific IP to specific port
sudo ufw allow from 203.0.113.1 to any port 22

# Deny specific IP
sudo ufw deny from 203.0.113.100
```

### Logging Levels

```bash
# Different logging levels
sudo ufw logging off        # No logging
sudo ufw logging low        # Log blocked packets
sudo ufw logging medium     # Low + invalid packets
sudo ufw logging high       # Medium + all packets (very verbose)
sudo ufw logging full       # Everything (debug mode)
```

---

## Configuration Files

### Main Configuration

- **Rules**: `/etc/ufw/user.rules` (IPv4), `/etc/ufw/user6.rules` (IPv6)
- **Config**: `/etc/ufw/ufw.conf`
- **Defaults**: `/etc/default/ufw`
- **Applications**: `/etc/ufw/applications.d/`

### Systemd Service

```bash
# Service file
/usr/lib/systemd/system/ufw.service

# Check status
systemctl status ufw

# View logs
journalctl -u ufw
```

---

## Quick Reference

### Essential Commands

```bash
# Status
sudo ufw status verbose

# Enable/Disable
sudo ufw enable
sudo ufw disable

# Add rule
sudo ufw allow [port]/[protocol]

# Delete rule
sudo ufw status numbered
sudo ufw delete [number]

# Reload
sudo ufw reload

# Reset
sudo ufw --force reset
```

### My Active Rules

```bash
# View current configuration
sudo ufw status numbered

# Expected rules:
# 1. KDE Connect (1714:1764 TCP/UDP)
# 2. Docker (172.17.0.0/16, 172.18.0.0/16, docker0)
# 3. Tailscale (tailscale0 in/out)
```

---

## Additional Resources

- [Arch Wiki - Uncomplicated Firewall](https://wiki.archlinux.org/title/Uncomplicated_Firewall)
- [UFW Man Page](https://manpages.ubuntu.com/manpages/focal/man8/ufw.8.html)
- [Docker and UFW](https://github.com/chaifeng/ufw-docker)

---

## Maintenance

### Weekly Tasks

```bash
# Check firewall status
sudo ufw status verbose

# Check for failed services
systemctl status ufw
```

### Monthly Tasks

```bash
# Review rules and remove unused ones
sudo ufw status numbered

# Backup configuration
sudo tar -czf ~/backups/ufw-$(date +%Y%m%d).tar.gz /etc/ufw/
```

### After System Changes

- Added new network service? → Add firewall rule
- Removed service? → Remove corresponding rule
- Changed network setup? → Verify interface-based rules

---

## Notes

- UFW rules persist across reboots (managed by systemd)
- Logging is disabled by default for better performance
- Docker bypasses UFW by default (by design)
- Tailscale handles its own encryption and authentication
- All outgoing connections are allowed (applications can connect freely)
- Incoming connections are blocked unless explicitly allowed

---

## Conclusion

This firewall configuration provides a good balance between security and usability. It protects against unauthorized network access while allowing necessary services to function properly. The configuration is minimal, maintainable, and has negligible performance impact.

For most use cases, this setup is sufficient. Advanced scenarios (DMZ, multiple network zones, complex routing) may require more sophisticated tools like `nftables` directly or dedicated firewall distributions.

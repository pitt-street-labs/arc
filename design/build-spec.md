# ARCbuild — System Builder & OS Provisioning

> Standardized OS images, utility suites, and provisioning infrastructure for ARC-networked systems

## Purpose

When new hardware joins the ARC network — whether scavenged, donated, or pre-staged — it needs a known-good operating system, standard tools, and ARC network integration. **ARCbuild** is the provisioning system that takes bare hardware from power-on to ARC-connected workstation in under 30 minutes.

Additionally, the ARC community needs a curated **software library** — the digital equivalent of a shareware CD-ROM collection — available offline for any platform. These are the tools people need to be productive without internet access.

---

## ARCspec Hardware Tiers

Every machine that joins the ARC network is classified into a hardware tier. The tier determines which ARCbuild profile (OS image, package set, resource allocation) it receives.

| Tier | Name | Specs | Example Hardware | OS Profile |
|------|------|-------|-----------------|------------|
| T0 | Micro | ARM SBC, 1-4 GB RAM, SD card | Raspberry Pi 4/5, Pine64 | ARCbuild-Micro (Alpine/Raspbian) |
| T1 | Edge | x86_64, 4-8 GB RAM, SSD | Toughbook CF-31, old laptops | ARCbuild-Edge (Fedora minimal) |
| T2 | Workstation | x86_64, 8-32 GB RAM, SSD | Desktop PCs, newer laptops | ARCbuild-Workstation (Fedora Workstation) |
| T3 | Server | x86_64, 32+ GB RAM, RAID/multi-disk | Rack servers, tower servers | ARCbuild-Server (Fedora Server) |
| T4 | GPU | T2/T3 + discrete GPU | Gaming PCs, workstations with GPU | ARCbuild-GPU (Fedora + CUDA/ROCm) |
| TW | Windows | x86_64, 8+ GB RAM | Pre-installed Windows PCs | ARCbuild-Windows (scripted config) |
| TM | macOS | Apple Silicon or Intel Mac | MacBook, iMac, Mac Mini | ARCbuild-Mac (config profile) |

---

## ARCbuild Profiles

### ARCbuild-Micro (Raspberry Pi / ARM SBC)

```
ARCbuild-Micro (~4 GB SD image)
├── Base: Raspberry Pi OS Lite (64-bit) or Alpine Linux
├── Network: DHCP on VLAN 20, auto-register with DNS
├── Services:
│   ├── Podman (container runtime)
│   ├── SSH server (key-based, enrolled in AD via SSSD)
│   ├── Prometheus node_exporter
│   └── Meshtastic daemon (if LoRa hardware detected)
├── ARCclient containers (pulled from Zot on first boot):
│   ├── Kiwix Serve (offline reference)
│   ├── CyberChef (data tools)
│   └── IT-Tools (utilities)
├── Tools: vim, tmux, htop, git, python3, gcc
└── Auto-config: Join AD domain, register with Authentik, report to Uptime Kuma
```

### ARCbuild-Edge (Toughbook / Field Laptop)

```
ARCbuild-Edge (~8 GB ISO)
├── Base: Fedora 43 minimal + Sway (lightweight Wayland compositor)
├── Network: NetworkManager, auto-DHCP, WPA3 WiFi, mesh support
├── Services:
│   ├── Podman (container runtime)
│   ├── SSH server (AD-enrolled)
│   ├── Prometheus node_exporter
│   ├── Avahi (mDNS for zero-conf mesh discovery)
│   └── Syncthing (file sync with ARC core when in range)
├── ARCclient containers (full set from Zot):
│   ├── Ollama CPU (1.5-3B model)
│   ├── Kiwix Serve + selected ZIMs
│   ├── Atlas (offline maps + local tiles)
│   ├── CyberChef, IT-Tools, Stirling-PDF
│   ├── LibreTranslate
│   └── Calibre-Web (field manuals)
├── Desktop apps:
│   ├── Firefox (offline, bookmarks to local services)
│   ├── QGIS (GIS analysis)
│   ├── Wireshark (network analysis)
│   ├── LibreOffice (documents)
│   └── KeePassXC (local credential store)
├── Field tools: gps-utils, meshtastic-cli, reticulum tools
└── Auto-config: AD domain join, Authentik enrollment, GPS/location services
```

### ARCbuild-Workstation (Desktop PC)

```
ARCbuild-Workstation (~12 GB ISO)
├── Base: Fedora 43 Workstation (GNOME)
├── Network: Full VLAN awareness, bonding support
├── All ARCbuild-Edge contents PLUS:
├── Development tools:
│   ├── VS Code (flatpak + offline VSIX extensions)
│   ├── Go, Python, C/C++, Rust toolchains
│   ├── Node.js, npm
│   ├── Podman, buildah, skopeo
│   └── GDB, Valgrind, strace
├── Desktop apps:
│   ├── GIMP (image editing)
│   ├── Inkscape (vector graphics)
│   ├── Audacity (audio)
│   ├── VLC (media player)
│   ├── Thunderbird (email — for post-collapse email if available)
│   ├── FreeCAD (3D modeling for print)
│   ├── KiCad (electronics/PCB design)
│   └── GNU Radio Companion (SDR)
├── Productivity:
│   ├── LibreOffice (full suite)
│   ├── Nextcloud Desktop Client
│   ├── XMPP client (Dino)
│   └── Element (Matrix client, if deployed)
└── Auto-config: AD domain join, Authentik SSO, printer discovery, display auto-detect
```

### ARCbuild-Server (Rack/Tower Server)

```
ARCbuild-Server (~6 GB ISO)
├── Base: Fedora 43 Server (no GUI)
├── Network: bonding, VLAN trunking, bridge interfaces
├── Services:
│   ├── Podman + Quadlet (production container management)
│   ├── Cockpit (web admin)
│   ├── SSH server (AD-enrolled)
│   ├── Prometheus node_exporter
│   ├── Podman exporter
│   ├── LUKS auto-unlock (via key file or manual)
│   └── Firewalld (zone-based, pre-configured for ARC VLANs)
├── Storage: LVM + LUKS, XFS, automated disk detection
├── Container platform: Pre-configured Zot pull-through to ARC registry
└── Auto-config: AD join, register with monitoring, configure Quadlet systemd units
```

### ARCbuild-GPU (GPU Workstation/Server)

```
ARCbuild-GPU (ARCbuild-Server + GPU extensions)
├── All ARCbuild-Server contents PLUS:
├── NVIDIA: nvidia-driver, nvidia-container-toolkit, CUDA 12
├── AMD: ROCm (if AMD GPU detected)
├── Pre-configured: Ollama with GPU acceleration
├── AI tools: llama.cpp (GPU build), whisper.cpp, stable-diffusion.cpp
└── Auto-detect: GPU vendor/model, install appropriate driver stack
```

### ARCbuild-Windows (Scripted Configuration)

Windows machines can't be reimaged without a license, so ARCbuild-Windows is a **configuration script** that transforms an existing Windows installation into an ARC-connected workstation.

```
ARCbuild-Windows (~2 GB package)
├── PowerShell bootstrap script (run as Administrator)
├── AD domain join
├── Software installation (via offline installers — no internet needed):
│   ├── VS Code + extensions
│   ├── Python 3
│   ├── Git for Windows
│   ├── PuTTY / WinSCP
│   ├── 7-Zip, Notepad++, VLC
│   ├── LibreOffice
│   ├── Wireshark
│   ├── KeePassXC
│   └── Podman Desktop (WSL2 backend)
├── Registry tweaks: disable telemetry, configure DNS, set NTP
├── Firewall rules: allow ARC VLAN traffic, block unnecessary outbound
└── Certificate trust: Install ExampleOrg Enterprise CA root cert
```

### ARCbuild-Mac (Configuration Profile)

macOS machines are configured via MDM-style profile or shell script.

```
ARCbuild-Mac (~1 GB package)
├── Shell script (run as admin)
├── Homebrew (offline cache):
│   ├── Core: git, python3, go, node, vim
│   ├── Cask: firefox, vs-code, libreoffice, vlc, wireshark, keepassxc
│   └── Tap: podman
├── Certificate trust: ExampleOrg Enterprise CA → System Keychain
├── DNS: Configure to use ARC DNS servers
├── Directory: AD bind via Directory Utility
└── Security: FileVault enable, firewall enable, disable analytics
```

---

## Software Library: ARC Utility Archive

A curated collection of **500-1000 essential utilities** organized by platform and category, stored offline. The digital equivalent of a shareware CD-ROM library — except every tool is vetted, scanned (Trivy + ClamAV), and documented.

### Storage Location

```
/media/labadmin/external-storage/arc-software-library/
├── windows/
│   ├── productivity/
│   ├── development/
│   ├── networking/
│   ├── security/
│   ├── system/
│   ├── multimedia/
│   └── utilities/
├── macos/
│   ├── homebrew-cache/     # Offline Homebrew bottles
│   └── installers/         # .dmg/.pkg files
├── linux/
│   ├── flatpak-repo/       # Offline Flatpak repository
│   ├── rpm-cache/          # Fedora RPM cache
│   └── appimage/           # Portable AppImage binaries
├── android/
│   └── → F-Droid Server (Server-1:8070, already operational, 1018 apps)
├── cross-platform/
│   ├── portable-apps/      # PortableApps.com collection
│   └── java-apps/          # Platform-independent .jar tools
└── manifests/
    ├── inventory.yaml       # Full catalog with SHA256 hashes
    ├── scan-results.json    # Trivy/ClamAV scan reports
    └── categories.md        # Human-readable category guide
```

### Windows Utility Collection (~200 GB estimated)

**Target: 500+ utilities organized by category.**

#### Productivity (50+)
| Software | Purpose | Size Est. |
|----------|---------|-----------|
| LibreOffice | Full office suite | 400 MB |
| Notepad++ | Text editor | 10 MB |
| SumatraPDF | PDF viewer | 15 MB |
| Obsidian | Knowledge management | 200 MB |
| Zotero | Reference management | 100 MB |
| draw.io Desktop | Diagramming | 150 MB |
| Calibre | Ebook management | 150 MB |
| Thunderbird | Email client | 100 MB |
| KeePassXC | Password manager | 30 MB |
| Joplin | Markdown notes | 200 MB |

#### Development (80+)
| Software | Purpose | Size Est. |
|----------|---------|-----------|
| VS Code | IDE | 300 MB |
| Git for Windows | Version control | 60 MB |
| Python 3 | Scripting/dev | 100 MB |
| Go | Systems programming | 200 MB |
| Node.js LTS | JavaScript runtime | 50 MB |
| MSYS2/MinGW | GCC toolchain for Windows | 500 MB |
| CMake | Build system | 50 MB |
| PuTTY | SSH client | 5 MB |
| WinSCP | SCP/SFTP client | 20 MB |
| Insomnia | REST API client | 200 MB |
| DB Browser for SQLite | Database tool | 30 MB |
| HxD | Hex editor | 5 MB |
| Process Explorer | System diagnostics | 5 MB |
| Dependency Walker | DLL analysis | 5 MB |
| Ghidra | Reverse engineering | 500 MB |
| x64dbg | Debugger | 30 MB |
| IDA Free | Disassembler | 100 MB |

#### Networking (40+)
| Software | Purpose | Size Est. |
|----------|---------|-----------|
| Wireshark | Packet analysis | 100 MB |
| Nmap/Zenmap | Network scanner | 30 MB |
| FileZilla | FTP/SFTP client | 30 MB |
| Angry IP Scanner | IP scanner | 10 MB |
| Advanced IP Scanner | LAN discovery | 20 MB |
| mRemoteNG | Multi-protocol remote | 30 MB |
| WinMTR | Traceroute/ping | 5 MB |
| Fiddler | HTTP debugger | 50 MB |
| cURL for Windows | HTTP client | 5 MB |

#### Security (40+)
| Software | Purpose | Size Est. |
|----------|---------|-----------|
| ClamWin | Antivirus | 200 MB |
| VeraCrypt | Disk encryption | 30 MB |
| GPG4Win | GPG encryption | 30 MB |
| Autoruns | Startup analysis | 5 MB |
| YARA | Pattern matching | 10 MB |
| Volatility | Memory forensics | 100 MB |
| NetworkMiner | PCAP analysis | 30 MB |
| HashCalc | File hashing | 5 MB |
| USBDeview | USB device audit | 2 MB |

#### System Utilities (80+)
| Software | Purpose | Size Est. |
|----------|---------|-----------|
| 7-Zip | Compression | 5 MB |
| Everything | File search | 5 MB |
| TreeSize | Disk usage | 10 MB |
| HWiNFO | Hardware info | 10 MB |
| CrystalDiskInfo | Disk health | 10 MB |
| CrystalDiskMark | Disk benchmark | 5 MB |
| CPU-Z | CPU info | 5 MB |
| GPU-Z | GPU info | 10 MB |
| Rufus | USB bootable media | 5 MB |
| Ventoy | Multi-boot USB | 20 MB |
| BleachBit | System cleaner | 20 MB |
| Sysinternals Suite | System tools (full) | 50 MB |
| ImgBurn | Disc burning | 10 MB |
| Recuva | File recovery | 10 MB |
| TestDisk/PhotoRec | Data recovery | 10 MB |
| Clonezilla Live | Disk cloning | 500 MB |

#### Multimedia (30+)
| Software | Purpose | Size Est. |
|----------|---------|-----------|
| VLC | Media player | 50 MB |
| Audacity | Audio editor | 50 MB |
| GIMP | Image editor | 300 MB |
| Inkscape | Vector graphics | 200 MB |
| OBS Studio | Screen recording | 300 MB |
| HandBrake | Video transcoding | 50 MB |
| FFmpeg | Media toolkit | 100 MB |
| Blender | 3D modeling | 500 MB |
| FreeCAD | CAD | 500 MB |
| KiCad | PCB design | 500 MB |

#### Science & Engineering (30+)
| Software | Purpose | Size Est. |
|----------|---------|-----------|
| GNU Octave | MATLAB alternative | 500 MB |
| Stellarium | Astronomy | 300 MB |
| QGIS | GIS mapping | 500 MB |
| GnuPlot | Data plotting | 30 MB |
| R + RStudio | Statistics | 500 MB |
| Scilab | Engineering math | 300 MB |
| KStars | Sky mapping | 200 MB |
| Celestia | Space simulation | 100 MB |

### macOS Utility Collection

**Homebrew offline cache:** Pre-download bottles for 200+ packages. Stored as tarball.

**Key .dmg installers (50+):** Firefox, VS Code, LibreOffice, VLC, Wireshark, GIMP, Inkscape, Audacity, HandBrake, KeePassXC, Calibre, QGIS, FreeCAD, Blender, OBS Studio, Thunderbird, iTerm2, Rectangle, AppCleaner, coconutBattery, DiskDrill.

### Linux Utility Collection

**Offline Flatpak repo:** Mirror 200+ Flatpak apps from Flathub. Stored as OSTree repo.

**AppImage collection:** 50+ portable binaries for key tools.

**RPM cache:** Full dependency tree for ARCbuild profiles. `dnf` offline install support.

---

## Provisioning Infrastructure

### G1: Netboot.xyz (PXE Boot Menu)

| Attribute | Value |
|-----------|-------|
| Image | `netbootxyz/netbootxyz:latest` |
| Target Node | Server-2 (or workstation) |
| Est. RAM | 256 MB |
| Est. Disk | 2 GB (boot assets) + ISOs |
| Ports | 69/UDP (TFTP), 3000/TCP (web UI) |

**Function:** PXE boot menu serving all ARCbuild ISOs. New hardware plugs into VLAN 20, PXE boots, selects profile, installs automatically.

**Boot menu:**
```
ARCbuild Provisioning Menu
─────────────────────────────
1. ARCbuild-Workstation (Fedora 43, full desktop)
2. ARCbuild-Edge (Fedora 43, lightweight field laptop)
3. ARCbuild-Server (Fedora 43, headless server)
4. ARCbuild-GPU (Fedora 43, server + GPU drivers)
5. ARCbuild-Micro (Raspberry Pi OS — SD card imaging only)
6. Clonezilla Live (disk cloning/imaging)
7. Kali Linux (security testing)
8. AlmaLinux 9 (alternative server OS)
9. ── Diagnostic Tools ──
10. Memtest86+ (RAM testing)
11. GParted Live (disk partitioning)
```

### G2: Clonezilla Server (Image Backup/Restore)

| Attribute | Value |
|-----------|-------|
| Type | ISO (not container) |
| Storage | external-storage or Server-2 NFS share |
| Function | Full-disk imaging for backup/restore/cloning |

**Golden images:** After ARCbuild installs and configures a system, Clonezilla captures a "golden image" that can be rapidly restored to identical or similar hardware.

### G3: Kickstart/Preseed Server

| Attribute | Value |
|-----------|-------|
| Type | HTTP server (nginx) serving Kickstart files |
| Target Node | Server-2 |
| Function | Automated OS installation profiles |

**Kickstart files:**
```
/var/www/kickstart/
├── arcbuild-workstation.ks
├── arcbuild-edge.ks
├── arcbuild-server.ks
├── arcbuild-gpu.ks
└── arcbuild-custom.ks.template
```

Each Kickstart file includes:
- Partitioning (LUKS + LVM + XFS)
- Package selection (per ARCspec tier)
- Post-install scripts (AD join, cert trust, monitoring agent, container runtime)
- Network configuration (DHCP on VLAN 20, DNS to ARC resolvers)
- User creation (local admin + AD-enrolled user accounts)

### G4: Offline Package Mirror

| Attribute | Value |
|-----------|-------|
| Type | nginx serving RPM/DEB repos |
| Target Node | Server-1 (co-locates with existing content servers) |
| Est. Disk | 100-200 GB |

**Mirrors:**
- Fedora 43 x86_64: `baseos`, `updates`, `appstream` (~60 GB)
- Fedora 43 aarch64: `baseos` only (~20 GB, for Raspberry Pi)
- Ubuntu 24.04 amd64: `main`, `universe` (~80 GB, for Android dev VM)
- PyPI mirror: Top 500 packages (~10 GB)
- npm mirror: Top 200 packages (~5 GB)
- Go module proxy: Cached modules (~5 GB)
- Cargo/crates.io: Top 100 crates (~2 GB)

---

## Provisioning Workflow

### New Hardware → ARC-Connected System

```
1. CLASSIFY — Identify hardware tier (T0-T4, TW, TM)
                ↓
2. BOOT    — PXE boot (T1-T4) or SD card flash (T0) or USB boot (TW/TM)
                ↓
3. INSTALL — Kickstart/preseed automates OS install
           — LUKS encryption with ARC master key
           — Packages from offline mirror
                ↓
4. CONFIG  — Post-install script:
           — AD domain join (via SSSD)
           — ExampleOrg Enterprise CA cert installed
           — Authentik enrollment
           — Monitoring agent (node_exporter, Podman exporter)
           — Container runtime (Podman) + Zot registry config
           — SSH key enrollment
                ↓
5. VERIFY  — Automated checklist:
           — [ ] Can resolve DNS (all 3 resolvers)
           — [ ] Can authenticate via Authentik SSO
           — [ ] Can pull containers from Zot
           — [ ] Monitoring agent reporting to Prometheus
           — [ ] Uptime Kuma check registered
           — [ ] LUKS encryption active
           — [ ] Firewall rules correct for VLAN
                ↓
6. REGISTER — Add to:
            — Portal services.yaml (if server)
            — Netbox (DCIM/IPAM)
            — Snipe-IT (asset management)
            — DNS (A record via AD-integrated DNS)
```

### Time Estimates

| Profile | Install Time | Config Time | Total |
|---------|-------------|-------------|-------|
| ARCbuild-Micro (SD flash) | 5 min | 3 min | ~8 min |
| ARCbuild-Edge | 10 min | 5 min | ~15 min |
| ARCbuild-Workstation | 15 min | 10 min | ~25 min |
| ARCbuild-Server | 10 min | 5 min | ~15 min |
| ARCbuild-GPU | 10 min | 15 min (driver compile) | ~25 min |
| ARCbuild-Windows (script) | N/A | 20 min | ~20 min |
| ARCbuild-Mac (script) | N/A | 15 min | ~15 min |

---

## Container Images to Preseed

| # | Service | Image | Purpose |
|---|---------|-------|---------|
| G1 | Netboot.xyz | `netbootxyz/netbootxyz:latest` | PXE boot menu |
| — | Code-Server | `linuxserver/code-server:latest` | Browser-based IDE (from ARC-DEV-ENVIRONMENTS.md) |
| — | Jupyter | `jupyter/datascience-notebook:latest` | Data science notebooks |
| — | Android SDK | `thyrlian/android-sdk:latest` | Headless Android builds |

**Note:** Code-Server, Jupyter, and Android SDK images should be preseeded into Zot alongside the G1 netboot.xyz image.

---

## Disk Budget

| Component | Est. Size | Location |
|-----------|-----------|----------|
| ARCbuild ISOs (all profiles) | ~50 GB | external-storage or Server-2 |
| Windows software library | ~50 GB | external-storage |
| macOS software library | ~20 GB | external-storage |
| Linux software library (Flatpak + AppImage + RPM) | ~30 GB | external-storage |
| Offline package mirrors (Fedora + Ubuntu + PyPI + npm) | ~200 GB | Server-1 |
| Golden images (Clonezilla, 5 profiles) | ~100 GB | external-storage |
| VSIX extension archive | ~2 GB | external-storage or Zot |
| **Total** | **~450 GB** | |

external-storage has 20 TB, currently ~4 TB used. This fits comfortably.

---

## Implementation Priority

| Priority | Component | Effort | Rationale |
|----------|-----------|--------|-----------|
| P1 | Kickstart files (Workstation + Server) | 1 day | Core provisioning — enables all downstream |
| P1 | Netboot.xyz container | 2 hours | PXE boot infrastructure |
| P1 | Offline RPM mirror (Fedora 43) | 4 hours | Enables air-gap installs |
| P2 | ARCbuild-Windows script | 4 hours | Windows machines need standardization |
| P2 | Software library curation (Windows top 200) | 2 days | Highest user demand |
| P2 | VSIX extension archive | 2 hours | Needed for code-server |
| P3 | Golden image capture (Clonezilla) | 4 hours | Rapid restore capability |
| P3 | Software library (macOS, Linux) | 1 day each | Lower priority platforms |
| P3 | ARCbuild-Mac script | 2 hours | Small user base |
| P4 | Flatpak offline mirror | 4 hours | Nice-to-have |
| P4 | PyPI/npm/Go mirrors | 4 hours | Dev-only |

---

## Relationship to Existing Projects

| Project | Relationship |
|---------|-------------|
| HAL (Bootable USB) | ARCbuild-Edge IS the HAL OS — HAL thumb drive = ARCbuild-Edge ISO + ARCclient containers + Kiwix ZIMs |
| Disaster Recovery | Clonezilla golden images integrate with DR restore workflow |
| F-Droid Server | Android software library already operational (1018 apps) |
| Zot Registry | Container distribution backbone for all ARCbuild profiles |
| PXE Boot (workstation) | Existing dnsmasq TFTP → migrate to Netboot.xyz for richer menu |
| Retro OS Museum | VMs already provisioned via similar process (QEMU/KVM) |
| Fedora CF-31 | Toughbook install project → becomes ARCbuild-Edge profile |

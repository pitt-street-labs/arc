# ARC Development Environments

> Software development, compilation, and SDK access for ARC community members

## Purpose

Post-collapse, the ARC community will need to:
1. **Maintain and extend ARC services** — bug fixes, configuration changes, new integrations
2. **Develop new tools** — custom automation, sensor integrations, data processing pipelines
3. **Train new developers** — education pipeline for the IT Admin role and cross-trained backups
4. **Build for field devices** — compile firmware for ESP32, Heltec LoRa, Raspberry Pi, Android
5. **Preserve software engineering knowledge** — development environments as living reference

## Architecture: Two-Tier Development Model

### Tier 1: Browser-Based IDEs (Containers)

Lightweight, multi-user, accessible from any ARC terminal via Guacamole or direct browser. No local installation required. Ideal for Python, Go, web development, scripting.

### Tier 2: Full Development VMs

Heavy-weight, single-user, accessed via Guacamole (HTML5 RDP/VNC). Required for Android Studio, cross-compilation, hardware debugging. Can be exported as ISOs for standalone deployment on capable hardware.

---

## Tier 1: Container-Based Development Environments

### F1: Code-Server (VS Code in Browser)

**Primary development environment for all languages.**

| Attribute | Value |
|-----------|-------|
| Image | `linuxserver/code-server:latest` |
| Target Node | Server-2 |
| Est. RAM | 1-2 GB per instance |
| Est. Disk | 5 GB base + project data |
| Access | Browser via `https://code.lab.example.com:8443` (Authentik SSO) |
| Languages | All — extensions install offline from VSIX archive |

**Included toolchains (baked into custom image):**
- **Go:** `go` 1.23+, `gopls`, `delve` debugger
- **Python:** `python3`, `pip`, `venv`, `pylint`, `black`, `debugpy`
- **C/C++:** `gcc`, `g++`, `gdb`, `make`, `cmake`, `clang`
- **Assembly:** `nasm`, `as` (GNU assembler), `objdump`, `gdb`
- **Rust:** `rustc`, `cargo` (optional — useful for systems programming)
- **Node.js:** `node`, `npm` (for web UI development)
- **Shell:** `bash`, `shellcheck`, `shfmt`

**VSIX Extension Archive:**
Pre-download 50-100 essential VS Code extensions into an offline VSIX mirror:
- Language support: Go, Python, C/C++, Rust, YAML, JSON, Markdown
- Tools: GitLens, Docker, Remote SSH, REST Client, Hex Editor
- Themes: minimal set (2-3)
- Linting: ESLint, Pylint, golangci-lint

**Multi-user model:** Each user gets their own code-server instance via Authentik SSO. Persistent home directories on Server-2 storage. Shared project repos via Gitea.

### F2: Jupyter Hub

**Data science, Python prototyping, machine learning notebooks.**

| Attribute | Value |
|-----------|-------|
| Image | `jupyter/datascience-notebook:latest` |
| Target Node | Server-2 (or workstation for GPU notebooks) |
| Est. RAM | 2-4 GB per instance |
| Est. Disk | 10 GB base + datasets |
| Access | Browser via Authentik SSO |
| Languages | Python, R, Julia |

**Use cases:**
- AI model evaluation and fine-tuning (connect to Ollama API)
- Sensor data analysis (MQTT → Jupyter pipeline)
- Medical data visualization (OpenEMR → Jupyter)
- Agricultural modeling (FarmOS → Jupyter)
- Training/education (Moodle assignments → Jupyter)

### F3: Android SDK Build Environment

**Container-based Android app compilation (no UI — headless builds).**

| Attribute | Value |
|-----------|-------|
| Image | `thyrlian/android-sdk:latest` |
| Target Node | Server-2 |
| Est. RAM | 4-8 GB |
| Est. Disk | 30 GB (SDK + build tools + Gradle cache) |
| Access | SSH or code-server terminal |

**Capabilities:**
- Compile custom Android apps for GrapheneOS/LineageOS devices
- Build F-Droid packages for local repository
- Modify Meshtastic Android client
- Custom ATAK plugins
- Gradle builds, APK signing, ADB debugging

**Limitation:** No Android emulator (requires KVM nested virtualization or bare metal). Use physical devices (Pixel 7 Pro) for testing.

### F4: Cross-Compilation Toolchain

**ARM64, RISC-V, ESP32 cross-compilation for embedded targets.**

| Attribute | Value |
|-----------|-------|
| Image | Custom Dockerfile (based on `library/fedora` or `library/ubuntu`) |
| Target Node | Server-2 |
| Est. RAM | 1-2 GB |
| Est. Disk | 5 GB |
| Access | code-server terminal or SSH |

**Toolchains included:**
- `aarch64-linux-gnu-gcc` — Raspberry Pi, ARM64 targets
- `arm-none-eabi-gcc` — Bare-metal ARM (STM32, nRF52)
- `xtensa-esp32-elf-gcc` — ESP32 (Heltec LoRa boards)
- `riscv64-linux-gnu-gcc` — RISC-V targets (future-proofing)
- `avr-gcc` — Arduino/ATmega (legacy)

**Use cases:**
- Custom Meshtastic firmware builds (Heltec V3 ESP32-S3)
- ESP32 sensor node firmware (IoT, weather stations, water sensors)
- Raspberry Pi system software and services
- LoRa radio firmware modifications
- Arduino-based sensor controllers

**Offline caches (pre-download while internet available):**

| Cache | Size | Contents |
|-------|------|----------|
| ESP-IDF framework | ~1.5 GB | Espressif IoT Development Framework (v5.x) |
| Arduino-ESP32 core | ~500 MB | Arduino framework for ESP32/S2/S3/C3 |
| PlatformIO packages | ~3 GB | Board definitions, toolchains, frameworks |
| Arduino libraries | ~500 MB | Top 200 Arduino libraries (sensors, displays, comms) |
| Raspberry Pi SDK | ~500 MB | Pi Pico SDK + ARM toolchain |

**PlatformIO integration:** VS Code extension in code-server handles all embedded targets from a single interface. Board config for ARC hardware:

```ini
; Heltec WiFi LoRa 32 V3 (ESP32-S3)
[env:heltec_v3]
platform = espressif32
board = heltec_wifi_lora_32_V3
framework = arduino

; Arduino Uno/Nano (ATmega328P)
[env:arduino_uno]
platform = atmelavr
board = uno
framework = arduino

; Raspberry Pi Pico (RP2040)
[env:pico]
platform = raspberrypi
board = pico
framework = arduino
```

**USB passthrough:** ESP32 and Arduino boards connect via USB serial. If hardware is plugged into Server-2, use `podman --device=/dev/ttyUSB0` for container access. If on workstation, use code-server on workstation directly or `ser2net` for remote serial over TCP.

---

## Tier 2: Full Development VMs

VMs provide complete desktop environments with GUI IDEs. Accessed via Guacamole (HTML5 RDP/VNC) from any ARC terminal, or exported as ISOs for standalone use.

### F5: ARCdev-Linux (Primary Development VM)

**Full Linux desktop with all development tools. The "developer workstation" VM.**

| Attribute | Value |
|-----------|-------|
| Base OS | Fedora Workstation 43 (matches Server-1/Server-2) |
| Hypervisor | KVM on Server-2 (or Server-1) |
| vCPUs | 4 |
| RAM | 16 GB |
| Disk | 100 GB (thin-provisioned) |
| Access | Guacamole (RDP via xrdp) |
| GPU Passthrough | None (CPU-only; workstation GPU reserved for inference) |

**Pre-installed software:**

| Category | Packages |
|----------|----------|
| **IDEs** | VS Code (flatpak), Vim/Neovim, Eclipse CDT |
| **Go** | go 1.23+, gopls, delve, golangci-lint |
| **Python** | python3, pip, venv, poetry, pylint, black, mypy |
| **C/C++** | gcc, g++, clang, gdb, make, cmake, autotools, valgrind |
| **Assembly** | nasm, yasm, GNU as, objdump, radare2 |
| **Rust** | rustc, cargo, clippy, rustfmt |
| **Java/Kotlin** | OpenJDK 21, Gradle, Maven |
| **Node.js** | node 22 LTS, npm, yarn |
| **Containers** | podman, buildah, skopeo (for building ARC service images) |
| **Debugging** | gdb, lldb, strace, ltrace, perf, valgrind |
| **Networking** | wireshark, tcpdump, nmap, curl, httpie |
| **Version Control** | git, git-lfs, tig |
| **Docs** | man-pages, POSIX spec, C11/C17 standard (offline) |
| **Databases** | sqlite3, psql client, mariadb client |

**Exportable as ISO:** Yes — Fedora Kickstart + custom package list = reproducible build. Can be burned to USB for standalone developer workstation on any x86_64 hardware.

### F6: ARCdev-Android (Android Studio VM)

**Full Android development environment with Android Studio IDE.**

| Attribute | Value |
|-----------|-------|
| Base OS | Ubuntu 24.04 LTS (Android Studio officially supports Ubuntu) |
| Hypervisor | KVM on Server-2 |
| vCPUs | 4 |
| RAM | 16 GB (Android Studio is memory-hungry) |
| Disk | 120 GB (SDK, emulator images, Gradle cache) |
| Access | Guacamole (RDP via xrdp) |

**Pre-installed software:**

| Component | Version |
|-----------|---------|
| Android Studio | Latest stable (Ladybug+) |
| Android SDK | API 34, 33, 30 (target range) |
| Build Tools | 34.0.0 |
| NDK | r26+ (for C/C++ native code) |
| Gradle | 8.x (bundled with Android Studio) |
| ADB/Fastboot | Platform tools |
| Kotlin | Bundled with Android Studio |
| Java | OpenJDK 17 (Android Studio requirement) |

**Key use cases:**
- Custom Meshtastic Android builds
- ATAK plugin development
- F-Droid app builds for local repo
- GrapheneOS app development
- Custom ARC mobile client (future)

**Note:** Android Emulator requires KVM (nested virtualization). If Server-2 doesn't support it, use physical devices only. Test with: `cat /sys/module/kvm_intel/parameters/nested`

### F7: ARCdev-Windows (Windows Development VM)

**Windows development for .NET, PowerShell, AD tooling.**

| Attribute | Value |
|-----------|-------|
| Base OS | Windows Server 2025 (already have license via AD DCs) |
| Hypervisor | KVM on Server-1 (co-locates with existing win11-tuned VM) |
| vCPUs | 4 |
| RAM | 8 GB |
| Disk | 80 GB |
| Access | Guacamole (native RDP) |

**Pre-installed software:**
- Visual Studio Community (C#/.NET)
- VS Code
- PowerShell 7
- RSAT (Remote Server Administration Tools)
- Python (Windows build)
- Git for Windows
- Windows SDK
- .NET SDK 8

**Use cases:**
- AD/GPO management scripts
- PowerShell automation for DC-1/DC-2
- Windows-specific tool development
- .NET applications for ARC services

---

## Access Model: Guacamole as Development Gateway

All development VMs and browser-based IDEs are accessible through **Apache Guacamole** (already planned as Tier E2d in ARC-CONTAINER-GAPS.md).

```
User → ARC Terminal (browser)
       → Authentik SSO (role check: ARC-Special or ARC-Admin)
       → Guacamole (HTML5)
           → code-server (container, browser-based VS Code)
           → ARCdev-Linux (RDP via xrdp)
           → ARCdev-Android (RDP via xrdp)
           → ARCdev-Windows (native RDP)
           → Jupyter Hub (browser redirect)
```

**Access control:**
- All development environments gated behind `ARC-Special` AD group (IT Admin role + cross-trained backups)
- Guacamole connection profiles configured per user/role
- Read-only access to Gitea repos for all roles; write access for IT Admin + authorized developers

---

## Downloadable ISO Strategy

For standalone deployment on capable hardware that joins the ARC network:

### ARCdev-Linux ISO

**Build process:** Fedora Kickstart file + offline package repo → bootable ISO via `lorax` / `livemedia-creator`

```
ARCdev-Linux ISO (~8 GB)
├── Fedora 43 base install
├── All development packages (Go, Python, C/C++, Rust, Node.js, Assembly)
├── VS Code + offline VSIX extensions
├── Offline man pages + language documentation
├── Git + pre-configured connection to Gitea
├── Podman + connection to Zot registry
└── Network auto-configuration (DHCP on VLAN 20)
```

**Distribution:**
- Stored in Zot as OCI artifact (non-container, but Zot supports generic artifacts)
- Downloadable from Portal as ISO file
- Burnable to USB (Ventoy or dd)
- PXE-bootable via netboot.xyz (F8)

### ARCdev-Android ISO

**Build process:** Ubuntu preseed + offline `.deb` repo + Android Studio installer → bootable ISO

```
ARCdev-Android ISO (~15 GB)
├── Ubuntu 24.04 base install
├── Android Studio + SDK + NDK
├── Gradle offline dependencies cache
├── ADB/Fastboot tools
├── Pre-configured Android SDK paths
└── Network auto-configuration
```

---

## Resource Summary

| Service | Type | Node | RAM | Disk | Image |
|---------|------|------|-----|------|-------|
| F1: Code-Server | Container | Server-2 | 2 GB/instance | 5 GB | `linuxserver/code-server` |
| F2: Jupyter Hub | Container | Server-2 | 4 GB | 10 GB | `jupyter/datascience-notebook` |
| F3: Android SDK (headless) | Container | Server-2 | 8 GB | 30 GB | `thyrlian/android-sdk` |
| F4: Cross-compile toolchain | Container | Server-2 | 2 GB | 5 GB | Custom (Fedora-based) |
| F5: ARCdev-Linux | VM | Server-2 | 16 GB | 100 GB | Fedora 43 Kickstart |
| F6: ARCdev-Android | VM | Server-2 | 16 GB | 120 GB | Ubuntu 24.04 preseed |
| F7: ARCdev-Windows | VM | Server-1 | 8 GB | 80 GB | Windows Server 2025 |
| **Containers total** | | | **16 GB** | **50 GB** | |
| **VMs total** | | | **40 GB** | **300 GB** | |

**Note:** VMs run on-demand, not always-on. Typical usage: 1-2 VMs active at a time. Server-2 has 276 GB RAM free — can support all containers + 2 VMs concurrently.

---

## VSIX Offline Extension Mirror

Pre-download and archive VS Code extensions for air-gap deployment:

```bash
# Build offline VSIX archive (run while internet available)
mkdir -p /media/labadmin/external-storage/arc-dev/vsix-mirror/
# Download ~50-100 extensions as .vsix files
# Store in Zot as OCI artifact or on external-storage
```

**Priority extensions (30 core):**
1. ms-python.python, ms-python.pylint, ms-python.black-formatter
2. golang.go
3. ms-vscode.cpptools, ms-vscode.cmake-tools
4. rust-lang.rust-analyzer
5. redhat.vscode-yaml, ms-azuretools.vscode-docker
6. eamodio.gitlens, mhutchie.git-graph
7. ms-vscode-remote.remote-ssh
8. humao.rest-client
9. hediet.vscode-drawio
10. ms-toolsai.jupyter

---

## Gitea Integration

All development environments pre-configured with:
- Git credentials via Gitea token (per-user, managed by Authentik)
- Gitea remote URL: `https://git.lab.example.com:8084/`
- SSH key pair generated on first login
- Pre-cloned ARC repo for reference

---

## Deployment Priority

| Priority | Service | Rationale |
|----------|---------|-----------|
| P1 | F1: Code-Server | Immediate value — browser-based, lightweight, multi-language |
| P1 | F4: Cross-compile | Needed for ESP32/LoRa firmware (Meshtastic, sensors) |
| P2 | F2: Jupyter Hub | Data science, AI model eval, education |
| P2 | F5: ARCdev-Linux VM | Full desktop dev for complex projects |
| P3 | F3: Android SDK | Needed when Android app development begins |
| P3 | F6: ARCdev-Android VM | Full Android Studio — heavy, use only when needed |
| P4 | F7: ARCdev-Windows VM | Only for AD/PowerShell — existing win11-tuned VM may suffice |

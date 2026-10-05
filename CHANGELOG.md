# Changelog

All notable changes to the OD2 Screen Dangle companion will be documented in this file.

---

## [1.0.0] - 2026-10-05

### Initial Public Release

OD2 Screen Dangle is an interactive, lightweight desktop companion that suspends a physics-based lucky charm from the top edge of your computer display across Windows and macOS.

#### Highlights & Core Features
* **Zero-Click Pass-Through Overlay**: Utilizes hardware-accelerated per-pixel alpha windowing (`WS_EX_LAYERED` / `WS_EX_TRANSPARENT`). Clicks and keystrokes pass transparently to applications, code editors, games, and browser tabs underneath.
* **Verlet Rope Physics**: Natural oscillation, damping, and inertia responding to gravity, ambient breeze sway, and cursor drags.
* **Live Studio Web Sync**: Instant 1-click synchronization with the web studio at [od2.in/screen-dangle](https://od2.in/screen-dangle).
* **Cultural Talismans & Custom Avatars**: Support for 10 built-in talismans (Nazar, Nimbu-Mirchi, Maneki-Neko, Daruma, Hamsa) plus custom transparent PNG, SVG, and avatar uploads up to 50MB.
* **Minimal Resource Footprint**: Consumes 0% idle CPU and less than 25MB RAM.
* **Keyboard Shortcuts**:
  * `Ctrl + D` (Windows) | `Cmd + D` (macOS): Toggle talisman visibility on/off.
  * `Ctrl + S` (Windows) | `Cmd + S` (macOS): Trigger gentle breeze sway and blessing chime.
* **System Tray & Menu Bar Integration**: Right-click tray icon on Windows or menu bar on macOS for settings, quick alignment, and clean exit.
* **OBS Studio Stream Overlay**: Transparent browser source export for live streaming.

#### Included Release Packages
* `OD2-Screen-Dangle-Setup-v1.0.0.exe`: Windows setup installer with desktop and Start Menu shortcuts.
* `OD2-Screen-Dangle-v1.0.0.exe`: Windows portable standalone executable.
* `OD2-Screen-Dangle-Windows-v1.0.0.zip`: Windows portable ZIP archive.
* `OD2-Screen-Dangle-macOS-v1.0.0.zip`: macOS application bundle.

#### Terminal Quick Install
* **Windows (PowerShell)**:
  ```powershell
  irm https://raw.githubusercontent.com/One-Day-Developers/screen-dangle/main/install.ps1 | iex
  ```
* **macOS (Terminal)**:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/One-Day-Developers/screen-dangle/main/install.sh | bash
  ```

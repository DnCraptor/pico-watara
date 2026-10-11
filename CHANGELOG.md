# v2.2.1

- Added per-ROM input recording (`R`) and replay playback (`P`) from the file browser, without changing the existing Demo shortcut or in-game `P` mapping.
- Added deterministic input-event playback indexed by emulated frame; live gameplay input is ignored during playback and restored when it finishes.
- Added `.wvr` replay files under `/.config/watara/replay/`, with ROM identity checks and periodic header updates and synchronization every 60 emulated frames.
- Added the `REC HH:MM:SS` indicator to the existing title OSD during recording, without adding a playback overlay.
- Extended save states with replay-session timeline metadata; loading a matching quick-save restores the recording position and truncates the abandoned recording branch.
- Moved save-state files from `/WATARA/` to `/.config/watara/`; previous `.save` files must be moved manually if they are still needed.
- Removed repeated FatFs remounts during quick-save, quick-load and configuration saving to avoid invalidating an open recording.
- Added allocation, file-open and complete read/write checks to save-state operations.
- Updated the README and release notes for version 2.1.9, the current save-data paths and replay controls.

# v2.1.6

- Added RP2040 and RP2350 release matrix support for VGA, HDMI and TV-SOFT.
- Added QSPI PSRAM ROM loading on supported RP2350 boards with Flash fallback.
- Flash ROM updates now compare sectors and skip unchanged erase/program operations.
- Added persistent per-platform/per-video configuration under `/.config/watara/...`.
- Added persistent PAL/NTSC selection for TV-SOFT.
- Reworked TV-SOFT PAL/NTSC timing, text rendering and color/phase handling.
- Added consistent Native/Bezel display semantics and 4:3 fullscreen mode for HDMI/TV-SOFT.
- Added VGA gray-line modes and HDMI horizontal gray lines.
- Added Demo mode with automatic cartridge cycling and cartridge-name overlay.
- Added file-browser PSRAM/FLASH storage indication and Demo shortcut.
- Added I2S underrun HOLD behavior and output pause during browser/menu/ROM transitions.
- Added robust ROM-load validation so the shell/menu remains usable without a loaded cartridge.
- Fixed menu/browser transition handling and active-area clearing without blanking the bezel.
- Added release build automation for the 48 supported RP2040/RP2350 VGA/HDMI/TV-SOFT x PWM/I2S variants.

# v1.1.0

- Save/Load
- TV-Link supervision background
- Palette names

# v1.0.0

- Everything is working

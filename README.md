# Raspberry Pi Pico Watara Supervision emulator

Watara Supervision emulator for MURMULATOR-family RP2040/RP2350 boards, based on the Potator emulator core.

## Supported release targets

The release matrix covers both RP2040 and RP2350.

Boards:

- MURMULATOR 1.x
- MURMULATOR 2.0
- Olimex RP2040-PICO-PC
- Waveshare RP2040-PiZero on RP2040
- Waveshare RP2350-PiZero on RP2350

Video outputs:

- VGA
- HDMI
- TV-SOFT composite PAL/NTSC

Audio outputs:

- PWM
- I2S

The release matrix contains 48 firmware variants: 8 board/platform combinations x 3 video outputs x 2 audio outputs.

## ROMs and SD-card layout

ROM files are loaded from:

```text
/WATARA/
```

Supported ROM extensions are `.sv` and `.bin`.

Save states and input recordings are persistent emulator data stored separately from ROMs:

```text
/.config/watara/             Save states (.save)
/.config/watara/replay/      Input recordings (.wvr)
```

A save state uses the original ROM filename (including `.sv` or `.bin`):
`<rom-filename>.save` for slot 0, or `<rom-filename>_<slot>.save` for numbered slots.
A recording is named `<rom-filename>.wvr`. Starting a new recording for the
same ROM replaces its existing `.wvr` file.

Per-platform/per-video emulator settings are stored in:

```text
/.config/watara/<platform>/<video>/emulator.cfg
```

Platform names:

```text
m1p1  MURMULATOR 1.x / RP2040
m2p1  MURMULATOR 2.0 / RP2040
pcp1  Olimex RP2040-PICO-PC / RP2040
z0p1  Waveshare RP2040-PiZero
m1p2  MURMULATOR 1.x / RP2350
m2p2  MURMULATOR 2.0 / RP2350
pcp2  Olimex RP2040-PICO-PC / RP2350
z0p2  Waveshare RP2350-PiZero
```

Video names are `vga`, `hdmi` and `softtv`.

`/tmp` is reserved for temporary filesystem objects. Persistent emulator data must not be stored there.

## ROM storage

On RP2350 boards with supported QSPI PSRAM, ROMs are loaded directly into PSRAM. The file browser shows `PSRAM` when this path is active.

When PSRAM is unavailable, ROMs use the flash storage area. Flash programming compares sectors first and erases/programs only sectors that actually changed. Programmed sectors are verified after writing; a failed load is reported instead of being treated as a valid cartridge. The file browser shows `FLASH` for this path.

## Display modes

VGA supports:

- Native
- Bezel

HDMI and TV-SOFT support:

- Native
- Bezel
- 4:3 fullscreen

The built-in Watara/Supervision bezel is preserved; no external Gamate-style backplane is used.

VGA also supports vertical/horizontal gray-line simulation with configurable intensity. HDMI supports horizontal gray lines. TV-SOFT intentionally does not use gray lines because composite resampling/chroma processing makes the logical pattern unsuitable for that output path.

## TV-SOFT

TV-SOFT supports PAL and NTSC with persistent TV-system selection. The `Colors` setting is also persistent. The software composite renderer includes the corrected text-mode width and color/phase handling used by the current menu/file-browser UI.

## Demo mode

Demo mode automatically walks through cartridges in `/WATARA` in alphabetical order.

It can be started either from the file browser with `B` or from the emulator menu. The selected duration is persistent. Available per-game durations are:

- 15 seconds
- 30 seconds
- 45 seconds
- 1 minute
- 2 minutes
- 3 minutes
- 5 minutes
- 10 minutes

The active cartridge name is shown along the bottom of the output while Demo mode is running. If a cartridge cannot be loaded, Demo mode briefly shows the load error, skips that cartridge and continues with the next one. Entering the file browser clears the active Demo state so Demo cannot remain latched after an unrelated exit from emulation.

## File browser controls

Select a `.sv` or `.bin` cartridge and use:

- `Start` / `Enter`: run the selected ROM normally.
- `R`: run the selected ROM and start a new input recording (overwrites its existing `.wvr`).
- `P`: run the selected ROM and play back its saved `.wvr` recording.
- `B`: start Demo mode (unchanged).
- `PageUp` / `PageDown` on a keyboard: move the selection by half a visible page.
- `F10`: toggle the file browser while a game is running.

The viewport scrolls only when the new selection would move outside the currently visible list. `P` continues to act as the in-game `B` key **outside** the file browser.

## Input recording and playback

Recording stores **input changes indexed by emulated frame**, not timestamps from the
wall clock. Input from the keyboard and controller is combined before it is sent
to the Supervision core. During playback, recorded input drives the emulated game;
live game-button input does not replace it. At the end of the recorded frames,
normal live input resumes.

Recording displays `REC HH:MM:SS` in the existing title-overlay area, updated
from emulated frame count (60 frames per displayed second). There is no `PLAY`
overlay. Demo mode retains its original cartridge-name display.

The recording is periodically synchronized to the SD card every 60 emulated
frames and when recording ends. A watchdog reset can therefore lose the most
recent, not-yet-synchronized portion. A recording belongs to a specific ROM
filename and size; playback checks both against the recording header.

## Save states and replay timeline

The emulator supports numbered save-state slots in the menu and keyboard quick
save/load shortcuts:

- `Ctrl+F1` through `Ctrl+F8`: save to the corresponding slot.
- `Alt+F1` through `Alt+F8`: load the corresponding slot.

Files are read and written in `/.config/watara/`, not `/WATARA/`. The directory
is created when necessary. Existing `.save` files previously written to
`/WATARA/` must be moved manually if they are still needed.

While recording, a save state also contains the recording session ID, emulated
frame and `.wvr` file position. Loading a state **from the same recording
session** restores that position, truncates input events from the abandoned
future and continues recording a new branch. Loading a state without compatible
recording metadata does not preserve the current recording timeline. The normal
Supervision state remains the first part of the `.save` file, with replay
metadata appended afterward.

Quick save/load does not remount FatFs while a recording file is open. Entering
the file browser ends the current recording or playback session; leaving Demo
mode via quick save/load continues to clear Demo state.

## Configuration format

The current settings format is **version 4**. It includes Demo duration,
TV-SOFT `Colors`, and custom-palette preset indices alongside the other
settings. Configuration reads are strict: settings files with an older version
or an unexpected size are not accepted. Configuration writes are considered
successful only if the complete settings block is written and the file closes
successfully. Saving configuration does not remount an already mounted SD
volume, so an open replay file is not invalidated.

## Clocking

The normal default system clock is 366 MHz for VGA and TV-SOFT builds. HDMI builds use 378 MHz, which gives an exact 1.5 divider for the 252 MHz HDMI PIO clock. The special RP2040 `CPU_FREQ` build path remains unchanged.

## MURMULATOR 2 audio

For MURMULATOR 2, PWM stereo uses GP10/GP11. This avoids GP8, which is used as the RP2350A QSPI PSRAM CS1 pin. The audio default configuration now derives the PWM data/clock pair from `AUDIO_PWM_PIN` when PWM output is selected.

## Building

The project uses Raspberry Pi Pico SDK 2.2.0, CMake and the ARM GCC toolchain supplied by the Pico VS Code environment.

For the complete release matrix on Windows run:

```bat
build_all.bat
```

The script locates CMake and Ninja from PATH or the Pico SDK installation under `%USERPROFILE%\.pico-sdk`, creates an independent build directory for each variant and builds the 48 supported RP2040/RP2350 release configurations.

## Firmware file names

Firmware names encode board/platform, video, audio and version.

Board/platform prefix:

```text
m1p1  MURMULATOR 1.x / RP2040
m2p1  MURMULATOR 2.0 / RP2040
PCp1  Olimex RP2040-PICO-PC / RP2040
z0p1  Waveshare RP2040-PiZero
m1p2  MURMULATOR 1.x / RP2350
m2p2  MURMULATOR 2.0 / RP2350
PCp2  Olimex RP2040-PICO-PC / RP2350
z0p2  Waveshare RP2350-PiZero
```

Video suffix:

```text
-VGA
-HDMI
-TV-SOFT
```

Audio suffix:

```text
-PWM
-I2S
```

Example names:

```text
m1p1-watara-VGA-PWM-2.2.1.uf2
z0p1-watara-TV-SOFT-I2S-2.2.1.uf2
m2p2-watara-HDMI-I2S-2.2.1.uf2
PCp2-watara-VGA-PWM-2.2.1.uf2
```

## Credits

Based on the [Potator](https://git.libretro.com/libretro/potator) Watara Supervision emulator core.

MURMULATOR hardware project: [MURMULATOR classical scheme](https://github.com/AlexEkb4ever/MURMULATOR_classical_scheme).

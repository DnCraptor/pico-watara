# Watara Supervision Emulator 2.1.6

This release substantially updates the Watara Supervision emulator for the MURMULATOR family and other supported RP2040/RP2350 boards.

The main focus of 2.1.6 is improved display output, RP2350/QSPI PSRAM support, more robust ROM loading and Flash handling, improved audio behaviour, Demo mode, and a unified release configuration for both RP2040 and RP2350 targets.

## Supported platforms

Release builds are provided for both Raspberry Pi microcontroller generations:

- RP2040
- RP2350 / Pico 2

Supported boards:

- MURMULATOR 1.x
- MURMULATOR 2.0
- Olimex RP2040-PICO-PC
- Waveshare RP2040-PiZero on RP2040 builds
- Waveshare RP2350-PiZero on RP2350 builds

## Video output

The release supports three video backends:

- VGA
- HDMI
- TV-SOFT composite video

Display modes have been made consistent between the supported outputs while retaining the Watara-specific bezel.

Available modes include:

- Native — original 160×160 Supervision image
- Bezel — 160×160 image inside the Watara console bezel
- 4:3 fullscreen — available on HDMI and TV-SOFT

### HDMI

HDMI rendering has been updated and stabilized for both RP2040 and RP2350.

Native, Bezel and 4:3 modes are supported. The renderer uses the same behaviour on both MCU generations.

### VGA

VGA supports Native and Bezel display modes.

Optional Gray lines are available to reproduce a more LCD-like appearance:

- No
- Vertical
- Horizontal
- Both

Gray-line intensity can also be adjusted.

### TV-SOFT

The software composite-video backend has received substantial timing and rendering updates.

Improvements include:

- PAL and NTSC operation
- corrected carrier and scanline timing
- improved colour generation
- corrected text-mode rendering
- 53-column text mode
- phase-continuous colour rendering
- Native, Bezel and 4:3 display modes

Gray lines are intentionally not used with TV-SOFT because analogue resampling and chroma encoding do not preserve the regular LCD-line pattern reliably.

## Demo mode

A new Demo mode automatically cycles through cartridges stored in `/WATARA`.

Available game durations:

- 30 seconds
- 45 seconds
- 1 minute
- 3 minutes
- 5 minutes
- 10 minutes

Demo mode can be started from the emulator menu or directly from the ROM browser.

While a game is running in Demo mode, the cartridge name is displayed along the bottom of the screen.

At the end of the selected interval, the emulator automatically resets the current game and starts the next cartridge.

## QSPI PSRAM support

RP2350 builds can use external QSPI PSRAM when supported by the board.

Up to 16 MiB of PSRAM can be detected and used for cartridge storage.

When PSRAM is available, cartridges can be loaded directly into PSRAM instead of rewriting the internal Flash.

The ROM browser indicates whether the selected storage path is using PSRAM or Flash.

If PSRAM is unavailable, the emulator automatically falls back to Flash storage.

## Improved Flash handling

Flash cartridge updates now compare existing Flash sectors against the new cartridge data.

A sector is erased and programmed only when its contents actually differ.

This reduces:

- unnecessary Flash erase/program cycles
- cartridge loading time when data is already present
- Flash wear

ROM loading is also validated: a cartridge is considered loaded only after the complete expected data has actually been read.

## Improved shell and ROM browser behaviour

The emulator shell no longer assumes that a valid cartridge must already be loaded.

The ROM browser and configuration menu remain usable without a ROM, while execution of the emulated Watara machine is blocked until a cartridge has been successfully loaded.

This also prevents stale or invalid ROM/PSRAM contents from being executed.

Transitions between the browser, menu, Demo mode and emulation now clear only the active 160×160 LCD area. The Watara bezel remains intact instead of flashing during transitions.

## Audio improvements

Release builds provide:

- PWM audio
- I2S audio

I2S output now uses HOLD-last-sample underrun handling to make timing interruptions less audible.

Audio output is explicitly paused during operations such as:

- ROM browser transitions
- menu entry
- cartridge changes
- Flash programming

For I2S, the output clocks remain running while a silent HOLD sample is supplied. PWM output is returned to its neutral level.

This reduces clicks and unwanted audio during cartridge and UI transitions.

## Persistent configuration

Configuration files are now separated by hardware platform and video backend:

```text
/.config/watara/<platform>/<video>/emulator.cfg
```

Platform identifiers include:

```text
m1p1
m2p1
pcp1
z0p1

m1p2
m2p2
pcp2
z0p2
```

Video identifiers are:

```text
vga
hdmi
softtv
```

The current settings format is version 2.

Old configuration formats and the former `/WATARA/emulator.cfg` location are no longer used.

PAL/NTSC selection is persistent.

## SD card layout

Cartridges remain under:

```text
/WATARA/
```

Save-state files also remain persistent user data under `/WATARA`.

Configuration is stored separately under:

```text
/.config/watara/
```

Temporary filesystem objects, when required, use:

```text
/tmp/
```

## Performance and clocking

The normal default clock is now 366 MHz on both RP2040 and RP2350 builds.

This frequency was selected because video output proved more stable than at the previous 378 MHz default.

The existing special RP2040 `CPU_FREQ` configuration remains unchanged.

## Release build matrix

The release matrix contains:

- 2 MCU platforms
- 4 board targets per platform
- 3 video outputs
- 2 audio outputs

This produces **48 firmware configurations**.

Video variants:

```text
VGA
HDMI
TV-SOFT
```

Audio variants:

```text
PWM
I2S
```

I2S-CS4334, TFT/ILI9341, the legacy TV backend and m1p2launcher are not part of the standard 2.1.6 release matrix.

## Firmware naming

Examples:

```text
m1p1-watara-VGA-PWM-2.1.6.uf2
m2p1-watara-HDMI-I2S-2.1.6.uf2
PCp2-watara-VGA-PWM-2.1.6.uf2
z0p2-watara-TV-SOFT-I2S-2.1.6.uf2
```

Platform suffix:

- `p1` — RP2040
- `p2` — RP2350

Board prefix:

- `m1` — MURMULATOR 1.x
- `m2` — MURMULATOR 2.0
- `PC` — Olimex RP2040-PICO-PC family
- `z0` — Waveshare PiZero family

Video suffix:

- `VGA` — VGA output
- `HDMI` — HDMI output
- `TV-SOFT` — software composite output

Audio suffix:

- `PWM` — PWM audio
- `I2S` — standard I2S audio

## Summary

Version 2.1.6 brings the Watara Supervision emulator substantially closer to the current MURMULATOR emulator infrastructure while retaining Watara-specific display and emulation behaviour.

The most significant additions are QSPI PSRAM cartridge loading, selective Flash programming, improved PAL/NTSC composite output, Demo mode, unified display modes, improved audio transition handling, robust ROM-loading state management, per-platform configuration storage, and a unified RP2040/RP2350 release matrix.
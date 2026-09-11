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

Save states are stored next to the ROMs in `/WATARA` using `.save` files.

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

## File browser navigation

In addition to the existing directional controls, USB keyboards can use `PageUp` and `PageDown` to move the selection by half a visible page. The viewport scrolls only when the new selection would move outside the currently visible list.

## Save states

The emulator supports multiple save-state slots from the menu. Save-state files remain persistent user data under `/WATARA`.

## Configuration format

The current settings format is version 3. Version 3 stores Demo duration and the TV-SOFT `Colors` option in addition to the previously persistent settings. Configuration reads are strict: older settings structures are not accepted as the current format. Configuration writes are considered successful only if the complete settings block is written and the file closes successfully.

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
m1p1-watara-VGA-PWM-2.1.7.uf2
z0p1-watara-TV-SOFT-I2S-2.1.7.uf2
m2p2-watara-HDMI-I2S-2.1.7.uf2
PCp2-watara-VGA-PWM-2.1.7.uf2
```

## Credits

Based on the [Potator](https://git.libretro.com/libretro/potator) Watara Supervision emulator core.

MURMULATOR hardware project: [MURMULATOR classical scheme](https://github.com/AlexEkb4ever/MURMULATOR_classical_scheme).

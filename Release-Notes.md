# Watara Supervision Emulator 2.1.7

Version 2.1.7 is a maintenance release focused on MURMULATOR 2 audio/PSRAM correctness, persistent Demo/TV-SOFT settings, safer Flash ROM loading, Demo-mode recovery, file-browser navigation, and cleaner HDMI clocking.

## MURMULATOR 2 PWM / PSRAM fix

PWM stereo on MURMULATOR 2 now starts at GP10, using GP10/GP11 as the stereo pair.

The previous PWM base pin was GP9; the PWM driver derives an even/odd pair from the base pin, which caused GP8/GP9 to be configured for PWM. On RP2350A-based MURMULATOR 2 boards GP8 is the QSPI PSRAM CS1 pin, so enabling PWM could interfere with PSRAM access.

The audio default configuration now uses `AUDIO_PWM_PIN` and `AUDIO_PWM_PIN + 1` when PWM output is selected, while I2S keeps the normal `AUDIO_DATA_PIN` / `AUDIO_CLOCK_PIN` routing.

## Persistent settings format v3

The settings structure is updated from version 2 to version 3.

The following settings are now persistent:

- Demo game duration
- TV-SOFT `Colors` mode

Configuration loading remains strict: only the current structure size and version 3 are accepted. Older configuration files are not interpreted as version 3 settings.

Configuration writes now also check the result of `f_close()`, so a settings save is considered successful only when the full settings block was written and the file closed successfully.

## Expanded Demo durations

Demo mode now offers:

- 15 seconds
- 30 seconds
- 45 seconds
- 1 minute
- 2 minutes
- 3 minutes
- 5 minutes
- 10 minutes

The default index is the first entry, so a fresh version-3 configuration uses 15 seconds.

## Demo-mode load recovery

ROM-load errors are now handled explicitly during Demo mode.

If a cartridge cannot be loaded, the error message is shown briefly and Demo mode continues with the next cartridge instead of stopping at the first failed entry.

The loader reports failures for:

- missing or empty ROM files
- ROMs too large for the configured storage path
- incomplete ROM reads
- Flash verification failures

Normal/manual load errors remain visible longer; Demo-mode errors use a shorter delay so automatic playback can continue.

## Flash verification

When Flash storage is used, sectors are still compared before erase/program operations so unchanged sectors are skipped.

After a changed sector is programmed, its contents are compared with the source buffer. A verification mismatch marks the ROM load as failed and displays `ERROR: Flash verify failed!` instead of accepting the cartridge as successfully loaded.

## Demo state no longer remains latched in the file browser

Entering the ROM browser now clears:

```text
demo_active
demo_requested
demo_advance_pending
```

The same state is cleared on the generic path that returns from emulation to the browser.

Normal automatic Demo cartridge-to-cartridge transitions still bypass the browser and continue directly, so this change prevents stale Demo state without breaking the normal Demo sequence.

## File-browser PageUp / PageDown

USB keyboard navigation now supports `PageUp` and `PageDown`.

Each key press moves the selected item by half of the visible page. The cursor moves first; the list viewport scrolls only when the new selected item would otherwise be outside the visible area.

## HDMI default clock

HDMI builds now default to 378 MHz instead of 366 MHz.

With the HDMI PIO target clock at 252 MHz, 378 MHz gives an exact 1.5 clock divider. VGA and TV-SOFT builds keep the 366 MHz default. The existing RP2040 `CPU_FREQ` override path is unchanged.

## Release build matrix

The standard release matrix remains unchanged:

- RP2040 and RP2350
- MURMULATOR 1.x
- MURMULATOR 2.0
- Olimex RP2040-PICO-PC
- Waveshare PiZero targets
- VGA, HDMI and TV-SOFT
- PWM and I2S audio

This produces 48 standard firmware variants.

## Firmware naming

Examples:

```text
m1p1-watara-VGA-PWM-2.1.7.uf2
m2p1-watara-HDMI-I2S-2.1.7.uf2
PCp2-watara-VGA-PWM-2.1.7.uf2
z0p2-watara-TV-SOFT-I2S-2.1.7.uf2
```

## Upgrade notes

Because the settings structure is now version 3, existing version-2 configuration files are not loaded as current settings. A new configuration will use the current defaults until settings are saved again.

For MURMULATOR 2 users, the GP10/GP11 PWM routing is an important hardware-facing fix, especially on RP2350A boards where GP8 is used for QSPI PSRAM CS1.

# Watara Supervision Emulator 2.2.1

Version 2.2.1 adds input recording and replay to the Watara Supervision emulator, integrates recordings with save states, and separates persistent save data from the ROM directory. It also hardens FatFs handling so save operations do not interrupt an open recording.

## Input recording and playback

The ROM file browser now accepts two additional keyboard commands when a cartridge is selected:

- **R — Record:** load the selected `.sv`/`.bin` ROM and start a new recording.
- **P — Play:** load the selected ROM and replay its previously recorded input.

`Start`/`Enter` still runs a ROM normally, and `B` still starts Demo mode. In the file browser, `P` is handled as a replay command rather than as the gamepad `B` button; the existing `P` mapping is retained during gameplay.

Recordings use the `.wvr` format and are written to `/.config/watara/replay/<rom-filename>.wvr`. A new recording replaces the prior recording for that ROM. Playback checks the ROM filename and size in the file header.

Instead of periodically sampling real-time input, the emulator records changes in the input delivered to the Supervision core, indexed by **emulated frame**. Playback applies those events before emulating each frame and ignores live game-button state for the emulated input until playback ends. The normal input mapping resumes when the recording reaches its saved end.

During recording, the existing title OSD shows `REC HH:MM:SS` based on emulated frames. Playback adds no separate `PLAY` OSD, and Demo mode keeps its original title overlay.

The recording header's frame count is updated and the file synchronized every 60 emulated frames and on normal recording shutdown. This limits, but cannot eliminate, loss of recent input events after an abrupt reset or power failure.

## Save-state-aware recording

Quick-save and quick-load now retain recording timeline information in an extra trailer after the existing Supervision save state. The trailer stores a session identifier, the frame index, the file offset and the recorded input state.

When a save state from the **current recording session** is loaded, Watara restores the saved frame and truncates the `.wvr` file at the saved position. New input is then recorded as a replacement branch instead of keeping the abandoned future. The REC indication remains associated with recording, including across quick-save and compatible quick-load.

Keyboard shortcuts are `Ctrl+F1` through `Ctrl+F8` for quick-save and `Alt+F1` through `Alt+F8` for quick-load. Existing save files without replay metadata can still restore the normal emulator state; they do not provide a recording timeline to resume.

## Corrected SD-card layout

ROM files remain in `/WATARA/`. Save states now belong in `/.config/watara/`, and recordings are stored in `/.config/watara/replay/`.

```text
/WATARA/<game>.sv                          ROM
/.config/watara/<game>.sv.save             Save state, slot 0
/.config/watara/<game>.sv_1.save           Save state, slot 1
/.config/watara/replay/<game>.sv.wvr       Input recording
/.config/watara/<platform>/<video>/emulator.cfg  Settings
```

The emulator creates the save/recording directories when needed. **Old `.save` files in `/WATARA/` are not migrated automatically**; move them to `/.config/watara/` to retain access to them.

## FatFs and quick-save reliability

- Removed repeated `f_mount()` calls from quick-save/quick-load, preventing them from invalidating an open recording file.
- Configuration saving avoids remounting an already mounted volume.
- Added memory-allocation, file-open and complete read/write checks around state operations; an incomplete state file is not passed to the Supervision state loader.
- Recording checkpoints synchronize pending events before creating a save state. The replay timeline is truncated on a compatible quick-load.

## Compatibility and release targets

- The current settings structure is **version 4** and remains stored in `/.config/watara/<platform>/<video>/emulator.cfg`.
- The firmware version is **2.2.1** (`BUILD_VERSION` in `CMakeLists.txt`).
- The existing 48-target RP2040/RP2350 matrix (VGA, HDMI, TV-SOFT × PWM/I2S) is unchanged.
- Earlier 2.1.8 improvements to random custom-palette selection and safe Demo exit on quick-save/load remain included.

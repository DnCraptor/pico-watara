# Watara Supervision Emulator 2.1.8

Version 2.1.8 is a maintenance release focused on improved random palette generation and safe interaction between Demo mode and quick save/load states.

## Improved random custom palettes

Random custom palettes now use the expanded Watara palette definitions.

`RGB0` and `RGB3` are selected independently from their complete color sets. `RGB1` is also selected from its complete set, while `RGB2` is selected from the opposite temperature group:

- a Cold `RGB1` is paired with a Warm `RGB2`
- a Warm `RGB1` is paired with a Cold `RGB2`

This keeps the random selection varied while avoiding Cold/Cold and Warm/Warm combinations for the two middle palette colors.

The Watara preset tables were also synchronized with the current palette definitions, including corrected Cold `RGB1` and Warm `RGB2` values.

## Quick save/load exits Demo mode

Quick save/load operations now leave Demo mode before the state operation is performed.

This applies to both quick-save and quick-load keyboard shortcuts. Demo state, pending automatic advancement and the Demo timer are cleared before the save or load starts.

Previously, a quick-save could be created for one cartridge while Demo mode remained active and later advanced to another cartridge. Loading that state after the automatic cartridge switch could restore state data against the wrong game and cause corrupted execution or other undefined behaviour.

Exiting Demo mode at the quick-state operation prevents an automatic cartridge change after the state has been saved or restored.

## Compatibility

The standard RP2040/RP2350 release targets and VGA, HDMI and TV-SOFT output variants remain unchanged from version 2.1.7.

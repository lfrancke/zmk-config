# ZMK Config for Corne Choc Pro

This is my personal ZMK firmware configuration for a **Corne Choc Pro** split keyboard from keebart.com.

## Hardware Setup
- **Board**: Corne Choc Pro (custom board definition)
- **Layout**: 46-key split (6x3 + 3 thumb keys per side + 2 extra keys per side)
- **Features**: RGB lighting, Bluetooth
- **Missing**: No nice_view displays, no rotary encoders

## Repository Origin

This was forked from https://github.com/Keebart/zmk-config

## Common Tasks

### Updating Keymap
1. Edit `config/corne_choc_pro.keymap`
2. Push to GitHub - firmware builds automatically via GitHub Actions
3. Download `.uf2` files from Actions artifacts
4. Flash both sides (see below)

Alternatively, use https://nickcoutsos.github.io/keymap-editor/

### Flashing Firmware

The Corne Choc Pro uses an nRF52840 with the Adafruit bootloader, so it appears as a USB drive when in bootloader mode. You need to flash **both halves separately**.

For each half (left and right):

1. Connect the half to your computer via USB-C
2. **Double-tap the reset button** quickly (the small button on the PCB) to enter bootloader mode -- use the SIM ejector tool included in the case to reach it
3. A USB drive named **NICENANO** (or similar) will appear on your computer
4. Copy the `.uf2` file to that drive:
   - Left half: `corne_choc_pro_left-zmk.uf2`
   - Right half: `corne_choc_pro_right-zmk.uf2`
   - e.g. `cp firmware.uf2 /run/media/$USER/NICENANO/`
5. The keyboard half reboots automatically once the file is copied
6. Repeat for the other half

### Host System Setup
**Important**: The Noted layout is implemented in the ZMK firmware keymap itself. The firmware outputs plain German (`de`) keycodes, so the host must be set to `de` layout (no variant). If your daily driver keyboard uses a different layout (e.g. Neo), you need to switch when using the Corne.

#### X11
On X11 you can set the layout per device, so the Corne can use `de` while other keyboards stay on Neo:
```bash
# Find your keyboard device ID
xinput list

# Set only the Corne to plain de (replace <device-id> with actual ID)
setxkbmap -device <device-id> de
```

#### Wayland (Niri)
Niri does not support per-device keyboard layouts yet ([niri#371](https://github.com/niri-wm/niri/issues/371)). As a workaround, configure both layouts and switch globally when using the Corne.

In `~/.config/niri/config.kdl`:
```kdl
input {
    keyboard {
        xkb {
            layout "de,de"
            variant "neo,"
        }
    }
}
```

This gives you two layouts: `de(neo)` (index 0) and plain `de` (index 1). Switch between them with:
```bash
niri msg action switch-layout 1   # plain de for Corne
niri msg action switch-layout 0   # back to Neo
```

### Troubleshooting Bluetooth
1. Use the settings reset firmware: `settings_reset-corne_choc_pro_left-zmk.uf2`
2. Flash both sides, then flash normal firmware again

### Adding New Features
- **For new keys/behaviors**: Edit keymap file
- **For hardware changes**: Modify board definition in `boards/arm/corne_choc_pro/`
- **For build variants**: Update `build.yaml`

## Notes for Future Me
- I removed encoder/SPI configs because my hardware doesn't have them
- I removed Piantor config

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
**Important**: This keymap uses German layout (`keys_de.h`), so your host system needs to be set to German keyboard layout.

#### Set German layout system-wide:
```bash
setxkbmap de
```

#### Set German layout for specific device only:
```bash
# Find your keyboard device ID
xinput list

# Set layout for specific device (replace <device-id> with actual ID)
setxkbmap -device <device-id> de
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

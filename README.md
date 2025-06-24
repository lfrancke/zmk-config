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
4. Flash `corne_choc_pro_left-zmk.uf2` and `corne_choc_pro_right-zmk.uf2`

Alternatively, use https://nickcoutsos.github.io/keymap-editor/

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

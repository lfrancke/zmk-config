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

The Corne Choc Pro uses an nRF52840 with the Adafruit UF2 bootloader, so it appears as a USB drive when in bootloader mode. You flash **both halves separately**.

**Easiest: use the helper script.** It downloads the latest CI build and walks you through both halves:
```bash
./flash.sh                              # download latest build, flash both halves
./flash.sh --dir /path/to/firmware right  # use local .uf2 files, one half only
./flash.sh --reset                      # flash the settings_reset firmware (BT recovery)
```

**Manual steps**, for each half:

1. Connect the half to your computer via USB-C.
2. **Double-tap the reset button on the BACK of the half** to enter bootloader mode. (There's also a `&bootloader` key on the settings layer if the keyboard is running.)
3. A USB drive labelled **`KEEBART`** appears. It usually does **not** auto-mount, so mount it:
   ```bash
   udisksctl mount -b /dev/sda      # adjust device if needed; lsblk shows LABEL=KEEBART
   ```
4. Copy the `.uf2` to it:
   - Left half: `corne_choc_pro_left-zmk.uf2`
   - Right half: `corne_choc_pro_right-zmk.uf2`
   - e.g. `cp corne_choc_pro_left-zmk.uf2 /run/media/$USER/KEEBART/ && sync`
5. The half reboots automatically once the file is copied (the drive disappears).
6. Repeat for the other half. The bootloader is identical on both halves, so do them one at a time.

### Keymap Layouts (active vs. archived)

Two layouts are maintained. **CI only ever builds `config/corne_choc_pro.keymap`** (the file named after the board); the other is a dormant archive.

- `config/corne_choc_pro.keymap` — the **active** layout. Currently **Neo2 (host-driven)**. Edit and tune this file directly.
- `config/corne_choc_pro_noted.keymap` — archived **Noted (firmware-baked)** layout. Not built.

To switch which layout the firmware uses, copy the desired variant over the active file, then push and flash:
```bash
# Build Noted instead of Neo2:
cp config/corne_choc_pro_noted.keymap config/corne_choc_pro.keymap
```
Your current Neo2 work stays in git history; restore it with `git checkout <neo2-commit> -- config/corne_choc_pro.keymap`.

### Host System Setup

The **active layout is Neo2, host-driven**: the firmware sends *standard positional* keycodes and the host keyboard layout turns them into Neo2. This is deliberate — your laptop and the MS Natural already run `de(neo)`, so all three keyboards behave identically and you never toggle host layouts.

**Required host layout: `de` + variant `neo`** (your normal Neo2 setup — nothing Corne-specific).

Neo's higher layers come *from the host* by holding a modifier (this is the "advanced features" payoff):
- Hold **CapsLock** → Neo Mod3 (symbols / programming)
- Hold **RightAlt** → Neo Mod4 (navigation / numpad)
- add **Shift** → Greek / math levels

#### Niri / Wayland
`~/.config/niri/config.kdl` already sets layout 0 to `de(neo)` — Corne and other keyboards all use it. **No switching needed for Neo2.** (Layout 1, plain `de`, only matters if you flash the archived Noted firmware.)

#### X11
```bash
setxkbmap de neo                              # system-wide
setxkbmap -device <id> de neo                 # one device only (xinput list for the id)
```

#### If you flash the archived Noted firmware instead
Noted is firmware-baked and outputs plain `de` keycodes, so it needs the host on **plain `de`** (no variant) — the opposite of Neo2. Niri: `niri msg action switch-layout 1`. X11: `setxkbmap de`.

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
- **Layout decision**: the real goal of the Corne is the *split ergonomics + finally using layers*, not switching base layout. So the active keymap is **Neo2, host-driven** — consistent with my laptop + MS Natural (all `de(neo)`), and Neo's higher layers come from the host for free (hold CapsLock / RightAlt). The earlier **Noted** experiment is archived in `corne_choc_pro_noted.keymap` if I ever want to revisit it.
- `config/keys_neo.h` is only used by a *firmware-baked* Neo approach (not the current host-driven one). It's currently unused — keep it only if you might bake Neo into firmware later.
- `config/keys_de.h` is used by the archived Noted keymap.

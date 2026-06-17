#!/usr/bin/env bash
#
# flash.sh — flash the latest built Corne Choc Pro firmware over USB.
#
# The keyboard's nRF52840 uses the Adafruit UF2 bootloader. Put a half into
# bootloader mode and it shows up as a USB drive labelled KEEBART:
#   * double-tap the RESET button on the BACK of the half, or
#   * on the running firmware, trigger the &bootloader key (settings layer).
# The drive often does NOT auto-mount, so this script mounts it via udisksctl,
# copies the correct .uf2, and waits for the board to reboot — once per half.
#
# Usage:
#   ./flash.sh                 # download latest CI build, flash both halves
#   ./flash.sh left            # flash only the left half
#   ./flash.sh right           # flash only the right half
#   ./flash.sh --dir DIR both  # use .uf2 files already in DIR (skip download)
#   ./flash.sh --reset         # flash the settings_reset firmware (BT recovery)
#
# Requires: gh (GitHub CLI, logged in) for downloading, and udisksctl.
# NOTE: the bootloader is identical on both halves — it cannot tell left from
# right — so flash one half at a time and answer the prompts in order.

set -euo pipefail

WORKFLOW="Build ZMK firmware"
DRIVE_LABEL="KEEBART"
FW_DIR=""
RESET=0
SIDES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)   FW_DIR="$2"; shift 2 ;;
        --reset) RESET=1; shift ;;
        left|right) SIDES+=("$1"); shift ;;
        both) SIDES=(left right); shift ;;
        *) echo "Unknown argument: $1" >&2; exit 1 ;;
    esac
done
[[ ${#SIDES[@]} -eq 0 ]] && SIDES=(left right)

# Resolve firmware directory: download the latest successful build if not given.
if [[ -z "$FW_DIR" ]]; then
    FW_DIR="$(mktemp -d)"
    echo "==> Downloading latest successful '$WORKFLOW' artifacts..."
    run_id="$(gh run list --workflow "$WORKFLOW" --status success --limit 1 --json databaseId --jq '.[0].databaseId')"
    [[ -z "$run_id" ]] && { echo "No successful build found." >&2; exit 1; }
    gh run download "$run_id" -D "$FW_DIR" >/dev/null
    echo "    Got build $run_id."
fi

prefix=""; [[ $RESET -eq 1 ]] && prefix="settings_reset-"

# Print the device path of the KEEBART bootloader drive, or nothing.
keebart_device() {
    lsblk -rno NAME,LABEL | awk -v l="$DRIVE_LABEL" '$2==l {print "/dev/"$1; exit}'
}

# Ensure the bootloader drive is mounted; print its mountpoint.
ensure_mounted() {
    local dev mp
    dev="$(keebart_device)" || return 1
    [[ -z "$dev" ]] && return 1
    mp="$(lsblk -rno MOUNTPOINT "$dev" | head -n1)"
    if [[ -z "$mp" ]]; then
        mp="$(udisksctl mount -b "$dev" 2>/dev/null | sed -n 's/.* at //p')"
    fi
    [[ -n "$mp" ]] && { echo "$mp"; return 0; }
    return 1
}

flash_side() {
    local side="$1"
    local uf2 mp=""
    uf2="$(find "$FW_DIR" -name "${prefix}corne_choc_pro_${side}-zmk.uf2" | head -n1)"
    [[ -z "$uf2" ]] && { echo "Firmware for $side not found in $FW_DIR" >&2; exit 1; }

    echo
    echo "==> Flashing ${prefix}${side^^} half"
    echo "    Plug in the $side half and double-tap RESET (on the back)."
    echo "    Waiting for the $DRIVE_LABEL bootloader drive..."

    for _ in $(seq 1 120); do
        if mp="$(ensure_mounted)"; then break; fi
        sleep 1
    done
    [[ -z "$mp" ]] && { echo "Timed out waiting for $DRIVE_LABEL." >&2; exit 1; }

    echo "    Mounted at $mp — copying $(basename "$uf2")..."
    cp "$uf2" "$mp/" && sync
    echo "    Copied. Waiting for the board to reboot..."
    for _ in $(seq 1 60); do
        [[ -z "$(keebart_device)" ]] && { echo "    $side done."; return 0; }
        sleep 1
    done
    echo "    (Drive still present — it may have flashed anyway.)"
}

for side in "${SIDES[@]}"; do
    flash_side "$side"
done

echo
echo "All requested halves flashed."

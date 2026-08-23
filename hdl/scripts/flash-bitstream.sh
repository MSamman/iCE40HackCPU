#!/usr/bin/env bash

# FPGA programming script for ICE40
# Usage: ./program.sh <bitstream_bin> [device]

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <bitstream_bin> [device]"
    echo "  bitstream_bin: Binary bitstream file (.bin)"
    echo "  device:        Device path (optional, e.g., /dev/ttyUSB0)"
    echo ""
    echo "Note: If device is not specified, iceprog will attempt to auto-detect"
    exit 1
fi

BITSTREAM_BIN="$1"
DEVICE="${2:-}"

if [ ! -f "$BITSTREAM_BIN" ]; then
    echo "Error: Bitstream file '$BITSTREAM_BIN' not found"
    exit 1
fi

echo "Programming FPGA"
echo "Bitstream: $BITSTREAM_BIN"
if [ -n "$DEVICE" ]; then
    echo "Device:    $DEVICE"
fi
echo ""
echo "Make sure your ICE40 board is connected via USB"
echo ""

if [ -n "$DEVICE" ]; then
    iceprog -d "$DEVICE" "$BITSTREAM_BIN"
else
    iceprog "$BITSTREAM_BIN"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Programming successful"
else
    echo ""
    echo "✗ Programming failed"
    echo "  - Check that the board is connected"
    echo "  - Check USB permissions (you may need to be in the 'dialout' group)"
    echo "  - Try specifying the device explicitly: $0 $BITSTREAM_BIN /dev/ttyUSB0"
    exit 1
fi


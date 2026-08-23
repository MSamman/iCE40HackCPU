#!/usr/bin/env bash

# Bitstream packing script for ICE40 FPGA
# Usage: ./pack_bitstream.sh <input_asc> [output_bin]

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_asc> [output_bin]"
    echo "  input_asc:  ASC file from place and route"
    echo "  output_bin: Output binary bitstream file (default: <input_asc>.bin)"
    exit 1
fi

INPUT_ASC="$1"
OUTPUT_BIN="${2:-${INPUT_ASC%.asc}.bin}"

if [ ! -f "$INPUT_ASC" ]; then
    echo "Error: Input ASC file '$INPUT_ASC' not found"
    exit 1
fi

echo "Packing bitstream"
echo "Input:  $INPUT_ASC"
echo "Output: $OUTPUT_BIN"
echo ""

icepack "$INPUT_ASC" "$OUTPUT_BIN"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Bitstream packing successful: $OUTPUT_BIN"
else
    echo ""
    echo "✗ Bitstream packing failed"
    exit 1
fi


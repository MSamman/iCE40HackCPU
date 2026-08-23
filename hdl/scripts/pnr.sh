#!/usr/bin/env bash

# Place and Route script for ICE40 FPGA
# Usage: ./pnr.sh <input_json> [pcf_file] [device] [output_asc]

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_json> [pcf_file] [device] [output_asc]"
    echo "  input_json:  JSON file from synthesis"
    echo "  pcf_file:    Pin constraint file (optional)"
    echo "  device:      ICE40 device (default: hx1k, options: hx1k, hx4k, hx8k, lp1k, lp4k, lp8k)"
    echo "  output_asc:  Output ASC file (default: <input_json>.asc)"
    exit 1
fi

INPUT_JSON="$1"
PCF_FILE="${2:-}"
DEVICE="${3:-hx1k}"
OUTPUT_ASC="${4:-${INPUT_JSON%.json}.asc}"

if [ ! -f "$INPUT_JSON" ]; then
    echo "Error: Input JSON file '$INPUT_JSON' not found"
    exit 1
fi

# Validate device
VALID_DEVICES="hx1k hx4k hx8k lp1k lp4k lp8k"
if [[ ! " $VALID_DEVICES " =~ " $DEVICE " ]]; then
    echo "Error: Invalid device '$DEVICE'. Valid options: $VALID_DEVICES"
    exit 1
fi

echo "Running place and route for $DEVICE"
echo "Input:  $INPUT_JSON"
if [ -n "$PCF_FILE" ]; then
    if [ ! -f "$PCF_FILE" ]; then
        echo "Error: PCF file '$PCF_FILE' not found"
        exit 1
    fi
    echo "PCF:    $PCF_FILE"
fi
echo "Output: $OUTPUT_ASC"
echo ""

if [ -n "$PCF_FILE" ]; then
    nextpnr-ice40 --"$DEVICE" --json "$INPUT_JSON" --pcf "$PCF_FILE" --asc "$OUTPUT_ASC"
else
    nextpnr-ice40 --"$DEVICE" --json "$INPUT_JSON" --asc "$OUTPUT_ASC"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Place and route successful: $OUTPUT_ASC"
else
    echo ""
    echo "✗ Place and route failed"
    exit 1
fi


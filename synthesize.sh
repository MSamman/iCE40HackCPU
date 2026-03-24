#!/usr/bin/env bash

# Synthesis script for ICE40 FPGA
# Usage: ./synthesize.sh <design_file> <top_module> [output_json]

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 <design_file> <top_module> [output_json]"
    echo "  design_file: SystemVerilog/Verilog source file"
    echo "  top_module:  Name of the top-level module"
    echo "  output_json: Output JSON file (default: <top_module>.json)"
    exit 1
fi

DESIGN_FILE="$1"
TOP_MODULE="$2"
OUTPUT_JSON="${3:-${TOP_MODULE}.json}"

if [ ! -f "$DESIGN_FILE" ]; then
    echo "Error: Design file '$DESIGN_FILE' not found"
    exit 1
fi

echo "Synthesizing $DESIGN_FILE with top module: $TOP_MODULE"
echo "Output: $OUTPUT_JSON"
echo ""

yosys -p "synth_ice40 -top $TOP_MODULE -json $OUTPUT_JSON" "$DESIGN_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Synthesis successful: $OUTPUT_JSON"
else
    echo ""
    echo "✗ Synthesis failed"
    exit 1
fi


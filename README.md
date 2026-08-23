# nand2tetris — SystemVerilog + Rust

Implementation of the [nand2tetris](https://www.nand2tetris.org/) Hack computer in SystemVerilog,
targeting the ICE40 FPGA (Go board), with a Rust toolchain for assembling and loading programs.

## Structure

| Path | Contents |
|------|----------|
| `hdl/gates/` | Basic logic gates (Not, And, Or, Xor, Mux, Dmux, …) |
| `hdl/adders/` | HalfAdder, FullAdder, 16-bit Adder, Incrementer |
| `hdl/alu/` | ALU |
| `hdl/memory/` | DFF, Register, RAM8 → RAM16k, Counter |
| `hdl/computer/` | CPU, ROM, Memory |
| `hdl/Computer.sv` | Top-level module |
| `hdl/scripts/` | ICE40 synthesis, place & route, bitstream packing, flashing |
| `hackasm/` | Rust CLI: Hack assembler + UART programmer |
| `programs/` | Hack assembly sources (Mult, Fill) |
| `build/` | Generated artifacts (gitignored) |

`programs/` sits at the top level because it is the handoff point between the two halves:
`hackasm` assembles `.asm` into a `.hex` that the HDL consumes.

## Simulation

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/).

```sh
make                # run all testbenches (default target)
make test           # same
make TEST=CPU_tb    # run a single testbench
make lint           # lint with Verilator
make clean          # remove build artifacts
```

Compiled testbenches are cached in `hdl/build/`, so re-running only recompiles what changed.
The simulation itself re-runs every time.

## hackasm

```sh
make hackasm        # cargo build --release
```

## FPGA Synthesis (ICE40)

A Nix dev shell provides the full toolchain (yosys, nextpnr, icestorm, plus Rust):

```sh
nix develop                                    # enter the dev shell
cd hdl
./scripts/synthesize.sh Computer.sv Computer   # synthesise
./scripts/pnr.sh Computer.json                 # place & route
./scripts/pack_bitstream.sh Computer.asc       # pack to .bin
./scripts/flash-bitstream.sh Computer.bin      # flash to board
```

`ROM.sv` selects its program at build time via the `PROGRAM_HEX` define, defaulting to
`program.hex`. Pass an explicit path to synthesise a different program.

# nand2tetris — SystemVerilog

Implementation of the [nand2tetris](https://www.nand2tetris.org/) Hack computer in SystemVerilog, targeting the ICE40 FPGA (Go board).

## Structure

| Directory | Contents |
|-----------|----------|
| `gates/` | Basic logic gates (Not, And, Or, Xor, Mux, Dmux, …) |
| `adders/` | HalfAdder, FullAdder, 16-bit Adder, Incrementer |
| `alu/` | ALU |
| `memory/` | DFF, Register, RAM8 → RAM16k, Counter |
| `computer/` | CPU, ROM, Memory, top-level Computer |
| `programs/` | Hack assembly programs (Mult, Fill) |

## Simulation

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/).

```sh
make test           # run all testbenches
make TEST=CPU_tb    # run a single testbench
make lint           # lint with Verilator
```

## FPGA Synthesis (ICE40)

A Nix dev shell provides the full toolchain (yosys, nextpnr, icestorm):

```sh
nix develop         # enter the dev shell
./synthesize.sh Computer.sv Computer   # synthesise
./pnr.sh                               # place & route
./pack_bitstream.sh                    # pack to .bin
./program.sh                           # flash to board
```
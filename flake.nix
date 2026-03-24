{
  description = "SystemVerilog project for ICE40 FPGA (Go board)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # ICE40 FPGA toolchain
            yosys              # Synthesis tool
            nextpnr            # Place and route for ICE40 (includes ICE40 support)
            icestorm           # Bitstream generation tools (icepack, iceprog, etc.)
            
            # SystemVerilog/Verilog tools
            iverilog           # Icarus Verilog simulator
            verilator          # Verilog/SystemVerilog simulator and linter
            
            # Development tools
            gtkwave            # Waveform viewer
            python3            # Often needed for scripts
            python3Packages.pip
            
            # Utilities
            which
            git
          ];

          shellHook = ''
            echo "ICE40 FPGA Development Environment"
            echo "=================================="
            echo "Available tools:"
            echo "  - yosys: FPGA synthesis"
            echo "  - nextpnr: Place and route (ICE40)"
            echo "  - icepack: Convert ASCII to binary bitstream"
            echo "  - iceprog: Program ICE40 FPGAs"
            echo "  - iverilog: Verilog simulation"
            echo "  - verilator: SystemVerilog/Verilog linting and simulation"
            echo "  - gtkwave: Waveform viewer"
            echo ""
            echo "Example workflow:"
            echo "  1. yosys -p 'synth_ice40 -top <top_module> -json <output>.json' <design>.sv"
            echo "  2. nextpnr-ice40 --hx1k --json <input>.json --pcf <constraints>.pcf --asc <output>.asc"
            echo "  3. icepack <input>.asc <output>.bin"
            echo "  4. iceprog <output>.bin"
          '';
        };
      }
    );
}


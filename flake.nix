{
  description = "Hack computer: SystemVerilog for ICE40 (Go board) + hackasm toolchain";

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
          nativeBuildInputs = with pkgs; [
            pkg-config         # so the serialport crate can locate libudev
          ];

          buildInputs = with pkgs; [
            # ICE40 FPGA toolchain
            yosys              # Synthesis tool
            nextpnr            # Place and route for ICE40 (includes ICE40 support)
            icestorm           # Bitstream generation tools (icepack, iceprog, etc.)

            # SystemVerilog/Verilog tools
            iverilog           # Icarus Verilog simulator
            verilator          # Verilog/SystemVerilog simulator and linter

            # Rust toolchain for hackasm (assembler + UART programmer)
            rustc
            cargo
            rustfmt
            clippy
            rust-analyzer

            # Native dependency of the serialport crate (UART programmer)
            udev

            # Development tools
            gtkwave            # Waveform viewer
            python3            # Often needed for scripts
            python3Packages.pip

            # Utilities
            which
            git
          ];

          # Lets rust-analyzer resolve std sources
          RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}";

          shellHook = ''
            echo "Hack Computer Development Environment"
            echo "===================================="
            echo "HDL:     iverilog, verilator, yosys, nextpnr, icepack, iceprog, gtkwave"
            echo "hackasm: cargo, rustc, clippy, rustfmt, rust-analyzer"
            echo ""
            echo "  make test              # run all HDL testbenches"
            echo "  make TEST=CPU_tb       # run a single testbench"
            echo "  make lint              # lint with Verilator"
            echo "  make hackasm           # build the Rust CLI"
            echo ""
          '';
        };
      }
    );
}

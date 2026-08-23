# Top-level delegator. The HDL half is driven by hdl/Makefile; the Rust half by Cargo.
# TEST= is a command-line variable, so it propagates to the sub-make automatically:
#   make TEST=CPU_tb

.PHONY: test lint clean hackasm all

# Bare `make` runs the HDL tests, as it did before hackasm existed.
.DEFAULT_GOAL := test

all: test hackasm

test lint:
	@$(MAKE) -C hdl $@

hackasm:
	@test -f hackasm/Cargo.toml || { echo "hackasm/Cargo.toml not found - create the crate first"; exit 1; }
	@cargo build --release --manifest-path hackasm/Cargo.toml

clean:
	@$(MAKE) -C hdl clean
	@rm -rf build
	@test -f hackasm/Cargo.toml && cargo clean --manifest-path hackasm/Cargo.toml || true

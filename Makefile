# Top-level delegator. The HDL half is driven by hdl/Makefile; the Rust half by Cargo.
# TEST= is a command-line variable, so it propagates to the sub-make automatically:
#   make TEST=CPU_tb

.PHONY: test lint clean hack all

# Bare `make` runs the HDL tests, as it did before hack existed.
.DEFAULT_GOAL := test

all: test hack

test lint:
	@$(MAKE) -C hdl $@

hack:
	@test -f hack/Cargo.toml || { echo "hack/Cargo.toml not found - create the crate first"; exit 1; }
	@cargo build --release --manifest-path hack/Cargo.toml

clean:
	@$(MAKE) -C hdl clean
	@rm -rf build
	@test -f hack/Cargo.toml && cargo clean --manifest-path hack/Cargo.toml || true

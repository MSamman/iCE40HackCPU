BUILD        := build
BOARDS_DIR   := boards
BOARDS       := $(notdir $(wildcard $(BOARDS_DIR)/*))

# Leaf libraries: linked into every testbench
SRC_DIRS     := gates adders alu memory
ALL_SRC      := $(filter-out $(wildcard $(addsuffix /*_tb.sv,$(SRC_DIRS))), \
                             $(wildcard $(addsuffix /*.sv,$(SRC_DIRS))))

# Linked only into computer/ testbenches: ROM.sv runs $readmemb in an initial
# block, which would warn about a missing program.bin in unrelated testbenches.
COMPUTER_SRC := $(filter-out $(wildcard computer/*_tb.sv), $(wildcard computer/*.sv))

vpath %.sv $(SRC_DIRS) computer

COMPUTER_TESTS := $(basename $(notdir $(wildcard computer/*_tb.sv)))
TESTS          := $(basename $(notdir $(wildcard $(addsuffix /*_tb.sv,$(SRC_DIRS))))) $(COMPUTER_TESTS)
BINS           := $(addprefix $(BUILD)/,$(TESTS))

# Every board's synthesis top is named `top`; boards/<name>/*.pcf constrains its
# ports by that name, so the convention is load-bearing.
TOP     ?= top
PROGRAM ?= program.hex

# Board targets select boards/<BOARD>/ for HDL, pin constraints and settings.
BOARD_GOALS := synth pnr bitstream flash lint-board

ifneq ($(filter $(BOARD_GOALS),$(MAKECMDGOALS)),)
  ifeq ($(strip $(BOARD)),)
    $(error BOARD not set. Usage: make $(firstword $(filter $(BOARD_GOALS),$(MAKECMDGOALS))) BOARD=<name>. Available: $(BOARDS))
  endif
  ifeq ($(wildcard $(BOARDS_DIR)/$(BOARD)),)
    $(error no board '$(BOARD)' under $(BOARDS_DIR)/. Available: $(BOARDS))
  endif
endif

BOARD_DIR := $(BOARDS_DIR)/$(BOARD)
BOARD_SRC := $(wildcard $(BOARD_DIR)/*.sv)
BOARD_PCF := $(wildcard $(BOARD_DIR)/*.pcf)

# Per-board settings (DEVICE, PACKAGE, FREQ); absent for boards that suit the
# defaults. FREQ is the nextpnr timing target in MHz — set it to the clock the
# design actually runs at, or nextpnr's own 12 MHz default is what PASS means.
-include $(BOARD_DIR)/board.mk
DEVICE  ?= hx1k
PACKAGE ?= tq144

# board_map.svh lives in the board dir, hence the -I.
SYNTH_SRC := $(BOARD_SRC) $(COMPUTER_SRC) $(ALL_SRC)

# Boards carrying HDL, so `make lint` can skip config-only ones (e.g. sim).
LINT_BOARDS := $(foreach b,$(BOARDS),$(if $(wildcard $(BOARDS_DIR)/$(b)/*.sv),$(b)))

.PHONY: test lint lint-board clean boards synth pnr bitstream flash $(TESTS)

test: $(if $(TEST),$(TEST),$(TESTS))

$(addprefix $(BUILD)/,$(COMPUTER_TESTS)): EXTRA_SRC = $(COMPUTER_SRC)

# Compilation is cached in $(BUILD); the simulation itself re-runs every time.
$(TESTS): %: $(BUILD)/%
	@echo "--- $* ---"
	@vvp $<

# Testbench is passed first so `define in *_tb.sv is seen before `ifndef in sources (e.g. ROM_tb -> ROM).
# COMPUTER_SRC is a prerequisite of every binary but is only linked where EXTRA_SRC is set;
# that over-approximates the dependency graph, at the cost of occasional extra rebuilds.
$(BINS): $(BUILD)/%: %.sv $(ALL_SRC) $(COMPUTER_SRC) | $(BUILD)
	@iverilog -g2012 -s $* -o $@ $< $(ALL_SRC) $(EXTRA_SRC)

$(BUILD):
	@mkdir -p $@

boards:
	@for b in $(BOARDS); do echo "$$b"; done

# Lints the board-agnostic core, then every board's top against it.
lint:
	@for b in $(LINT_BOARDS); do \
	  echo "--- lint $$b ---"; \
	  verilator --lint-only --sv -I$(BOARDS_DIR)/$$b --top-module $(TOP) \
	    $(BOARDS_DIR)/$$b/*.sv $(COMPUTER_SRC) $(ALL_SRC) || exit 1; \
	done

lint-board:
	@verilator --lint-only --sv -I$(BOARD_DIR) --top-module $(TOP) $(SYNTH_SRC)

synth:     $(BUILD)/$(BOARD).json
pnr:       $(BUILD)/$(BOARD).asc
bitstream: $(BUILD)/$(BOARD).bin

# yosys and nextpnr are driven directly: scripts/synthesize.sh takes only a
# single design file, and scripts/pnr.sh cannot pass --package. The packing and
# flashing stages use the scripts as-is.
# $(PROGRAM) is a prerequisite because it is baked into the bitstream by
# $readmem at elaboration: a new program must force a resynthesis.
$(BUILD)/$(BOARD).json: $(SYNTH_SRC) $(wildcard $(PROGRAM)) | $(BUILD)
	@yosys -p 'read_verilog -sv -I$(BOARD_DIR) -DPROGRAM_BIN="$(PROGRAM)" $(SYNTH_SRC); synth_ice40 -top $(TOP) -json $@'

$(BUILD)/$(BOARD).asc: $(BUILD)/$(BOARD).json $(BOARD_PCF)
	@test -n "$(BOARD_PCF)" || { \
	  echo "make: board '$(BOARD)' has no .pcf — simulation-only boards cannot be placed."; \
	  exit 1; }
	@nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) $(if $(FREQ),--freq $(FREQ)) \
	  --json $< --pcf $(BOARD_PCF) --asc $@

$(BUILD)/$(BOARD).bin: $(BUILD)/$(BOARD).asc
	@scripts/pack_bitstream.sh $< $@

flash: $(BUILD)/$(BOARD).bin
	@scripts/flash-bitstream.sh $<

clean:
	@rm -rf $(BUILD)

attach:
	@usbipd.exe attach --wsl --busid $(USB_BUSID) 2>&1 | grep -v '^usbipd: info' || true
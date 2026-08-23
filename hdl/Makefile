BUILD        := build

# Leaf libraries: linked into every testbench
SRC_DIRS     := gates adders alu memory
ALL_SRC      := $(filter-out $(wildcard $(addsuffix /*_tb.sv,$(SRC_DIRS))), \
                             $(wildcard $(addsuffix /*.sv,$(SRC_DIRS))))

# Linked only into computer/ testbenches: ROM.sv runs $readmemh in an initial
# block, which would warn about a missing program.hex in unrelated testbenches.
COMPUTER_SRC := $(filter-out $(wildcard computer/*_tb.sv), $(wildcard computer/*.sv))

vpath %.sv $(SRC_DIRS) computer

COMPUTER_TESTS := $(basename $(notdir $(wildcard computer/*_tb.sv)))
TESTS          := $(basename $(notdir $(wildcard $(addsuffix /*_tb.sv,$(SRC_DIRS))))) $(COMPUTER_TESTS)
BINS           := $(addprefix $(BUILD)/,$(TESTS))

.PHONY: test lint clean $(TESTS)

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

lint:
	@verilator --lint-only --sv --top-module Computer Computer.sv $(ALL_SRC) $(COMPUTER_SRC)

clean:
	@rm -rf $(BUILD)

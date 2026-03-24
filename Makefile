ALL_SRC          := $(filter-out $(wildcard gates/*_tb.sv) $(wildcard adders/*_tb.sv) $(wildcard alu/*_tb.sv) $(wildcard memory/*_tb.sv), \
                                  $(wildcard gates/*.sv) $(wildcard adders/*.sv) $(wildcard alu/*.sv) $(wildcard memory/*.sv))
COMPUTER_SRC     := $(filter-out $(wildcard computer/*_tb.sv), $(wildcard computer/*.sv))

GATE_TESTS       := $(basename $(notdir $(wildcard gates/*_tb.sv)))
ADDER_TESTS      := $(basename $(notdir $(wildcard adders/*_tb.sv)))
ALU_TESTS        := $(basename $(notdir $(wildcard alu/*_tb.sv)))
MEMORY_TESTS     := $(basename $(notdir $(wildcard memory/*_tb.sv)))
COMPUTER_TESTS   := $(basename $(notdir $(wildcard computer/*_tb.sv)))
TESTS            := $(GATE_TESTS) $(ADDER_TESTS) $(ALU_TESTS) $(MEMORY_TESTS) $(COMPUTER_TESTS)

.PHONY: test $(TESTS)

test: $(if $(TEST),$(TEST),$(TESTS))

$(GATE_TESTS): %: gates/%.sv
	@echo "--- $< ---"
	@iverilog -g2012 -s $@ -o /tmp/$@ $(ALL_SRC) $< && vvp /tmp/$@

$(ADDER_TESTS): %: adders/%.sv
	@echo "--- $< ---"
	@iverilog -g2012 -s $@ -o /tmp/$@ $(ALL_SRC) $< && vvp /tmp/$@

$(ALU_TESTS): %: alu/%.sv
	@echo "--- $< ---"
	@iverilog -g2012 -s $@ -o /tmp/$@ $(ALL_SRC) $< && vvp /tmp/$@

$(MEMORY_TESTS): %: memory/%.sv
	@echo "--- $< ---"
	@iverilog -g2012 -s $@ -o /tmp/$@ $(ALL_SRC) $< && vvp /tmp/$@

# Testbench is passed first so `define in *_tb.sv is seen before `ifndef in sources (e.g. ROM_tb -> ROM)
$(COMPUTER_TESTS): %: computer/%.sv
	@echo "--- $< ---"
	@iverilog -g2012 -s $@ -o /tmp/$@ $< $(ALL_SRC) $(COMPUTER_SRC) && vvp /tmp/$@

lint:
	@verilator --lint-only --sv --top-module Computer Computer.sv $(ALL_SRC) $(COMPUTER_SRC)

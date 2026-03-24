module CPU_tb;
  reg  [15:0] inM;
  reg  [15:0] instruction;
  reg         reset;
  reg         clk;
  wire [15:0] outM;
  wire        writeM;
  wire [15:0] addressM;
  wire [15:0] pc;

  CPU dut(
    .clk(clk),
    .inM(inM),
    .instruction(instruction),
    .reset(reset),
    .outM(outM),
    .writeM(writeM),
    .addressM(addressM),
    .pc(pc)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  localparam integer NUM_TESTS = 7;
  reg  [15:0] inM_in          [0:NUM_TESTS-1];
  reg  [15:0] instruction_in  [0:NUM_TESTS-1];
  reg         reset_in        [0:NUM_TESTS-1];
  reg  [15:0] expected_outM   [0:NUM_TESTS-1];
  reg         expected_writeM [0:NUM_TESTS-1];
  reg  [15:0] expected_addressM [0:NUM_TESTS-1];
  reg  [15:0] expected_pc     [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  task tick;
    @(posedge clk);
    #1;
  endtask

  initial begin
    $dumpfile("/tmp/CPU_tb.vcd");
    $dumpvars(0, CPU_tb);

    // A-instruction tests
    inM_in[0] = 16'h00; instruction_in[0] = 16'h00FF; reset_in[0] = 1'b0;
    expected_outM[0] = 16'hXXXX; expected_writeM[0] = 1'b0; expected_addressM[0] = 16'h00FF; expected_pc[0] = 16'h0001;

    inM_in[1] = 16'h00; instruction_in[1] = 16'h00FF; reset_in[1] = 1'b1;
    expected_outM[1] = 16'hXXXX; expected_writeM[1] = 1'b0; expected_addressM[1] = 16'h00FF; expected_pc[1] = 16'h0000;

    // C-instruction tests
    // load M -> A and jump
    inM_in[2] = 16'h00FF; instruction_in[2] = 16'b1111110000100111; reset_in[2] = 1'b0;
    expected_outM[2] = 16'hXXXX; expected_writeM[2] = 1'b0; expected_addressM[2] = 16'h00FF; expected_pc[2] = 16'h00FF;

    // write M to A, D and M
    inM_in[3] = 16'h00EE; instruction_in[3] = 16'b1111110000111000; reset_in[3] = 1'b0;
    expected_outM[3] = 16'h00EE; expected_writeM[3] = 1'b1; expected_addressM[3] = 16'h00EE; expected_pc[3] = 16'h0100;

    // jump fail on D - M < 0
    inM_in[4] = 16'h0022; instruction_in[4] = 16'b1111010011001100; reset_in[4] = 1'b0;
    expected_outM[4] = 16'h00CC; expected_writeM[4] = 1'b1; expected_addressM[4] = 16'h00EE; expected_pc[4] = 16'h0101;

    // jump on A - D == 0
    inM_in[5] = 16'h0F0F; instruction_in[5] = 16'b1110000111001010; reset_in[5] = 1'b0;
    expected_outM[5] = 16'h0000; expected_writeM[5] = 1'b1; expected_addressM[5] = 16'h00EE; expected_pc[5] = 16'h00EE;

    // outM = D + M
    inM_in[6] = 16'h0100; instruction_in[6] = 16'b1111000010001000; reset_in[6] = 1'b0;
    expected_outM[6] = 16'h01EE; expected_writeM[6] = 1'b1; expected_addressM[6] = 16'h00EE; expected_pc[6] = 16'h00EF;

    pass_count = 0;
    fail_count = 0;

    reset = 1;
    inM = 0;
    instruction = 0;
    tick;
    reset = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      inM         = inM_in[i];
      instruction = instruction_in[i];
      reset       = reset_in[i];
      tick;
      assert ((outM === expected_outM[i] || !writeM) && writeM == expected_writeM[i] &&
              addressM === expected_addressM[i] && pc == expected_pc[i]) begin
        pass_count++;
        $display("PASS [%0d]: inM=%h instruction=%h reset=%b | outM=%h writeM=%b addressM=%h pc=%h",
          i, inM, instruction, reset, outM, writeM, addressM, pc);
      end else begin
        fail_count++;
        $error("FAIL [%0d]: inM=%h instruction=%h reset=%b | outM=%h writeM=%b addressM=%h pc=%h, expected outM=%h writeM=%b addressM=%h pc=%h",
          i, inM, instruction, reset, outM, writeM, addressM, pc,
          expected_outM[i], expected_writeM[i], expected_addressM[i], expected_pc[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
    $finish;
  end

endmodule
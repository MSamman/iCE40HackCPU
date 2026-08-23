`define PROGRAM_HEX "computer/rom_test.hex"

module ROM_tb;
  reg  [9:0]  address;
  wire [15:0] instruction;

  ROM dut(
    .address(address),
    .instruction(instruction)
  );

  localparam integer NUM_TESTS = 16;
  reg [9:0]  address_in [0:NUM_TESTS-1];
  reg [15:0] expected   [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/ROM_tb.vcd");
    $dumpvars(1, ROM_tb);

    address_in[0]  = 10'h000; expected[0]  = 16'h0000;
    address_in[1]  = 10'h001; expected[1]  = 16'h0001;
    address_in[2]  = 10'h002; expected[2]  = 16'h0002;
    address_in[3]  = 10'h003; expected[3]  = 16'h0003;
    address_in[4]  = 10'h004; expected[4]  = 16'h0004;
    address_in[5]  = 10'h005; expected[5]  = 16'h0005;
    address_in[6]  = 10'h006; expected[6]  = 16'h0006;
    address_in[7]  = 10'h007; expected[7]  = 16'h0007;
    address_in[8]  = 10'h3F8; expected[8]  = 16'h0008;
    address_in[9]  = 10'h3F9; expected[9]  = 16'h0009;
    address_in[10] = 10'h3FA; expected[10] = 16'h000A;
    address_in[11] = 10'h3FB; expected[11] = 16'h000B;
    address_in[12] = 10'h3FC; expected[12] = 16'h000C;
    address_in[13] = 10'h3FD; expected[13] = 16'h000D;
    address_in[14] = 10'h3FE; expected[14] = 16'h000E;
    address_in[15] = 10'h3FF; expected[15] = 16'h000F;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      address = address_in[i];
      #1;
      assert (instruction == expected[i]) begin
        pass_count++;
        $display("PASS: address=%h | instruction=%h", address, instruction);
      end else begin
        fail_count++;
        $error("FAIL: address=%h | instruction=%h, expected %h", address, instruction, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
    $finish;
  end
endmodule

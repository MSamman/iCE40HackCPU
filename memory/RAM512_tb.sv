module RAM512_tb;
  reg        clk;
  reg [0:15] in;
  reg        load;
  reg [0:8]  address;
  wire [0:15] out;

  RAM512 dut(
    .clk(clk),
    .in(in),
    .load(load),
    .address(address),
    .out(out)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  localparam integer NUM_TESTS = 24;
  reg [0:15] in_in      [0:NUM_TESTS-1];
  reg        load_in    [0:NUM_TESTS-1];
  reg [0:8]  address_in [0:NUM_TESTS-1];
  reg [0:15] expected   [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  task tick;
    @(posedge clk);
    #1;
  endtask

  initial begin
    $dumpfile("/tmp/RAM512_tb.vcd");
    // $dumpvars(1, RAM512_tb);

    in_in[0] = 16'h7777; load_in[0] = 1'b0; address_in[0] = 9'b000000000; expected[0] = 16'h0000;
    in_in[1] = 16'h7777; load_in[1] = 1'b0; address_in[1] = 9'b001000000; expected[1] = 16'h0000;
    in_in[2] = 16'h7777; load_in[2] = 1'b0; address_in[2] = 9'b010000000; expected[2] = 16'h0000;
    in_in[3] = 16'h7777; load_in[3] = 1'b0; address_in[3] = 9'b011000000; expected[3] = 16'h0000;
    in_in[4] = 16'h7777; load_in[4] = 1'b0; address_in[4] = 9'b100000000; expected[4] = 16'h0000;
    in_in[5] = 16'h7777; load_in[5] = 1'b0; address_in[5] = 9'b101000000; expected[5] = 16'h0000;
    in_in[6] = 16'h7777; load_in[6] = 1'b0; address_in[6] = 9'b110000000; expected[6] = 16'h0000;
    in_in[7] = 16'h7777; load_in[7] = 1'b0; address_in[7] = 9'b111000000; expected[7] = 16'h0000;
    in_in[8] = 16'h2222; load_in[8] = 1'b1; address_in[8] = 9'b000000000; expected[8] = 16'h2222;
    in_in[9] = 16'h4444; load_in[9] = 1'b1; address_in[9] = 9'b001000000; expected[9] = 16'h4444;
    in_in[10] = 16'h6666; load_in[10] = 1'b1; address_in[10] = 9'b010000000; expected[10] = 16'h6666;
    in_in[11] = 16'h8888; load_in[11] = 1'b1; address_in[11] = 9'b011000000; expected[11] = 16'h8888;
    in_in[12] = 16'hAAAA; load_in[12] = 1'b1; address_in[12] = 9'b100000000; expected[12] = 16'hAAAA;
    in_in[13] = 16'hCCCC; load_in[13] = 1'b1; address_in[13] = 9'b101000000; expected[13] = 16'hCCCC;
    in_in[14] = 16'hEEEE; load_in[14] = 1'b1; address_in[14] = 9'b110000000; expected[14] = 16'hEEEE;
    in_in[15] = 16'hFFFF; load_in[15] = 1'b1; address_in[15] = 9'b111000000; expected[15] = 16'hFFFF;
    in_in[16] = 16'h0000; load_in[16] = 1'b0; address_in[16] = 9'b000000000; expected[16] = 16'h2222;
    in_in[17] = 16'h0000; load_in[17] = 1'b0; address_in[17] = 9'b001000000; expected[17] = 16'h4444;
    in_in[18] = 16'h0000; load_in[18] = 1'b0; address_in[18] = 9'b010000000; expected[18] = 16'h6666;
    in_in[19] = 16'h0000; load_in[19] = 1'b0; address_in[19] = 9'b011000000; expected[19] = 16'h8888;
    in_in[20] = 16'h0000; load_in[20] = 1'b0; address_in[20] = 9'b100000000; expected[20] = 16'hAAAA;
    in_in[21] = 16'h0000; load_in[21] = 1'b0; address_in[21] = 9'b101000000; expected[21] = 16'hCCCC;
    in_in[22] = 16'h0000; load_in[22] = 1'b0; address_in[22] = 9'b110000000; expected[22] = 16'hEEEE;
    in_in[23] = 16'h0000; load_in[23] = 1'b0; address_in[23] = 9'b111000000; expected[23] = 16'hFFFF;

    pass_count = 0;
    fail_count = 0;

    // Reset
    for (i = 0; i < 8; i++) begin
      in = 16'h0000;
      load = 1;
      address = i << 6;
      tick;
    end

    for (i = 0; i < NUM_TESTS; i++) begin
      in      = in_in[i];
      load    = load_in[i];
      address = address_in[i];
      tick;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: in=%h load=%b address=%h | out=%h", in, load, address, out);
      end else begin
        fail_count++;
        $error("FAIL: in=%h load=%b address=%h | out=%h, expected %h", in, load, address, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
    $finish;
  end

endmodule

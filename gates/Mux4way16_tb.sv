module Mux4way16_tb;
  reg  [15:0] a;
  reg  [15:0] b;
  reg  [15:0] c;
  reg  [15:0] d;
  reg  [1:0]  sel;
  wire [15:0] out;

  Mux4way16 dut(
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .sel(sel),
    .out(out)
  );

  localparam integer NUM_TESTS = 8;
  reg[15:0] a_in    [0:NUM_TESTS-1];
  reg[15:0] b_in    [0:NUM_TESTS-1];
  reg[15:0] c_in    [0:NUM_TESTS-1];
  reg[15:0] d_in    [0:NUM_TESTS-1];
  reg[1:0]  sel_in  [0:NUM_TESTS-1];
  reg[15:0] expected[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Mux4way16_tb.vcd");
    $dumpvars(0, Mux4way16_tb);

    a_in[0] = 16'h0000; b_in[0] = 16'hFFFF; c_in[0] = 16'hFFFF; d_in[0] = 16'hFFFF; sel_in[0] = 2'b00; expected[0] = 16'h0000;
    a_in[1] = 16'hFFFF; b_in[1] = 16'h0000; c_in[1] = 16'h0000; d_in[1] = 16'h0000; sel_in[1] = 2'b00; expected[1] = 16'hFFFF;
    a_in[2] = 16'hFFFF; b_in[2] = 16'h0000; c_in[2] = 16'hFFFF; d_in[2] = 16'hFFFF; sel_in[2] = 2'b01; expected[2] = 16'h0000;
    a_in[3] = 16'h0000; b_in[3] = 16'hFFFF; c_in[3] = 16'h0000; d_in[3] = 16'h0000; sel_in[3] = 2'b01; expected[3] = 16'hFFFF;
    a_in[4] = 16'hFFFF; b_in[4] = 16'hFFFF; c_in[4] = 16'h0000; d_in[4] = 16'hFFFF; sel_in[4] = 2'b10; expected[4] = 16'h0000;
    a_in[5] = 16'h0000; b_in[5] = 16'h0000; c_in[5] = 16'hFFFF; d_in[5] = 16'h0000; sel_in[5] = 2'b10; expected[5] = 16'hFFFF;
    a_in[6] = 16'hFFFF; b_in[6] = 16'hFFFF; c_in[6] = 16'hFFFF; d_in[6] = 16'h0000; sel_in[6] = 2'b11; expected[6] = 16'h0000;
    a_in[7] = 16'h0000; b_in[7] = 16'h0000; c_in[7] = 16'h0000; d_in[7] = 16'hFFFF; sel_in[7] = 2'b11; expected[7] = 16'hFFFF;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      a   = a_in[i];
      b   = b_in[i];
      c   = c_in[i];
      d   = d_in[i];
      sel = sel_in[i];
      #10;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: a=%d b=%d c=%d d=%d sel=%b | out=%d", a, b, c, d, sel, out);
      end else begin
        fail_count++;
        $error("FAIL: a=%d b=%d c=%d d=%d sel=%b | out=%d, expected %d", a, b, c, d, sel, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

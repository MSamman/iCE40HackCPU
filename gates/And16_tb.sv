module And16_tb;
  reg  [15:0] a;
  reg  [15:0] b;
  wire [15:0] out;

  And16 dut(
    .a(a),
    .b(b),
    .out(out)
  );

  localparam integer NUM_TESTS = 4;
  reg[15:0] a_in[0:NUM_TESTS-1];
  reg[15:0] b_in[0:NUM_TESTS-1];
  reg[15:0] expected[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/And16_tb.vcd");
    $dumpvars(0, And16_tb);

    a_in[0] = 16'h0000; b_in[0] = 16'h0000; expected[0] = 16'h0000;
    a_in[1] = 16'h0000; b_in[1] = 16'hFFFF; expected[1] = 16'h0000;
    a_in[2] = 16'hFFFF; b_in[2] = 16'h0000; expected[2] = 16'h0000;
    a_in[3] = 16'hFFFF; b_in[3] = 16'hFFFF; expected[3] = 16'hFFFF;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      a = a_in[i];
      b = b_in[i];
      #10;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: a=%d b=%d | out=%d", a, b, out);
      end else begin
        fail_count++;
        $error("FAIL: a=%d b=%d | out=%d, expected %d", a, b, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

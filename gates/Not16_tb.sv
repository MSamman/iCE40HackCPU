module Not16_tb;
  reg  [15:0] in;
  wire [15:0] out;

  Not16 dut(
    .in(in),
    .out(out)
  );

  localparam integer NUM_TESTS = 4;
  reg[15:0] in_in[0:NUM_TESTS-1];
  reg[15:0] expected[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Not16_tb.vcd");
    $dumpvars(0, Not16_tb);

    in_in[0] = 16'b0000000000000000; expected[0] = 16'b1111111111111111;
    in_in[1] = 16'b0101010101010101; expected[1] = 16'b1010101010101010;
    in_in[2] = 16'b1010101010101010; expected[2] = 16'b0101010101010101;
    in_in[3] = 16'b1111111111111111; expected[3] = 16'b0000000000000000;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      in = in_in[i];
      #10;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: in=%d | out=%d", in, out);
      end else begin
        fail_count++;
        $error("FAIL: in=%d | out=%d, expected %d", in, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

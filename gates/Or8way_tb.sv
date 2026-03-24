module Or8way_tb;
  reg  [7:0] in;
  wire out;

  Or8way dut(
    .in(in),
    .out(out)
  );

  localparam integer NUM_TESTS = 9;
  reg[7:0] in_in[0:NUM_TESTS-1];
  reg      expected[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Or8way_tb.vcd");
    $dumpvars(0, Or8way_tb);

    in_in[0] = 8'b00000000; expected[0] = 0;
    in_in[1] = 8'b00000001; expected[1] = 1;
    in_in[2] = 8'b00000010; expected[2] = 1;
    in_in[3] = 8'b00000100; expected[3] = 1;
    in_in[4] = 8'b00001000; expected[4] = 1;
    in_in[5] = 8'b00010000; expected[5] = 1;
    in_in[6] = 8'b00100000; expected[6] = 1;
    in_in[7] = 8'b01000000; expected[7] = 1;
    in_in[8] = 8'b10000000; expected[8] = 1;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      in = in_in[i];
      #10;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: in=%b | out=%b", in, out);
      end else begin
        fail_count++;
        $error("FAIL: in=%b | out=%b, expected %b", in, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

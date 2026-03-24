module Not_tb;
  reg in;
  wire out;

  Not dut(
    .in(in),
    .out(out)
  );

  localparam integer NUM_TESTS = 2;
  reg in_in   [0:NUM_TESTS-1];
  reg expected[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Not_tb.vcd");
    $dumpvars(0, Not_tb);

    in_in[0] = 0; expected[0] = 1;
    in_in[1] = 1; expected[1] = 0;

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

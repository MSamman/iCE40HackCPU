module Mux_tb;
  reg a, b, sel;
  wire out;

  Mux dut(
    .a(a),
    .b(b),
    .sel(sel),
    .out(out)
  );

  localparam integer NUM_TESTS = 8;
  reg a_in    [0:NUM_TESTS-1];
  reg b_in    [0:NUM_TESTS-1];
  reg sel_in  [0:NUM_TESTS-1];
  reg expected[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Mux_tb.vcd");
    $dumpvars(0, Mux_tb);

    a_in[0] = 0; b_in[0] = 0; sel_in[0] = 0; expected[0] = 0;
    a_in[1] = 0; b_in[1] = 1; sel_in[1] = 0; expected[1] = 0;
    a_in[2] = 1; b_in[2] = 0; sel_in[2] = 0; expected[2] = 1;
    a_in[3] = 1; b_in[3] = 1; sel_in[3] = 0; expected[3] = 1;
    a_in[4] = 0; b_in[4] = 0; sel_in[4] = 1; expected[4] = 0;
    a_in[5] = 0; b_in[5] = 1; sel_in[5] = 1; expected[5] = 1;
    a_in[6] = 1; b_in[6] = 0; sel_in[6] = 1; expected[6] = 0;
    a_in[7] = 1; b_in[7] = 1; sel_in[7] = 1; expected[7] = 1;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      a   = a_in[i];
      b   = b_in[i];
      sel = sel_in[i];
      #10;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: a=%b b=%b sel=%b | out=%b", a, b, sel, out);
      end else begin
        fail_count++;
        $error("FAIL: a=%b b=%b sel=%b | out=%b, expected %b", a, b, sel, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

module Dmux_tb;
  reg in, sel;
  wire a, b;

  Dmux dut(
    .in(in),
    .sel(sel),
    .a(a),
    .b(b)
  );

  localparam integer NUM_TESTS = 4;
  reg in_in     [0:NUM_TESTS-1];
  reg sel_in    [0:NUM_TESTS-1];
  reg expected_a[0:NUM_TESTS-1];
  reg expected_b[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Dmux_tb.vcd");
    $dumpvars(0, Dmux_tb);

    in_in[0] = 0; sel_in[0] = 0; expected_a[0] = 0; expected_b[0] = 0;
    in_in[1] = 0; sel_in[1] = 1; expected_a[1] = 0; expected_b[1] = 0;
    in_in[2] = 1; sel_in[2] = 0; expected_a[2] = 1; expected_b[2] = 0;
    in_in[3] = 1; sel_in[3] = 1; expected_a[3] = 0; expected_b[3] = 1;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      in  = in_in[i];
      sel = sel_in[i];
      #10;
      assert (a == expected_a[i] && b == expected_b[i]) begin
        pass_count++;
        $display("PASS: in=%b sel=%b | a=%b b=%b", in, sel, a, b);
      end else begin
        fail_count++;
        $error("FAIL: in=%b sel=%b | a=%b, expected %b b=%b, expected %b",
               in, sel, a, expected_a[i], b, expected_b[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

module Dmux4way_tb;
  reg        in;
  reg  [1:0] sel;
  wire       a, b, c, d;

  Dmux4way dut(
    .in(in),
    .sel(sel),
    .a(a),
    .b(b),
    .c(c),
    .d(d)
  );

  localparam integer NUM_TESTS = 8;
  reg       in_in     [0:NUM_TESTS-1];
  reg[1:0]  sel_in    [0:NUM_TESTS-1];
  reg       expected_a[0:NUM_TESTS-1];
  reg       expected_b[0:NUM_TESTS-1];
  reg       expected_c[0:NUM_TESTS-1];
  reg       expected_d[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Dmux4way_tb.vcd");
    $dumpvars(0, Dmux4way_tb);

    in_in[0] = 0; sel_in[0] = 2'b00; expected_a[0] = 0; expected_b[0] = 0; expected_c[0] = 0; expected_d[0] = 0;
    in_in[1] = 0; sel_in[1] = 2'b01; expected_a[1] = 0; expected_b[1] = 0; expected_c[1] = 0; expected_d[1] = 0;
    in_in[2] = 0; sel_in[2] = 2'b10; expected_a[2] = 0; expected_b[2] = 0; expected_c[2] = 0; expected_d[2] = 0;
    in_in[3] = 0; sel_in[3] = 2'b11; expected_a[3] = 0; expected_b[3] = 0; expected_c[3] = 0; expected_d[3] = 0;
    in_in[4] = 1; sel_in[4] = 2'b00; expected_a[4] = 1; expected_b[4] = 0; expected_c[4] = 0; expected_d[4] = 0;
    in_in[5] = 1; sel_in[5] = 2'b01; expected_a[5] = 0; expected_b[5] = 1; expected_c[5] = 0; expected_d[5] = 0;
    in_in[6] = 1; sel_in[6] = 2'b10; expected_a[6] = 0; expected_b[6] = 0; expected_c[6] = 1; expected_d[6] = 0;
    in_in[7] = 1; sel_in[7] = 2'b11; expected_a[7] = 0; expected_b[7] = 0; expected_c[7] = 0; expected_d[7] = 1;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      in  = in_in[i];
      sel = sel_in[i];
      #10;
      assert (a == expected_a[i] && b == expected_b[i] &&
              c == expected_c[i] && d == expected_d[i]) begin
        pass_count++;
        $display("PASS: in=%b sel=%b | a=%b b=%b c=%b d=%b", in, sel, a, b, c, d);
      end else begin
        fail_count++;
        $error("FAIL: in=%b sel=%b | a=%b, expected %b b=%b, expected %b c=%b, expected %b d=%b, expected %b",
               in, sel, a, expected_a[i], b, expected_b[i], c, expected_c[i], d, expected_d[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

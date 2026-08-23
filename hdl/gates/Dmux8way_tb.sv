module Dmux8way_tb;
  reg        in;
  reg  [2:0] sel;
  wire       a, b, c, d, e, f, g, h;

  Dmux8way dut(
    .in(in),
    .sel(sel),
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .e(e),
    .f(f),
    .g(g),
    .h(h)
  );

  localparam integer NUM_TESTS = 16;
  reg       in_in     [0:NUM_TESTS-1];
  reg[2:0]  sel_in    [0:NUM_TESTS-1];
  reg       expected_a[0:NUM_TESTS-1];
  reg       expected_b[0:NUM_TESTS-1];
  reg       expected_c[0:NUM_TESTS-1];
  reg       expected_d[0:NUM_TESTS-1];
  reg       expected_e[0:NUM_TESTS-1];
  reg       expected_f[0:NUM_TESTS-1];
  reg       expected_g[0:NUM_TESTS-1];
  reg       expected_h[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Dmux8way_tb.vcd");
    $dumpvars(0, Dmux8way_tb);

    in_in[0]  = 0; sel_in[0]  = 3'b000; expected_a[0]  = 0; expected_b[0]  = 0; expected_c[0]  = 0; expected_d[0]  = 0; expected_e[0]  = 0; expected_f[0]  = 0; expected_g[0]  = 0; expected_h[0]  = 0;
    in_in[1]  = 0; sel_in[1]  = 3'b001; expected_a[1]  = 0; expected_b[1]  = 0; expected_c[1]  = 0; expected_d[1]  = 0; expected_e[1]  = 0; expected_f[1]  = 0; expected_g[1]  = 0; expected_h[1]  = 0;
    in_in[2]  = 0; sel_in[2]  = 3'b010; expected_a[2]  = 0; expected_b[2]  = 0; expected_c[2]  = 0; expected_d[2]  = 0; expected_e[2]  = 0; expected_f[2]  = 0; expected_g[2]  = 0; expected_h[2]  = 0;
    in_in[3]  = 0; sel_in[3]  = 3'b011; expected_a[3]  = 0; expected_b[3]  = 0; expected_c[3]  = 0; expected_d[3]  = 0; expected_e[3]  = 0; expected_f[3]  = 0; expected_g[3]  = 0; expected_h[3]  = 0;
    in_in[4]  = 0; sel_in[4]  = 3'b100; expected_a[4]  = 0; expected_b[4]  = 0; expected_c[4]  = 0; expected_d[4]  = 0; expected_e[4]  = 0; expected_f[4]  = 0; expected_g[4]  = 0; expected_h[4]  = 0;
    in_in[5]  = 0; sel_in[5]  = 3'b101; expected_a[5]  = 0; expected_b[5]  = 0; expected_c[5]  = 0; expected_d[5]  = 0; expected_e[5]  = 0; expected_f[5]  = 0; expected_g[5]  = 0; expected_h[5]  = 0;
    in_in[6]  = 0; sel_in[6]  = 3'b110; expected_a[6]  = 0; expected_b[6]  = 0; expected_c[6]  = 0; expected_d[6]  = 0; expected_e[6]  = 0; expected_f[6]  = 0; expected_g[6]  = 0; expected_h[6]  = 0;
    in_in[7]  = 0; sel_in[7]  = 3'b111; expected_a[7]  = 0; expected_b[7]  = 0; expected_c[7]  = 0; expected_d[7]  = 0; expected_e[7]  = 0; expected_f[7]  = 0; expected_g[7]  = 0; expected_h[7]  = 0;
    in_in[8]  = 1; sel_in[8]  = 3'b000; expected_a[8]  = 1; expected_b[8]  = 0; expected_c[8]  = 0; expected_d[8]  = 0; expected_e[8]  = 0; expected_f[8]  = 0; expected_g[8]  = 0; expected_h[8]  = 0;
    in_in[9]  = 1; sel_in[9]  = 3'b001; expected_a[9]  = 0; expected_b[9]  = 1; expected_c[9]  = 0; expected_d[9]  = 0; expected_e[9]  = 0; expected_f[9]  = 0; expected_g[9]  = 0; expected_h[9]  = 0;
    in_in[10] = 1; sel_in[10] = 3'b010; expected_a[10] = 0; expected_b[10] = 0; expected_c[10] = 1; expected_d[10] = 0; expected_e[10] = 0; expected_f[10] = 0; expected_g[10] = 0; expected_h[10] = 0;
    in_in[11] = 1; sel_in[11] = 3'b011; expected_a[11] = 0; expected_b[11] = 0; expected_c[11] = 0; expected_d[11] = 1; expected_e[11] = 0; expected_f[11] = 0; expected_g[11] = 0; expected_h[11] = 0;
    in_in[12] = 1; sel_in[12] = 3'b100; expected_a[12] = 0; expected_b[12] = 0; expected_c[12] = 0; expected_d[12] = 0; expected_e[12] = 1; expected_f[12] = 0; expected_g[12] = 0; expected_h[12] = 0;
    in_in[13] = 1; sel_in[13] = 3'b101; expected_a[13] = 0; expected_b[13] = 0; expected_c[13] = 0; expected_d[13] = 0; expected_e[13] = 0; expected_f[13] = 1; expected_g[13] = 0; expected_h[13] = 0;
    in_in[14] = 1; sel_in[14] = 3'b110; expected_a[14] = 0; expected_b[14] = 0; expected_c[14] = 0; expected_d[14] = 0; expected_e[14] = 0; expected_f[14] = 0; expected_g[14] = 1; expected_h[14] = 0;
    in_in[15] = 1; sel_in[15] = 3'b111; expected_a[15] = 0; expected_b[15] = 0; expected_c[15] = 0; expected_d[15] = 0; expected_e[15] = 0; expected_f[15] = 0; expected_g[15] = 0; expected_h[15] = 1;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      in  = in_in[i];
      sel = sel_in[i];
      #10;
      assert (a == expected_a[i] && b == expected_b[i] &&
              c == expected_c[i] && d == expected_d[i] &&
              e == expected_e[i] && f == expected_f[i] &&
              g == expected_g[i] && h == expected_h[i]) begin
        pass_count++;
        $display("PASS: in=%b sel=%b | a=%b b=%b c=%b d=%b e=%b f=%b g=%b h=%b",
                 in, sel, a, b, c, d, e, f, g, h);
      end else begin
        fail_count++;
        $error("FAIL: in=%b sel=%b | a=%b exp %b, b=%b exp %b, c=%b exp %b, d=%b exp %b, e=%b exp %b, f=%b exp %b, g=%b exp %b, h=%b exp %b",
               in, sel,
               a, expected_a[i], b, expected_b[i],
               c, expected_c[i], d, expected_d[i],
               e, expected_e[i], f, expected_f[i],
               g, expected_g[i], h, expected_h[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

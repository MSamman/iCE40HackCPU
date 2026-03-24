module Mux8way16_tb;
  reg  [15:0] a;
  reg  [15:0] b;
  reg  [15:0] c;
  reg  [15:0] d;
  reg  [15:0] e;
  reg  [15:0] f;
  reg  [15:0] g;
  reg  [15:0] h;
  reg  [2:0]  sel;
  wire [15:0] out;

  Mux8way16 dut(
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .e(e),
    .f(f),
    .g(g),
    .h(h),
    .sel(sel),
    .out(out)
  );

  localparam integer NUM_TESTS = 16;
  reg[15:0] a_in    [0:NUM_TESTS-1];
  reg[15:0] b_in    [0:NUM_TESTS-1];
  reg[15:0] c_in    [0:NUM_TESTS-1];
  reg[15:0] d_in    [0:NUM_TESTS-1];
  reg[15:0] e_in    [0:NUM_TESTS-1];
  reg[15:0] f_in    [0:NUM_TESTS-1];
  reg[15:0] g_in    [0:NUM_TESTS-1];
  reg[15:0] h_in    [0:NUM_TESTS-1];
  reg[2:0]  sel_in  [0:NUM_TESTS-1];
  reg[15:0] expected[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/Mux8way16_tb.vcd");
    $dumpvars(0, Mux8way16_tb);

    a_in[0]  = 16'h0000; b_in[0]  = 16'hFFFF; c_in[0]  = 16'hFFFF; d_in[0]  = 16'hFFFF; e_in[0]  = 16'hFFFF; f_in[0]  = 16'hFFFF; g_in[0]  = 16'hFFFF; h_in[0]  = 16'hFFFF; sel_in[0]  = 3'b000; expected[0]  = 16'h0000;
    a_in[1]  = 16'hFFFF; b_in[1]  = 16'h0000; c_in[1]  = 16'h0000; d_in[1]  = 16'h0000; e_in[1]  = 16'h0000; f_in[1]  = 16'h0000; g_in[1]  = 16'h0000; h_in[1]  = 16'h0000; sel_in[1]  = 3'b000; expected[1]  = 16'hFFFF;
    a_in[2]  = 16'hFFFF; b_in[2]  = 16'h0000; c_in[2]  = 16'hFFFF; d_in[2]  = 16'hFFFF; e_in[2]  = 16'hFFFF; f_in[2]  = 16'hFFFF; g_in[2]  = 16'hFFFF; h_in[2]  = 16'hFFFF; sel_in[2]  = 3'b001; expected[2]  = 16'h0000;
    a_in[3]  = 16'h0000; b_in[3]  = 16'hFFFF; c_in[3]  = 16'h0000; d_in[3]  = 16'h0000; e_in[3]  = 16'h0000; f_in[3]  = 16'h0000; g_in[3]  = 16'h0000; h_in[3]  = 16'h0000; sel_in[3]  = 3'b001; expected[3]  = 16'hFFFF;
    a_in[4]  = 16'hFFFF; b_in[4]  = 16'hFFFF; c_in[4]  = 16'h0000; d_in[4]  = 16'hFFFF; e_in[4]  = 16'hFFFF; f_in[4]  = 16'hFFFF; g_in[4]  = 16'hFFFF; h_in[4]  = 16'hFFFF; sel_in[4]  = 3'b010; expected[4]  = 16'h0000;
    a_in[5]  = 16'h0000; b_in[5]  = 16'h0000; c_in[5]  = 16'hFFFF; d_in[5]  = 16'h0000; e_in[5]  = 16'h0000; f_in[5]  = 16'h0000; g_in[5]  = 16'h0000; h_in[5]  = 16'h0000; sel_in[5]  = 3'b010; expected[5]  = 16'hFFFF;
    a_in[6]  = 16'hFFFF; b_in[6]  = 16'hFFFF; c_in[6]  = 16'hFFFF; d_in[6]  = 16'h0000; e_in[6]  = 16'hFFFF; f_in[6]  = 16'hFFFF; g_in[6]  = 16'hFFFF; h_in[6]  = 16'hFFFF; sel_in[6]  = 3'b011; expected[6]  = 16'h0000;
    a_in[7]  = 16'h0000; b_in[7]  = 16'h0000; c_in[7]  = 16'h0000; d_in[7]  = 16'hFFFF; e_in[7]  = 16'h0000; f_in[7]  = 16'h0000; g_in[7]  = 16'h0000; h_in[7]  = 16'h0000; sel_in[7]  = 3'b011; expected[7]  = 16'hFFFF;
    a_in[8]  = 16'hFFFF; b_in[8]  = 16'hFFFF; c_in[8]  = 16'hFFFF; d_in[8]  = 16'hFFFF; e_in[8]  = 16'h0000; f_in[8]  = 16'hFFFF; g_in[8]  = 16'hFFFF; h_in[8]  = 16'hFFFF; sel_in[8]  = 3'b100; expected[8]  = 16'h0000;
    a_in[9]  = 16'h0000; b_in[9]  = 16'h0000; c_in[9]  = 16'h0000; d_in[9]  = 16'h0000; e_in[9]  = 16'hFFFF; f_in[9]  = 16'h0000; g_in[9]  = 16'h0000; h_in[9]  = 16'h0000; sel_in[9]  = 3'b100; expected[9]  = 16'hFFFF;
    a_in[10] = 16'hFFFF; b_in[10] = 16'hFFFF; c_in[10] = 16'hFFFF; d_in[10] = 16'hFFFF; e_in[10] = 16'hFFFF; f_in[10] = 16'h0000; g_in[10] = 16'hFFFF; h_in[10] = 16'hFFFF; sel_in[10] = 3'b101; expected[10] = 16'h0000;
    a_in[11] = 16'h0000; b_in[11] = 16'h0000; c_in[11] = 16'h0000; d_in[11] = 16'h0000; e_in[11] = 16'h0000; f_in[11] = 16'hFFFF; g_in[11] = 16'h0000; h_in[11] = 16'h0000; sel_in[11] = 3'b101; expected[11] = 16'hFFFF;
    a_in[12] = 16'hFFFF; b_in[12] = 16'hFFFF; c_in[12] = 16'hFFFF; d_in[12] = 16'hFFFF; e_in[12] = 16'hFFFF; f_in[12] = 16'hFFFF; g_in[12] = 16'h0000; h_in[12] = 16'hFFFF; sel_in[12] = 3'b110; expected[12] = 16'h0000;
    a_in[13] = 16'h0000; b_in[13] = 16'h0000; c_in[13] = 16'h0000; d_in[13] = 16'h0000; e_in[13] = 16'h0000; f_in[13] = 16'h0000; g_in[13] = 16'hFFFF; h_in[13] = 16'h0000; sel_in[13] = 3'b110; expected[13] = 16'hFFFF;
    a_in[14] = 16'hFFFF; b_in[14] = 16'hFFFF; c_in[14] = 16'hFFFF; d_in[14] = 16'hFFFF; e_in[14] = 16'hFFFF; f_in[14] = 16'hFFFF; g_in[14] = 16'hFFFF; h_in[14] = 16'h0000; sel_in[14] = 3'b111; expected[14] = 16'h0000;
    a_in[15] = 16'h0000; b_in[15] = 16'h0000; c_in[15] = 16'h0000; d_in[15] = 16'h0000; e_in[15] = 16'h0000; f_in[15] = 16'h0000; g_in[15] = 16'h0000; h_in[15] = 16'hFFFF; sel_in[15] = 3'b111; expected[15] = 16'hFFFF;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      a   = a_in[i];
      b   = b_in[i];
      c   = c_in[i];
      d   = d_in[i];
      e   = e_in[i];
      f   = f_in[i];
      g   = g_in[i];
      h   = h_in[i];
      sel = sel_in[i];
      #10;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: sel=%b | out=%d", sel, out);
      end else begin
        fail_count++;
        $error("FAIL: sel=%b | out=%d, expected %d", sel, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

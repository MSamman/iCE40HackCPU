module ALU_tb;
  reg[0:15] x, y;
  reg zx, nx, zy, ny, f, no;
  wire [0:15] out;
  wire zr ,ng;

  ALU dut(
    .x(x),
    .y(y),
    .zx(zx),
    .nx(nx),
    .zy(zy),
    .ny(ny),
    .f(f),
    .no(no),
    .out(out),
    .zr(zr),
    .ng(ng)
  );

  localparam integer NUM_TESTS = 18;
  reg[15:0] x_in[0:NUM_TESTS-1];
  reg[15:0] y_in[0:NUM_TESTS-1];
  reg zx_in[0:NUM_TESTS-1];
  reg nx_in[0:NUM_TESTS-1];
  reg zy_in[0:NUM_TESTS-1];
  reg ny_in[0:NUM_TESTS-1];
  reg f_in[0:NUM_TESTS-1];
  reg no_in[0:NUM_TESTS-1];
  reg[15:0] expected_out[0:NUM_TESTS-1];
  reg expected_zr[0:NUM_TESTS-1];
  reg expected_ng[0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/ALU_tb.vcd");
    $dumpvars(0, ALU_tb);

    // 0
    zx_in[0] = 1'b1; nx_in[0] = 1'b0; zy_in[0] = 1'b1; ny_in[0] = 1'b0; f_in[0] = 1'b1; no_in[0] = 1'b0; 
    x_in[0] = 16'h1010; y_in[0] = 16'h0101; expected_out[0] = 16'h0000; expected_zr[0] = 1'b1; expected_ng[0] = 1'b0;

    // 1
    zx_in[1] = 1'b1; nx_in[1] = 1'b1; zy_in[1] = 1'b1; ny_in[1] = 1'b1; f_in[1] = 1'b1; no_in[1] = 1'b1; 
    x_in[1] = 16'h1010; y_in[1] = 16'h0101; expected_out[1] = 16'h0001; expected_zr[1] = 1'b0; expected_ng[1] = 1'b0;

    // -1
    zx_in[2] = 1'b1; nx_in[2] = 1'b1; zy_in[2] = 1'b1; ny_in[2] = 1'b0; f_in[2] = 1'b1; no_in[2] = 1'b0; 
    x_in[2] = 16'h1010; y_in[2] = 16'h0101; expected_out[2] = 16'hFFFF; expected_zr[2] = 1'b0; expected_ng[2] = 1'b1;

    // x
    zx_in[3] = 1'b0; nx_in[3] = 1'b0; zy_in[3] = 1'b1; ny_in[3] = 1'b1; f_in[3] = 1'b0; no_in[3] = 1'b0; 
    x_in[3] = 16'h1010; y_in[3] = 16'h0101; expected_out[3] = 16'h1010; expected_zr[3] = 1'b0; expected_ng[3] = 1'b0;

    // y
    zx_in[4] = 1'b1; nx_in[4] = 1'b1; zy_in[4] = 1'b0; ny_in[4] = 1'b0; f_in[4] = 1'b0; no_in[4] = 1'b0; 
    x_in[4] = 16'h1010; y_in[4] = 16'h0101; expected_out[4] = 16'h0101; expected_zr[4] = 1'b0; expected_ng[4] = 1'b0;

    // !x
    zx_in[5] = 1'b0; nx_in[5] = 1'b0; zy_in[5] = 1'b1; ny_in[5] = 1'b1; f_in[5] = 1'b0; no_in[5] = 1'b1; 
    x_in[5] = 16'h1010; y_in[5] = 16'h0101; expected_out[5] = 16'hEFEF; expected_zr[5] = 1'b0; expected_ng[5] = 1'b1;

    // !y
    zx_in[6] = 1'b1; nx_in[6] = 1'b1; zy_in[6] = 1'b0; ny_in[6] = 1'b0; f_in[6] = 1'b0; no_in[6] = 1'b1; 
    x_in[6] = 16'h1010; y_in[6] = 16'h0101; expected_out[6] = 16'hFEFE; expected_zr[6] = 1'b0; expected_ng[6] = 1'b1;

    // -x
    zx_in[7] = 1'b0; nx_in[7] = 1'b0; zy_in[7] = 1'b1; ny_in[7] = 1'b1; f_in[7] = 1'b1; no_in[7] = 1'b1; 
    x_in[7] = 16'h1010; y_in[7] = 16'h0101; expected_out[7] = 16'hEFF0; expected_zr[7] = 1'b0; expected_ng[7] = 1'b1;

    // -y
    zx_in[8] = 1'b1; nx_in[8] = 1'b1; zy_in[8] = 1'b0; ny_in[8] = 1'b0; f_in[8] = 1'b1; no_in[8] = 1'b1;
    x_in[8] = 16'h1010; y_in[8] = 16'h0101; expected_out[8] = 16'hFEFF; expected_zr[8] = 1'b0; expected_ng[8] = 1'b1;

    // x+1
    zx_in[9] = 1'b0; nx_in[9] = 1'b1; zy_in[9] = 1'b1; ny_in[9] = 1'b1; f_in[9] = 1'b1; no_in[9] = 1'b1;
    x_in[9] = 16'h1010; y_in[9] = 16'h0101; expected_out[9] = 16'h1011; expected_zr[9] = 1'b0; expected_ng[9] = 1'b0;

    // y+1
    zx_in[10] = 1'b1; nx_in[10] = 1'b1; zy_in[10] = 1'b0; ny_in[10] = 1'b1; f_in[10] = 1'b1; no_in[10] = 1'b1;
    x_in[10] = 16'h1010; y_in[10] = 16'h0101; expected_out[10] = 16'h0102; expected_zr[10] = 1'b0; expected_ng[10] = 1'b0;

    // x-1
    zx_in[11] = 1'b0; nx_in[11] = 1'b0; zy_in[11] = 1'b1; ny_in[11] = 1'b1; f_in[11] = 1'b1; no_in[11] = 1'b0;
    x_in[11] = 16'h1010; y_in[11] = 16'h0101; expected_out[11] = 16'h100F; expected_zr[11] = 1'b0; expected_ng[11] = 1'b0;

    // y-1
    zx_in[12] = 1'b1; nx_in[12] = 1'b1; zy_in[12] = 1'b0; ny_in[12] = 1'b0; f_in[12] = 1'b1; no_in[12] = 1'b0;
    x_in[12] = 16'h1010; y_in[12] = 16'h0101; expected_out[12] = 16'h0100; expected_zr[12] = 1'b0; expected_ng[12] = 1'b0;

    // x+y
    zx_in[13] = 1'b0; nx_in[13] = 1'b0; zy_in[13] = 1'b0; ny_in[13] = 1'b0; f_in[13] = 1'b1; no_in[13] = 1'b0;
    x_in[13] = 16'h1010; y_in[13] = 16'h0101; expected_out[13] = 16'h1111; expected_zr[13] = 1'b0; expected_ng[13] = 1'b0;

    // x-y
    zx_in[14] = 1'b0; nx_in[14] = 1'b1; zy_in[14] = 1'b0; ny_in[14] = 1'b0; f_in[14] = 1'b1; no_in[14] = 1'b1;
    x_in[14] = 16'h1010; y_in[14] = 16'h0101; expected_out[14] = 16'h0F0F; expected_zr[14] = 1'b0; expected_ng[14] = 1'b0;

    // y-x
    zx_in[15] = 1'b0; nx_in[15] = 1'b0; zy_in[15] = 1'b0; ny_in[15] = 1'b1; f_in[15] = 1'b1; no_in[15] = 1'b1;
    x_in[15] = 16'h1010; y_in[15] = 16'h0101; expected_out[15] = 16'hF0F1; expected_zr[15] = 1'b0; expected_ng[15] = 1'b1;

    // x&y
    zx_in[16] = 1'b0; nx_in[16] = 1'b0; zy_in[16] = 1'b0; ny_in[16] = 1'b0; f_in[16] = 1'b0; no_in[16] = 1'b0;
    x_in[16] = 16'h1010; y_in[16] = 16'h0101; expected_out[16] = 16'h0000; expected_zr[16] = 1'b1; expected_ng[16] = 1'b0;

    // x|y
    zx_in[17] = 1'b0; nx_in[17] = 1'b1; zy_in[17] = 1'b0; ny_in[17] = 1'b1; f_in[17] = 1'b0; no_in[17] = 1'b1;
    x_in[17] = 16'h1010; y_in[17] = 16'h0101; expected_out[17] = 16'h1111; expected_zr[17] = 1'b0; expected_ng[17] = 1'b0;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      x = x_in[i];
      y = y_in[i];
      zx = zx_in[i];
      nx = nx_in[i];
      zy = zy_in[i];
      ny = ny_in[i];
      f = f_in[i];
      no = no_in[i];
      #10;
      assert (out == expected_out[i] &&
              zr == expected_zr[i] &&
              ng == expected_ng[i]) begin
        pass_count++;
        $display("PASS: x=%d y=%d zx=%d nx=%d zy=%d ny=%d f=%d no=%d | out=%d zr=%d ng=%d ", x, y, zx, nx, zy, ny, f, no, out, zr, ng);
      end else begin
        fail_count++;
        $error("FAIL: x=%d y=%d zx=%d nx=%d zy=%d ny=%d f=%d no=%d | out=%d, expected %d zr=%d, expected %d ng=%d, expected %d",  x, y, zx, nx, zy, ny, f, no, out, expected_out[i], zr, expected_zr[i], ng, expected_ng[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

module Adder(
  input   [15:0] a,
  input   [15:0] b,
  output  [15:0] out
);

  // Propogate and generate calculation
  genvar i;
  wire [14:0] p, g;
  generate
    for (i = 0; i < 15; i++) begin
      Or p_or(
        .a(a[i]),
        .b(b[i]),
        .out(p[i])
      );

      And g_and(
        .a(a[i]),
        .b(b[i]),
        .out(g[i])
      );
    end
  endgenerate

  // First level prefix
  wire [7:0] g_1, g_1_temp, p_1;
  And p_1_and_0(p[0], 1'b1, p_1[0]);
  And g_1_temp_and_0(p[0], 1'b0, g_1_temp[0]);
  Or g_1_or_0(g[0], g_1_temp[0], g_1[0]);

  generate
    for (i = 1; i < 8; i++) begin
      And p_1_and(p[i*2], p[i*2-1], p_1[i]);
      And g_1_temp_and(p[i*2], g[i*2-1], g_1_temp[i]);
      Or g_1_or(g[i*2], g_1_temp[i], g_1[i]);
    end
  endgenerate

  // Second level prefix
  wire [7:0] g_2, g_2_temp, p_2;
  generate
    for (i = 0; i < 4; i++) begin
      And p_2_and_0(p[i*4+1], p_1[i*2], p_2[i*2]);
      And g_2_temp_and_0(p[i*4+1], g_1[i*2], g_2_temp[i*2]);
      Or g_2_or_0(g[i*4+1], g_2_temp[i*2], g_2[i*2]);

      And p_2_and_1(p_1[i*2+1], p_1[i*2], p_2[i*2+1]);
      And g_2_temp_and_1(p_1[i*2+1], g_1[i*2], g_2_temp[i*2+1]);
      Or g_2_or_1(g_1[i*2+1], g_2_temp[i*2+1], g_2[i*2+1]);
    end
  endgenerate

  // Third level prefix
  wire [7:0] g_3, g_3_temp, p_3;
  generate
    for (i = 0; i < 2; i++) begin
      And p_3_and_0(p[i*8+3], p_2[i*4+1], p_3[i*4]);
      And g_3_temp_and_0(p[i*8+3], g_2[i*4+1], g_3_temp[i*4]);
      Or g_3_or_0(g[i*8+3], g_3_temp[i*4], g_3[i*4]);

      And p_3_and_1(p_1[i*4+2], p_2[i*4+1], p_3[i*4+1]);
      And g_3_temp_and_1(p_1[i*4+2], g_2[i*4+1], g_3_temp[i*4+1]);
      Or g_3_or_1(g_1[i*4+2], g_3_temp[i*4+1], g_3[i*4+1]);

      And p_3_and_2(p_2[i*4+2], p_2[i*4+1], p_3[i*4+2]);
      And g_3_temp_and_2(p_2[i*4+2], g_2[i*4+1], g_3_temp[i*4+2]);
      Or g_3_or_2(g_2[i*4+2], g_3_temp[i*4+2], g_3[i*4+2]);

      And p_3_and_3(p_2[i*4+3], p_2[i*4+1], p_3[i*4+3]);
      And g_3_temp_and_3(p_2[i*4+3], g_2[i*4+1], g_3_temp[i*4+3]);
      Or g_3_or_3(g_2[i*4+3], g_3_temp[i*4+3], g_3[i*4+3]);
    end
  endgenerate

  // Forth level prefix
  wire [7:0] g_4, g_4_temp, p_4;
  And p_4_and_0(p[7], p_3[3], p_4[0]);
  And g_4_temp_and_0(p[7], g_3[3], g_4_temp[0]);
  Or g_4_or_0(g[7], g_4_temp[0], g_4[0]);

  And p_4_and_1(p_1[4], p_3[3], p_4[1]);
  And g_4_temp_and_1(p_1[4], g_3[3], g_4_temp[1]);
  Or g_4_or_1(g_1[4], g_4_temp[1], g_4[1]);

  And p_4_and_2(p_2[4], p_3[3], p_4[2]);
  And g_4_temp_and_2(p_2[4], g_3[3], g_4_temp[2]);
  Or g_4_or_2(g_2[4], g_4_temp[2], g_4[2]);

  And p_4_and_3(p_2[5], p_3[3], p_4[3]);
  And g_4_temp_and_3(p_2[5], g_3[3], g_4_temp[3]);
  Or g_4_or_3(g_2[5], g_4_temp[3], g_4[3]);

  And p_4_and_4(p_3[4], p_3[3], p_4[4]);
  And g_4_temp_and_4(p_3[4], g_3[3], g_4_temp[4]);
  Or g_4_or_4(g_3[4], g_4_temp[4], g_4[4]);

  And p_4_and_5(p_3[5], p_3[3], p_4[5]);
  And g_4_temp_and_5(p_3[5], g_3[3], g_4_temp[5]);
  Or g_4_or_5(g_3[5], g_4_temp[5], g_4[5]);

  And p_4_and_6(p_3[6], p_3[3], p_4[6]);
  And g_4_temp_and_6(p_3[6], g_3[3], g_4_temp[6]);
  Or g_4_or_6(g_3[6], g_4_temp[6], g_4[6]);

  And p_4_and_7(p_3[7], p_3[3], p_4[7]);
  And g_4_temp_and_7(p_3[7], g_3[3], g_4_temp[7]);
  Or g_4_or_7(g_3[7], g_4_temp[7], g_4[7]);

  // Summation
  wire [15:0] out_temp;
  generate
    for (i = 0; i < 16; i++) begin
      Xor xor_temp(a[i], b[i], out_temp[i]);
    end
  endgenerate

  Xor out_0_xor(out_temp[0], 1'b0, out[0]);
  Xor out_1_xor(out_temp[1], g_1[0], out[1]);
  Xor out_2_xor(out_temp[2], g_2[0], out[2]);
  Xor out_3_xor(out_temp[3], g_2[1], out[3]);
  Xor out_4_xor(out_temp[4], g_3[0], out[4]);
  Xor out_5_xor(out_temp[5], g_3[1], out[5]);
  Xor out_6_xor(out_temp[6], g_3[2], out[6]);
  Xor out_7_xor(out_temp[7], g_3[3], out[7]);
  Xor out_8_xor(out_temp[8], g_4[0], out[8]);
  Xor out_9_xor(out_temp[9], g_4[1], out[9]);
  Xor out_10_xor(out_temp[10], g_4[2], out[10]);
  Xor out_11_xor(out_temp[11], g_4[3], out[11]);
  Xor out_12_xor(out_temp[12], g_4[4], out[12]);
  Xor out_13_xor(out_temp[13], g_4[5], out[13]);
  Xor out_14_xor(out_temp[14], g_4[6], out[14]);
  Xor out_15_xor(out_temp[15], g_4[7], out[15]);
endmodule
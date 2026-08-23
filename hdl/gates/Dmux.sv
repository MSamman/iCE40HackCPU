module Dmux(
  input in,
  input sel,
  output a,
  output b
);
  wire w_b0, w_a0;

  nand(w_b0, in, sel);
  nand(b, w_b0, w_b0);
  nand(w_a0, in, w_b0);
  nand(a, w_a0, w_a0);
endmodule

module Xor(
  input a,
  input b,
  output out
);
  wire w_o1, w_a1, w_b1;
  
  nand(w_o1, a, b);
  nand(w_a1, a, w_o1);
  nand(w_b1, b, w_o1);
  nand(out, w_a1, w_b1);
endmodule

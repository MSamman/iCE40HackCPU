module Mux(
  input a,
  input b,
  input sel,
  output out
);
  wire w_sel_not, w_a1, w_b1;

  nand(w_sel_not, sel, sel);
  nand(w_a1, a, w_sel_not);
  nand(w_b1, b, sel);
  nand(out, w_a1, w_b1);
endmodule

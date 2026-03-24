module Or(
  input a,
  input b,
  output out
);

  wire w_a_not, w_b_not;
  nand(w_a_not, a, a);
  nand(w_b_not, b, b);
  nand(out, w_a_not, w_b_not);
endmodule

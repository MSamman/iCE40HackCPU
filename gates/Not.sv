module Not(
  input in,
  output out
);
  nand(out, in, in);
endmodule

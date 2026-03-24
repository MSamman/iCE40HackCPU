module And(
  input a,
  input b,
  output out
);
  wire temp;
  nand nand1(temp, a, b);
  nand nand2(out, temp, temp);
endmodule
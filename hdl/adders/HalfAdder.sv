module HalfAdder(
  input a,
  input b,
  output carry,
  output sum
);
  Xor c(
    .a(a),
    .b(b),
    .out(sum)
  );
  And s(
    .a(a),
    .b(b),
    .out(carry)
  );
endmodule
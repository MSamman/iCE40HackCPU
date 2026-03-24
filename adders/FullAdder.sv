module FullAdder(
  input a,
  input b,
  input c,
  output carry,
  output sum
);
  wire w_half_sum, w_first_carry, w_second_carry;
  HalfAdder h1(
    .a(a),
    .b(b),
    .carry(w_first_carry),
    .sum(w_half_sum)
  );
  HalfAdder h2(
    .a(w_half_sum),
    .b(c),
    .carry(w_second_carry),
    .sum(sum)
  );
  Or o1(
    .a(w_first_carry),
    .b(w_second_carry),
    .out(carry)
  );
endmodule
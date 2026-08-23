module Mux8way16(
  input  [15:0] a,
  input  [15:0] b,
  input  [15:0] c,
  input  [15:0] d,
  input  [15:0] e,
  input  [15:0] f,
  input  [15:0] g,
  input  [15:0] h,
  input  [2:0]  sel,
  output [15:0] out
);
  wire[15:0] w_left, w_left_middle, w_right_middle, w_right;
  Mux16 left(
    .a(a),
    .b(b),
    .sel(sel[0]),
    .out(w_left)
  );
  Mux16 left_middle(
    .a(c),
    .b(d),
    .sel(sel[0]),
    .out(w_left_middle)
  );
  Mux16 right_middle(
    .a(e),
    .b(f),
    .sel(sel[0]),
    .out(w_right_middle)
  );
  Mux16 right(
    .a(g),
    .b(h),
    .sel(sel[0]),
    .out(w_right)
  );

  Mux4way16 top(
    .a(w_left),
    .b(w_left_middle),
    .c(w_right_middle),
    .d(w_right),
    .sel(sel[2:1]),
    .out(out)
  );
endmodule

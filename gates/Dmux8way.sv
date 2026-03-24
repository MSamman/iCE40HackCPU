module Dmux8way(
  input       in,
  input [2:0] sel,
  output      a,
  output      b,
  output      c,
  output      d,
  output      e,
  output      f,
  output      g,
  output      h
);
  wire w_left, w_left_middle, w_right_middle, w_right;
  Dmux4way split(
    .in(in),
    .sel(sel[1:0]),
    .a(w_left),
    .b(w_left_middle),
    .c(w_right_middle),
    .d(w_right)
  );

  Dmux left(        .in(w_left),          .sel(sel[2]), .a(a), .b(e));
  Dmux left_middle( .in(w_left_middle),   .sel(sel[2]), .a(b), .b(f));
  Dmux right_middle(.in(w_right_middle),  .sel(sel[2]), .a(c), .b(g));
  Dmux right(       .in(w_right),         .sel(sel[2]), .a(d), .b(h));
endmodule

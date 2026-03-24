module Dmux4way(
  input       in,
  input [1:0] sel,
  output      a,
  output      b,
  output      c,
  output      d
);
 wire w_left, w_right;
  Dmux split(
    .in(in),
    .sel(sel[0]),
    .a(w_left),
    .b(w_right)
  );

  Dmux left(  .in(w_left),  .sel(sel[1]), .a(a),  .b(c));
  Dmux right( .in(w_right), .sel(sel[1]), .a(b),  .b(d));
endmodule

module Mux4way16(
  input  [15:0] a,
  input  [15:0] b,
  input  [15:0] c,
  input  [15:0] d,
  input  [1:0]  sel,
  output [15:0] out
);
  wire[15:0] w_left, w_right;
  Mux16 left(
    .a(a),
    .b(b),
    .sel(sel[0]),
    .out(w_left)
  );
  Mux16 right(
    .a(c),
    .b(d),
    .sel(sel[0]),
    .out(w_right)
  );

  Mux16 top(
    .a(w_left),
    .b(w_right),
    .sel(sel[1]),
    .out(out)
  );
endmodule

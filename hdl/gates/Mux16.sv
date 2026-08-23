module Mux16(
  input  [15:0] a,
  input  [15:0] b,
  input         sel,
  output [15:0] out
);
  genvar i;
  generate;
    for (i = 0; i < 16; i++) begin
      Mux n(
        .a(a[i]),
        .b(b[i]),
        .sel(sel),
        .out(out[i])
      );
    end
  endgenerate
endmodule

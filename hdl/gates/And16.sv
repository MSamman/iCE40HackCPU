module And16(
  input  [15:0] a,
  input  [15:0] b,
  output [15:0] out
);
  genvar i;
  generate;
    for (i = 0; i < 16; i++) begin
      And n(
        .a(a[i]),
        .b(b[i]),
        .out(out[i])
      );
    end
  endgenerate
endmodule

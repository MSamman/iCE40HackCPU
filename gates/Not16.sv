module Not16(
  input  [15:0] in,
  output [15:0] out
);
  genvar i;
  generate;
    for (i = 0; i < 16; i++) begin
      Not n(
        .in(in[i]),
        .out(out[i])
      );
    end
  endgenerate
endmodule

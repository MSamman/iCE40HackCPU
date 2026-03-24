module Register16(
  input  logic       clk,
  input  logic[0:15] in,
  input  logic       load,
  output logic[0:15] out
);

  genvar i;
  generate;
    for(i = 0; i < 16; i++) begin
      Register n(
        .clk(clk),
        .in(in[i]),
        .load(load),
        .out(out[i])
      );
    end
  endgenerate
endmodule
module Register16(
  input  logic       clk,
  input  logic[15:0] in,
  input  logic       load,
  output logic[15:0] out
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
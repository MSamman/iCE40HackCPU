module RAM4k(
  input clk,
  input[0:15] in,
  input load,
  input[0:11] address,
  output[0:15] out
);
  reg [0:15] mem [0:4095];

  always_ff @(posedge clk)
    if (load) mem[address] <= in;

  assign out = mem[address];

endmodule
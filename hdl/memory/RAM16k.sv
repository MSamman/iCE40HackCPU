module RAM16k(
  input clk,
  input[0:15] in,
  input load,
  input[0:14] address,
  output[0:15] out
);
  reg [0:15] mem [0:16383];

  always_ff @(posedge clk)
    if (load) mem[address] <= in;

  assign out = mem[address];
endmodule
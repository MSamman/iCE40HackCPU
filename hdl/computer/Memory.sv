// RAM 3072 words - 12 EBRs 
// Going for a 640x480 VGA display and storing 160x120 display data which means we need to scale 4x
module Memory(
  input logic clk,
  input logic[11:0] address,
  input logic[15:0] in,
  input logic load,
  output logic[15:0] out
);
  reg [15:0] mem [0:3071];

  always_ff @(posedge clk) begin
    if (load)
      mem[address] <= in;
  end

  assign out = mem[address];
endmodule
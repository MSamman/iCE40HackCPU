module RAM #(parameter WORDS = 32768) (
  input logic clk,
  input logic[$clog2(WORDS)-1:0] address,
  input logic[15:0] in,
  input logic load,
  output logic[15:0] out
);
  reg [15:0] mem [0:WORDS-1];

  always_ff @(posedge clk) begin
    if (load)
      mem[address] <= in;
  end

  logic [15:0] rdata;
  always_ff @(negedge clk) begin
    rdata <= mem[address];
  end
  assign out = rdata;
endmodule
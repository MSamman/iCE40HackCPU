module SevenSegmentDisplay(
  input clk,
  input load,
  input [3:0] in,

  // Ordered from G through A segments
  output [3:0] out,
  output [6:0] segment
);
  reg [6:0] hexReg;
  reg [3:0] inReg;

  always @(posedge clk) begin
    if(load) begin
      inReg <= in;
      case(in)
        4'b0000: hexReg <= 7'b0111111; // 0
        4'b0001: hexReg <= 7'b0110000; // 1
        4'b0010: hexReg <= 7'b1011011; // 2
        4'b0011: hexReg <= 7'b1001111; // 3
        4'b0100: hexReg <= 7'b1100110; // 4
        4'b0101: hexReg <= 7'b1101101; // 5
        4'b0110: hexReg <= 7'b1111101; // 6
        4'b0111: hexReg <= 7'b0000111; // 7
        4'b1000: hexReg <= 7'b1111111; // 8
        4'b1001: hexReg <= 7'b1100111; // 9
        4'b1010: hexReg <= 7'b1110111; // A
        4'b1011: hexReg <= 7'b1111111; // B
        4'b1100: hexReg <= 7'b0111001; // C
        4'b1101: hexReg <= 7'b0111111; // D
        4'b1110: hexReg <= 7'b1111001; // E
        4'b1111: hexReg <= 7'b1110001; // F
      endcase
    end
  end

  assign segment = ~hexReg;
  assign out = inReg;
endmodule
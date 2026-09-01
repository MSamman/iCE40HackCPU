module LEDArray(
  input       clk,
  input       load,
  input [3:0] in,

  output [3:0] out
);
  reg [3:0] ledsReg;

  always @(posedge clk) begin
    if(load) begin
      ledsReg <= in;
    end
  end

  assign out = ledsReg;
endmodule
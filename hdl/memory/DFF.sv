module DFF(
  input  logic clk,
  input  logic reset,
  input  logic d,
  output logic q
);
  always_ff @(posedge clk or posedge reset) begin
    if(reset) begin
      q <= 1'b0;
    end else begin
      q <= d;
    end
  end
endmodule
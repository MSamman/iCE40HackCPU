module Computer(
  input logic clk,
  input logic reset
);
  wire  logic[15:0] inM;
  wire  logic[15:0] instruction;
  wire  logic[15:0] outM;
  wire  logic       writeM;
  wire  logic[15:0] addressM;
  wire  logic[15:0] pc;

  ROM computerROM(
    .address(pc[9:0]),
    .instruction(instruction)
  );

  CPU computerCPU(
    .clk(clk),
    .inM(inM),
    .instruction(instruction),
    .reset(reset),
    .writeM(writeM),
    .outM(outM),
    .addressM(addressM),
    .pc(pc)
  );
  
  Memory computeRAM(
    .clk(clk),
    .address(addressM[11:0]),
    .in(outM),
    .load(writeM),
    .out(inM)
  );
endmodule

`include "board_map.svh"

module top(
  input logic clk,
  input logic reset
);
  wire  logic[15:0] inM;
  wire  logic[15:0] instruction;
  wire  logic[15:0] outM;
  wire  logic       writeM;
  wire  logic[15:0] addressM;
  wire  logic[15:0] pc;

  ROM #(.WORDS(`ROM_WORDS))computerROM(
    .clk(clk),
    .address(pc[$clog2(`ROM_WORDS)-1:0]),
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
  
  RAM #(.WORDS(`RAM_WORDS))computeRAM(
    .clk(clk),
    .address(addressM[$clog2(`RAM_WORDS)-1:0]),
    .in(outM),
    .load(writeM),
    .out(inM)
  );
endmodule
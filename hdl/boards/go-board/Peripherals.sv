`include "board_map.svh"

module Peripherals #(parameter SELW = `IO_SEL_BITS) (
  input logic       clk,
  input logic[`IO_SEL_BITS-1:0]  address,
  input logic[15:0] in,
  input logic       load,
  output logic[15:0] out,
  output logic[3:0]   ledsOut,
  output logic[6:0]   segment1Out,
  output logic[6:0]   segment2Out
);
  localparam logic [15:0] LED_ADDR = `LED_ADDR; 
  localparam logic [15:0] SEG_ADDR = `SEG_ADDR; 

  localparam logic [SELW-1:0] LED_SEL = LED_ADDR[SELW-1:0];
  localparam logic [SELW-1:0] SEG_SEL = SEG_ADDR[SELW-1:0];

  wire loadLeds     = load && (address == LED_SEL);
  wire loadSegments = load && (address == SEG_SEL);

  wire [7:0] segmentsOut;
  always_comb begin
      case(address)
        LED_SEL: out = {12'b0, ledsOut};
        SEG_SEL: out = {8'b0, segmentsOut};
        default: out = 16'b0;
      endcase
  end

  LEDArray leds(
    .clk(clk),
    .load(loadLeds),
    .in(in[3:0]),
    .out(ledsOut)
  );

  SevenSegmentDisplay segment2(
    .clk(clk),
    .load(loadSegments),
    .in(in[7:4]),
    .out(segmentsOut[7:4]),
    .segment(segment1Out)
  );

    SevenSegmentDisplay segment1(
    .clk(clk),
    .load(loadSegments),
    .in(in[3:0]),
    .out(segmentsOut[3:0]),
    .segment(segment2Out)
  );
endmodule
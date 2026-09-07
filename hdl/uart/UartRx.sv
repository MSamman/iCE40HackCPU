// Settings:
// Baud Rate            115200
// Number of Data Bits  8
// Parity Bit           Off
// Stop Bits            1
// Flow Control         None

// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of clk)/(Frequency of UART)
// Example: 12.5 MHz Clock, 115200 baud UART
// (12500000)/(115200) = 108.507 ~ 109

module UartRx #(parameter CLKS_PER_BIT = 109) (
  input   logic clk,
  input   logic reset,
  input   logic uartRxIn,
  output  logic rxReady,
  output  logic[7:0] rxByte
);
  initial if (CLKS_PER_BIT < 16)
    $fatal(1, "UartRx: CLKS_PER_BIT=%0d too small; need >= 16", CLKS_PER_BIT);

  localparam RESET = 3'b000;
  localparam IDLE = 3'b001;
  localparam START = 3'b010;
  localparam DATA = 3'b011;
  localparam STOP = 3'b100;
  localparam ABORT = 3'b101;

  localparam CLK_COUNTER_BITS = $clog2(CLKS_PER_BIT + 1) - 1;
  localparam IDLE_HOLD_CLKS = 10 * CLKS_PER_BIT;
  localparam IDLE_HOLD_BITS = $clog2(IDLE_HOLD_CLKS + 1);

  reg[2:0]                state = RESET;
  reg[CLK_COUNTER_BITS:0] clkCount;
  reg[IDLE_HOLD_BITS-1:0] stableCount;
  reg[7:0]                rxByteHold;  
  reg[7:0]                rxByteReg;
  reg[2:0]                rxByteIndex;
  reg                     rxReadyReg;

  reg [1:0] rxSyncReg = 2'b11;
  always_ff@(posedge clk) rxSyncReg <= {rxSyncReg[0], uartRxIn};
  wire rxSync = rxSyncReg[1];

  always_ff@(posedge clk) begin
    if (reset) begin
      state <= RESET;
    end else begin
      case(state)
        RESET:
          begin
            clkCount <= 0;
            stableCount <= 0;
            rxByteHold <= 0;
            rxByteReg <= 0;
            rxByteIndex <= 0;
            rxReadyReg <= 0;
            state <= IDLE;
          end

        IDLE:
          begin
            clkCount <= 0;
            rxByteIndex <= 0;
            rxReadyReg <= 0;

            if (!rxSync) begin 
              state <= START;
            end else begin
              state <= IDLE;
            end
          end 
          

        START:
          begin
            if (clkCount == (CLKS_PER_BIT / 2) - 1) begin
              clkCount <= 0;
              state <= !rxSync ? DATA : ABORT;
            end else begin
              clkCount <= clkCount + 1;
              state <= START;
            end
          end

        DATA:
          begin
            if (clkCount == CLKS_PER_BIT - 1) begin
              clkCount <= 0;
              rxByteReg <= {rxSync, rxByteReg[7:1]};
              if (rxByteIndex == 7) begin
                rxByteIndex <= 0;
                state <= STOP;
              end else begin
                rxByteIndex <= rxByteIndex + 1;
                state <= DATA;
              end
            end else begin
              clkCount <= clkCount + 1;
              state <= DATA;
            end
          end

        STOP:
          begin
            if (clkCount == CLKS_PER_BIT - 1) begin
              clkCount <= 0;
              if (rxSync) begin
                rxByteHold <= rxByteReg;
                rxReadyReg <= 1'b1;
                state <= IDLE;
              end else begin
                state <= ABORT;
              end
            end else begin
              clkCount <= clkCount + 1;
              state <= STOP;
            end
          end

        ABORT:
          begin
            if (!rxSync) begin
              stableCount <= 0;
              state <= ABORT;
            end else if (stableCount == IDLE_HOLD_CLKS - 1) begin
              stableCount <= 0;
              state <= IDLE;
            end else begin
              stableCount <= stableCount + 1;
              state <= ABORT;
            end
          end

        default: state <= RESET;
      endcase
    end
  end

  assign rxReady = rxReadyReg;
  assign rxByte = rxByteHold;
endmodule // UartRx

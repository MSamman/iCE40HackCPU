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

module UartTx #(parameter CLKS_PER_BIT = 109) (
  input   logic       clk,
  input   logic       reset,
  input   logic       txStart,
  input   logic[7:0]  txByte,
  output  logic       txBusy,
  output  logic       uartTxOut
);
  initial if (CLKS_PER_BIT < 16)
    $fatal(1, "UartTx: CLKS_PER_BIT=%0d too small; need >= 16", CLKS_PER_BIT);

  localparam RESET = 2'b00;
  localparam IDLE = 2'b01;
  localparam DATA = 2'b11;

  localparam CLK_COUNTER_BITS = $clog2(CLKS_PER_BIT + 1) - 1;

  reg[1:0]                state = RESET;
  reg[CLK_COUNTER_BITS:0] clkCount;
  reg[9:0]                txByteReg;
  reg[3:0]                txByteIndex;
  reg                     txBitReg;

  always_ff@(posedge clk) begin
    if (reset) begin
      state <= RESET;
    end else begin
      case(state)
        RESET:
          begin
            clkCount <= 0;
            txByteReg <= 0;
            txByteIndex <= 0;
            txBitReg <= 1'b1;
            state <= IDLE;
          end

        IDLE:
          begin
            if(txStart) begin
              clkCount <= 0;
              txByteReg <= {1'b1, txByte, 1'b0}; // Pad with stop and start bits.
              txByteIndex <= 0;
              state <= DATA;
            end else begin
              state <= IDLE;
            end
          end 

        DATA:
          begin
            if (clkCount < CLKS_PER_BIT -1) begin
              if (clkCount == 0) begin 
                txBitReg  <= txByteReg[0];
                txByteReg <= {1'b1, txByteReg[9:1]};
              end 
              clkCount <= clkCount + 1;
            end else begin
              clkCount <= 0;
              if (txByteIndex < 9) begin
                txByteIndex <= txByteIndex + 1;
                state <= DATA;
              end else begin
                txByteIndex <= 0;
                state <= IDLE;
              end
            end
          end

        default: state <= RESET;
      endcase
    end
  end

  assign txBusy = (state != IDLE) && (state != RESET);
  assign uartTxOut = txBitReg;
endmodule // UartTx

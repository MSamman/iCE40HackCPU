module UartTx_tb;
  reg         clk, reset, txStart;
  wire        txBusy;
  wire        txOut;

  localparam CLKS_PER_BIT = 16;

  UartTx #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut(
    .clk(clk),
    .reset(reset),
    .txStart(txStart),
    .txByte(8'hAA),
    .txBusy(txBusy),
    .uartTxOut(txOut)
  );

  initial clk = 0;
  always #1 clk = ~clk;

  localparam integer NUM_TESTS = 12;
  reg txBusyExpected   [0:NUM_TESTS-1];
  reg txOutExpected    [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  task tick (integer n = CLKS_PER_BIT);
    repeat (n) @(negedge clk);
  endtask

  initial begin
    $dumpfile("/tmp/UartTx_tb.vcd");
    $dumpvars(0, UartTx_tb);

    txOutExpected[0]  = 1'b0; txBusyExpected[0]  = 1'b1; // Start bit
    txOutExpected[1]  = 1'b0; txBusyExpected[1]  = 1'b1; // Bit 1
    txOutExpected[2]  = 1'b1; txBusyExpected[2]  = 1'b1; // Bit 2
    txOutExpected[3]  = 1'b0; txBusyExpected[3]  = 1'b1; // Bit 3
    txOutExpected[4]  = 1'b1; txBusyExpected[4]  = 1'b1; // Bit 4
    txOutExpected[5]  = 1'b0; txBusyExpected[5]  = 1'b1; // Bit 5
    txOutExpected[6]  = 1'b1; txBusyExpected[6]  = 1'b1; // Bit 6
    txOutExpected[7]  = 1'b0; txBusyExpected[7]  = 1'b1; // Bit 7
    txOutExpected[8]  = 1'b1; txBusyExpected[8]  = 1'b1; // Bit 8
    txOutExpected[9]  = 1'b1; txBusyExpected[9]  = 1'b1; // Stop bit
    txOutExpected[10]  = 1'b1; txBusyExpected[10]  = 1'b0; // Idle
    txOutExpected[11]  = 1'b1; txBusyExpected[11]  = 1'b0; // Idle

    pass_count = 0;
    fail_count = 0;

    txStart = 1'b1;
    tick(CLKS_PER_BIT/2);
    txStart = 1'b0;
    
    for (i = 0; i < NUM_TESTS; i++) begin
      assert (txBusy == txBusyExpected[i] && txOut == txOutExpected[i]) begin
        pass_count++;
        $display("PASS: txBusy=%b txOut=%b | txBusyExpected=%b txOutExpected=%h", txBusy, txOut, txBusyExpected[i],  txOutExpected[i]);
      end else begin
        fail_count++;
        $error("FAIL: txBusy=%b txOut=%b | txBusyExpected=%b txOutExpected=%h", txBusy, txOut, txBusyExpected[i],  txOutExpected[i]);
      end
      tick;
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
    $finish;
  end
endmodule

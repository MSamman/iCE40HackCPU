module UartRx_tb;
  reg         clk;
  reg         reset;
  reg         uartRxInReg;
  wire        rxReady;
  wire[7:0]   rxByte;
  reg         rxReadyPrev = 1'b0;

  localparam CLKS_PER_BIT = 16;

  UartRx #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut(
    .clk(clk),
    .reset(reset),
    .uartRxIn(uartRxInReg),
    .rxReady(rxReady),
    .rxByte(rxByte)
  );

  initial clk = 0;
  always #1 clk = ~clk;

  localparam integer NUM_TESTS = 13;
  reg       uartRxIn          [0:NUM_TESTS-1];
  reg       resetIn           [0:NUM_TESTS-1];
  reg       rxReadyExpected   [0:NUM_TESTS-1];
  reg [7:0] rxByteExpected    [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  task automatic sendbit(input reg b);
    begin
      @(negedge clk);
      uartRxInReg = b;
      repeat (CLKS_PER_BIT - 1) @(negedge clk);
    end
  endtask

  integer expectedStrobes = 1, readyCount = 0, monErrors = 0;
  always @(posedge clk) begin
    if (rxReady) begin
      if (rxReadyPrev) begin
        $error("rxReady high >1 cycle at t=%0t", $time); monErrors = monErrors + 1;
      end
      if (^rxByte === 1'bx) begin
        $error("rxByte is X while rxReady at t=%0t", $time); monErrors = monErrors + 1;
      end
      readyCount   = readyCount + 1;
    end
    rxReadyPrev <= rxReady;
  end

  initial begin
    $dumpfile("/tmp/UartRx_tb.vcd");
    $dumpvars(0, UartRx_tb);

    uartRxIn[0]  = 1'b1; rxByteExpected[0]  = 8'h00; resetIn[0] = 1'b0;
    uartRxIn[1]  = 1'b0; rxByteExpected[1]  = 8'h00; resetIn[1] = 1'b0; // Start bit
    uartRxIn[2]  = 1'b0; rxByteExpected[2]  = 8'h00; resetIn[2] = 1'b0; // Bit 1
    uartRxIn[3]  = 1'b1; rxByteExpected[3]  = 8'h00; resetIn[3] = 1'b0; // Bit 2
    uartRxIn[4]  = 1'b0; rxByteExpected[4]  = 8'h00; resetIn[4] = 1'b0; // Bit 3
    uartRxIn[5]  = 1'b1; rxByteExpected[5]  = 8'h00; resetIn[5] = 1'b0; // Bit 4
    uartRxIn[6]  = 1'b0; rxByteExpected[6]  = 8'h00; resetIn[6] = 1'b0; // Bit 5
    uartRxIn[7]  = 1'b1; rxByteExpected[7]  = 8'h00; resetIn[7] = 1'b0; // Bit 6
    uartRxIn[8]  = 1'b0; rxByteExpected[8]  = 8'h00; resetIn[8] = 1'b0; // Bit 7
    uartRxIn[9]  = 1'b1; rxByteExpected[9]  = 8'h00; resetIn[9] = 1'b0; // Bit 8
    uartRxIn[10]  = 1'b1; rxByteExpected[10]  = 8'hAA; resetIn[10] = 1'b0; // Stop bit
    uartRxIn[11]  = 1'b1; rxByteExpected[11]  = 8'hAA; resetIn[11] = 1'b1;// Reset
    uartRxIn[12]  = 1'b1; rxByteExpected[12]  = 8'h00; resetIn[12] = 1'b0;// Reset

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      reset = resetIn[i];
      sendbit(uartRxIn[i]);
      assert (rxByte == rxByteExpected[i]) begin
        pass_count++;
        $display("PASS: uartRxInReg=%b rxReady = %b rxByte=%h | rxReadyExpected =%b rxByteExpected=%h", uartRxInReg, rxReady, rxByte,  rxReadyExpected[i], rxByteExpected[i]);
      end else begin
        fail_count++;
        $error("FAIL: uartRxInReg=%b rxReady = %b rxByte=%h | rxReadyExpected=%b rxByteExpected=%h", uartRxInReg, rxReady, rxByte, rxReadyExpected[i], rxByteExpected[i]);
      end
    end
    
    assert(readyCount == expectedStrobes) begin
      pass_count++;
      $display("PASS: expected %0d strobes, got %0d", expectedStrobes, readyCount);
    end else begin
      fail_count++;
      $error("FAIL: expected %0d strobes, got %0d", expectedStrobes, readyCount);
    end

    assert(monErrors == 0) begin 
      pass_count++;
      $display("PASS: no mon errors");
    end else begin
      fail_count++;
      $display("FAIL: got %0d monitor errors", monErrors);
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
    $finish;
  end
endmodule

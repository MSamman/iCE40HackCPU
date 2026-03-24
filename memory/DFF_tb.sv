module DFF_tb;
  reg clk, reset, d;
  wire q;

  DFF dut(
    .clk(clk),
    .reset(reset),
    .d(d),
    .q(q)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  localparam integer NUM_TESTS = 4;
  reg reset_in [0:NUM_TESTS-1];
  reg d_in     [0:NUM_TESTS-1];
  reg expected [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  task tick;
    @(posedge clk);
    #1;
  endtask

  initial begin
    $dumpfile("/tmp/DFF_tb.vcd");
    $dumpvars(0, DFF_tb);

    // reset overrides d
    reset_in[0] = 1; d_in[0] = 0; expected[0] = 0;
    reset_in[1] = 1; d_in[1] = 1; expected[1] = 0;
    // normal capture
    reset_in[2] = 0; d_in[2] = 0; expected[2] = 0;
    reset_in[3] = 0; d_in[3] = 1; expected[3] = 1;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      reset = reset_in[i];
      d = d_in[i];
      tick;
      assert (q == expected[i]) begin
        pass_count++;
        $display("PASS: reset=%b d=%b | q=%b", reset, d, q);
      end else begin
        fail_count++;
        $error("FAIL: reset=%b d=%b | q=%b, expected %b", reset, d, q, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
    $finish;
  end

endmodule

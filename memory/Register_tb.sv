module Register_tb;
  reg clk, in, load;
  wire out;

  Register dut(
    .clk(clk),
    .in(in),
    .load(load),
    .out(out)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  localparam integer NUM_TESTS = 5;
  reg in_in [0:NUM_TESTS-1];
  reg load_in     [0:NUM_TESTS-1];
  reg expected [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  task tick;
    @(posedge clk);
    #1;
  endtask

  initial begin
    $dumpfile("/tmp/Register_tb.vcd");
    $dumpvars(0, Register_tb);

    // "Reset"
    in = 0;
    load = 1;
    tick;

    // reset overrides d
    in_in[0] = 1; load_in[0] = 0; expected[0] = 0;
    in_in[1] = 1; load_in[1] = 1; expected[1] = 1;
    in_in[2] = 0; load_in[2] = 0; expected[2] = 1;
    in_in[3] = 0; load_in[3] = 1; expected[3] = 0;
    in_in[4] = 1; load_in[4] = 0; expected[4] = 0;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      in = in_in[i];
      load = load_in[i];
      tick;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: in=%b load=%b | out=%b", in, load, out);
      end else begin
        fail_count++;
        $error("FAIL: in=%b load=%b | out=%b, expected %b", in, load, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
    $finish;
  end
endmodule
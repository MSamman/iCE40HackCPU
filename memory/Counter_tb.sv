module Counter_tb;
  reg         clk;
  reg [0:15]  in;
  reg         load;
  reg         inc;
  reg         reset;
  wire [0:15] out;

  Counter dut(
    .clk(clk),
    .in(in),
    .load(load),
    .inc(inc),
    .reset(reset),
    .out(out)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  localparam integer NUM_TESTS = 7;
  reg [0:15] in_in    [0:NUM_TESTS-1];
  reg        load_in  [0:NUM_TESTS-1];
  reg        inc_in   [0:NUM_TESTS-1];
  reg        reset_in [0:NUM_TESTS-1];
  reg [0:15] expected [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  task tick;
    @(posedge clk);
    #1;
  endtask

  initial begin
    $dumpfile("/tmp/Counter_tb.vcd");
    $dumpvars(0, Counter_tb);

    in_in[0] = 16'h0000; load_in[0] = 1'b0; inc_in[0] = 1'b0; reset_in[0] = 1'b1; expected[0] = 16'h0000;
    in_in[1] = 16'h0000; load_in[1] = 1'b0; inc_in[1] = 1'b1; reset_in[1] = 1'b0; expected[1] = 16'h0001;
    in_in[2] = 16'h0000; load_in[2] = 1'b0; inc_in[2] = 1'b1; reset_in[2] = 1'b0; expected[2] = 16'h0002;
    in_in[3] = 16'hFF00; load_in[3] = 1'b1; inc_in[3] = 1'b0; reset_in[3] = 1'b0; expected[3] = 16'hFF00;
    in_in[4] = 16'hFF00; load_in[4] = 1'b0; inc_in[4] = 1'b1; reset_in[4] = 1'b0; expected[4] = 16'hFF01;
    in_in[5] = 16'hFF00; load_in[5] = 1'b0; inc_in[5] = 1'b1; reset_in[5] = 1'b0; expected[5] = 16'hFF02;
    in_in[6] = 16'hFF00; load_in[6] = 1'b0; inc_in[6] = 1'b0; reset_in[6] = 1'b1; expected[6] = 16'h0000;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      in    = in_in[i];
      load  = load_in[i];
      inc   = inc_in[i];
      reset = reset_in[i];
      tick;
      assert (out == expected[i]) begin
        pass_count++;
        $display("PASS: in=%h load=%b inc=%b reset=%b | out=%h", in, load, inc, reset, out);
      end else begin
        fail_count++;
        $error("FAIL: in=%h load=%b inc=%b reset=%b | out=%h, expected %h", in, load, inc, reset, out, expected[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
    $finish;
  end

endmodule

module FullAdder_tb;
  reg a, b, c;
  wire carry, sum;

  FullAdder dut(
    .a(a),
    .b(b),
    .c(c),
    .carry(carry),
    .sum(sum)
  );

  localparam integer NUM_TESTS = 8;
  reg a_in          [0:NUM_TESTS-1];
  reg b_in          [0:NUM_TESTS-1];
  reg c_in          [0:NUM_TESTS-1];
  reg expected_carry[0:NUM_TESTS-1];
  reg expected_sum  [0:NUM_TESTS-1];

  integer pass_count, fail_count;
  integer i;

  initial begin
    $dumpfile("/tmp/FullAdder_tb.vcd");
    $dumpvars(0, FullAdder_tb);

    a_in[0] = 0; b_in[0] = 0; c_in[0] = 0; expected_carry[0] = 0; expected_sum[0] = 0;
    a_in[1] = 0; b_in[1] = 1; c_in[1] = 0; expected_carry[1] = 0; expected_sum[1] = 1;
    a_in[2] = 1; b_in[2] = 0; c_in[2] = 0; expected_carry[2] = 0; expected_sum[2] = 1;
    a_in[3] = 1; b_in[3] = 1; c_in[3] = 0; expected_carry[3] = 1; expected_sum[3] = 0;
    a_in[4] = 0; b_in[4] = 0; c_in[4] = 1; expected_carry[4] = 0; expected_sum[4] = 1;
    a_in[5] = 0; b_in[5] = 1; c_in[5] = 1; expected_carry[5] = 1; expected_sum[5] = 0;
    a_in[6] = 1; b_in[6] = 0; c_in[6] = 1; expected_carry[6] = 1; expected_sum[6] = 0;
    a_in[7] = 1; b_in[7] = 1; c_in[7] = 1; expected_carry[7] = 1; expected_sum[7] = 1;

    pass_count = 0;
    fail_count = 0;

    for (i = 0; i < NUM_TESTS; i++) begin
      a = a_in[i];
      b = b_in[i];
      c = c_in[i];
      #10;
      assert (carry == expected_carry[i] && sum == expected_sum[i]) begin
        pass_count++;
        $display("PASS: a=%b b=%b c=%b | carry=%b sum=%b", a, b, c, carry, sum);
      end else begin
        fail_count++;
        $error("FAIL: a=%b b=%b c=%b | carry=%b, expected %b sum=%b, expected %b",
               a, b, c, carry, expected_carry[i], sum, expected_sum[i]);
      end
    end

    $display("Results: %0d/%0d passed", pass_count, pass_count + fail_count);
    if (fail_count > 0) $fatal(1, "Test suite FAILED");
  end

endmodule

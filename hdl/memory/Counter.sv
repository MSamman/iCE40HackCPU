module Counter(
  input  logic        clk,
  input  logic[0:15]  in,
  input  logic        load,
  input  logic        inc,
  input  logic        reset,
  output logic[0:15]  out
);
  wire[0:15] w_reg_out, w_inc_out, w_inc_mux_out, w_load_mux_out, w_next;

  // check inc
  Incrementer inc_out(
    .in(w_reg_out),
    .out(w_inc_out)
  );
  Mux16 inc_mux(
    .a(w_reg_out),
    .b(w_inc_out),
    .sel(inc),
    .out(w_inc_mux_out)
  );

  // check load
  Mux16 load_mux(
    .a(w_inc_mux_out),
    .b(in),
    .sel(load),
    .out(w_load_mux_out)
  );

  // check reset
  Mux16 reset_mux(
    .a(w_load_mux_out),
    .b(16'h0000),
    .sel(reset),
    .out(w_next)
  );

  // store next value, expose current stored value as output
  Register16 reg_out(
    .clk(clk),
    .in(w_next),
    .load(1'b1),
    .out(w_reg_out)
  );

  assign out = w_reg_out;
endmodule
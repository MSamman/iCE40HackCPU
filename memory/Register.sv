module Register(
  input logic clk,
  input logic in,
  input logic load,
  output logic out
);
  wire w_mux_out, w_dff_out;

  Mux reg_mux(
    .a(w_dff_out),
    .b(in),
    .sel(load),
    .out(w_mux_out)
  );

  DFF reg_dff(
    .clk(clk),
    .reset(1'b0),
    .d(w_mux_out),
    .q(w_dff_out)
  );

  assign out = w_dff_out;
endmodule
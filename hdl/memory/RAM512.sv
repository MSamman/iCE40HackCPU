module RAM512(
  input clk,
  input[0:15] in,
  input load,
  input[0:8] address,
  output[0:15] out
);
  wire[0:7] loads;
  Dmux8way loads_dmux(
    .in(load),
    .sel(address[0:2]),
    .a(loads[0]),
    .b(loads[1]),
    .c(loads[2]),
    .d(loads[3]),
    .e(loads[4]),
    .f(loads[5]),
    .g(loads[6]),
    .h(loads[7])
  );

  wire[0:15] outputs[0:7];
  Mux8way16 outputs_mux(
    .sel(address[0:2]),
    .a(outputs[0]),
    .b(outputs[1]),
    .c(outputs[2]),
    .d(outputs[3]),
    .e(outputs[4]),
    .f(outputs[5]),
    .g(outputs[6]),
    .h(outputs[7]),
    .out(out)
  );

  genvar i;
  generate
    for(i = 0; i < 8; i++) begin
      RAM64 n(
        .clk(clk),
        .in(in),
        .address(address[3:8]),
        .load(loads[i]),
        .out(outputs[i])
      );
    end
  endgenerate
endmodule
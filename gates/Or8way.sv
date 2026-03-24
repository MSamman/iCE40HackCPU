module Or8way(
  input  [7:0] in,
  output      out
);
  wire w_first[3:0];
  wire w_second[1:0];

  genvar i;
  generate
    for (i = 0; i < 4; i++) begin
      Or first(
        .a(in[i*2+1]),
        .b(in[i*2]),
        .out(w_first[i])
      );
    end
  endgenerate

  generate
    for (i = 0; i < 2; i++) begin
      Or second(
        .a(w_first[i*2+1]),
        .b(w_first[i*2]),
        .out(w_second[i])
      );
    end
  endgenerate

  Or last(
    .a(w_second[1]),
    .b(w_second[0]),
    .out(out)
  );
endmodule

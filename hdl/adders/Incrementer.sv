module Incrementer(
  input   [15:0] in,
  output  [15:0] out
);
  wire [14:0] w_carries;
  HalfAdder first(
    .a(in[0]),
    .b(1'b1),
    .carry(w_carries[0]),
    .sum(out[0])
  );

  genvar i;
  generate
    for (i = 1; i < 15; i++) begin
      HalfAdder n(
        .a(in[i]),
        .b(w_carries[i-1]),
        .carry(w_carries[i]),
        .sum(out[i])
      );
    end
  endgenerate

  HalfAdder last(
    .a(in[15]),
    .b(w_carries[14]),
    .carry(),
    .sum(out[15])
  );
endmodule
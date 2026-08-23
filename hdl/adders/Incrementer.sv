module Incrementer(
  input   [0:15] in,
  output  [0:15] out
);
  wire [0:15] w_carries;
  HalfAdder first(
    .a(in[15]),
    .b(1'b1),
    .carry(w_carries[15]),
    .sum(out[15])
  );

  genvar i;
  generate
    for (i = 14; i > 0; i--) begin
      HalfAdder n(
        .a(in[i]),
        .b(w_carries[i+1]),
        .carry(w_carries[i]),
        .sum(out[i])
      );
    end
  endgenerate

  HalfAdder last(
    .a(in[0]),
    .b(w_carries[1]),
    .carry(),
    .sum(out[0])
  );
endmodule
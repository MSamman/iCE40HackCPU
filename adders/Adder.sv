module Adder(
  input   [0:15] a,
  input   [0:15] b,
  output  [0:15] out
);
  wire [0:15] w_carries;
  FullAdder first(
    .a(a[15]),
    .b(b[15]),
    .c(1'b0),
    .carry(w_carries[14]),
    .sum(out[15])
  );

  genvar i;
  generate
    for (i = 14; i > 0; i--) begin
      FullAdder n(
        .a(a[i]),
        .b(b[i]),
        .c(w_carries[i]),
        .carry(w_carries[i-1]),
        .sum(out[i])
      );
    end
  endgenerate

  FullAdder last(
    .a(a[0]),
    .b(b[0]),
    .c(w_carries[0]),
    .carry(),
    .sum(out[0])
  );
endmodule
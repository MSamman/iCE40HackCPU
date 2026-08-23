module ALU(
  input [0:15] x,
  input [0:15] y,
  input zx,
  input nx,
  input zy,
  input ny,
  input f,
  input no,
  output [0:15] out,
  output zr,
  output ng
);

  // zx control bit
  wire[0:15] w_zx;
  Mux16 zx_out(
    .a(x),
    .b(16'h0000),
    .sel(zx),
    .out(w_zx)
  );

  // nx control bit
  wire[0:15] w_nx, w_nx_val;
  Not16 nx_val_out(
    .in(w_zx),
    .out(w_nx_val)
  );
  Mux16 nx_out(
    .a(w_zx),
    .b(w_nx_val),
    .sel(nx),
    .out(w_nx)
  );

  // zy control bit
  wire[0:15] w_zy;
  Mux16 zy_out(
    .a(y),
    .b(16'h0000),
    .sel(zy),
    .out(w_zy)
  );

  // ny control bit
  wire[0:15] w_ny, w_ny_val;
  Not16 ny_val_out(
    .in(w_zy),
    .out(w_ny_val)
  );
  Mux16 ny_out(
    .a(w_zy),
    .b(w_ny_val),
    .sel(ny),
    .out(w_ny)
  );

  // f control bit
  wire [0:15] w_f, w_f_and, w_f_add;
  And16 f_and_out(
    .a(w_nx),
    .b(w_ny),
    .out(w_f_and)
  );
  Adder f_add_out(
    .a(w_nx),
    .b(w_ny),
    .out(w_f_add)
  );
  Mux16 f_out(
    .a(w_f_and),
    .b(w_f_add),
    .sel(f),
    .out(w_f)
  );

  // no control bit
  wire[0:15] w_no;
  Not16 no_not_out(
    .in(w_f),
    .out(w_no)
  );
  Mux16 no_out(
    .a(w_f),
    .b(w_no),
    .sel(no),
    .out(out)
  );

  // calculate zr
  wire w_zr_lh, w_zr_rh, w_zr;
  Or8way zr_lh(
    .in(out[0:7]),
    .out(w_zr_lh)
  );
  Or8way zr_rh(
    .in(out[8:15]),
    .out(w_zr_rh)
  );
  Or zr_or(
    .a(w_zr_lh),
    .b(w_zr_rh),
    .out(w_zr)
  );
  Not zr_out(
    .in(w_zr),
    .out(zr)
  );

  // calculate ng
  assign ng = out[0];
endmodule
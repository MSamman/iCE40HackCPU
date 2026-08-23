module CPU(
  input   logic       clk,
  input   logic[15:0] inM,
  input   logic[15:0] instruction,
  input   logic       reset,
  output  logic[15:0] outM,
  output  logic       writeM,
  output  logic[15:0] addressM,
  output  logic[15:0] pc
);
  wire isC = instruction[15];

  // C instruction decoding
  wire aOrM = instruction[12];
  wire[5:0] comp = instruction[11:6];
  
  wire[2:0] dest = instruction[5:3];
  wire cLoadA = dest[2];
  wire cLoadD = dest[1];
  wire cLoadM = dest[0];

  wire[2:0] jump = instruction[2:0];

  wire[15:0] regAOut;
  Mux16 addressMux(
    .a(instruction),
    .b(aluOut),
    .sel(isC),
    .out(regAOut)
  );

  // If A instruction OR C instruction with appropriate d bit set
  wire isA;
  Not notA(
    .in(isC),
    .out(isA)
  );

  wire loadA;
  Or aOrCLoadA(
    .a(isA),
    .b(cLoadA),
    .out(loadA)
  );

  Register16 regA(
    .clk(clk),
    .in(regAOut),
    .load(loadA),
    .out(addressM)
  );

  wire loadD;
  And cAndCLoadD(
    .a(isC),
    .b(cLoadD),
    .out(loadD)
  );

  wire[15:0] regDOut;
  Register16 regD(
    .clk(clk),
    .in(aluOut),
    .load(loadD),
    .out(regDOut)
  );

  wire[15:0] aOrMOut;
  Mux16 aOrIn(
    .a(addressM),
    .b(inM),
    .sel(aOrM),
    .out(aOrMOut)
  );

  wire aluZr, aluNg;
  wire [15:0] aluOut;
  ALU alu(
    .x(regDOut),
    .y(aOrMOut),
    .zx(comp[5]),
    .nx(comp[4]),
    .zy(comp[3]),
    .ny(comp[2]),
    .f(comp[1]),
    .no(comp[0]),
    .out(aluOut),
    .zr(aluZr),
    .ng(aluNg)
  );

  wire aluNgZrOr;
  Or gtOr(
    .a(aluNg),
    .b(aluZr),
    .out(aluNgZrOr)
  );

  wire aluNgZrNor;
  Not gtNor(
    .in(aluNgZrOr),
    .out(aluNgZrNor)
  );

  wire ltJump, gtJump;
  And j2AndNg(
    .a(jump[2]),
    .b(aluNg),
    .out(ltJump)
  );
  And j0AnNotNg(
    .a(jump[0]),
    .b(aluNgZrNor),
    .out(gtJump)
  );

  wire ngOrOut;
  Or ngOr(
    .a(ltJump),
    .b(gtJump),
    .out(ngOrOut)
  );

  wire eqJump;
  And j1AndZr(
    .a(jump[1]),
    .b(aluZr),
    .out(eqJump)
  );

  wire shouldJump;
  Or zrOrNg(
    .a(ngOrOut),
    .b(eqJump),
    .out(shouldJump)
  );

  wire pcLoad;
  And isCshouldLoad(
    .a(isC),
    .b(shouldJump),
    .out(pcLoad)
  );

  Counter programCounter(
    .clk(clk),
    .in(addressM),
    .load(pcLoad),
    .inc(1'b1),
    .reset(reset),
    .out(pc)
  );

  assign outM = aluOut;

  And cAndCLoadM(
    .a(isC),
    .b(cLoadM),
    .out(writeM)
  );
endmodule;
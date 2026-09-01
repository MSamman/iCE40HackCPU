// Selectable program at build time
`ifndef PROGRAM_BIN
  `define PROGRAM_BIN "program.bin"
`endif

module ROM #(parameter WORDS = 32768)(
  input   logic                     clk,
  input   logic[$clog2(WORDS)-1:0]  address,
  output  logic[15:0]               instruction
  );
  reg [15:0] mem [0:WORDS-1];
  initial begin
    $readmemb(`PROGRAM_BIN, mem);
  end

  logic [15:0] rdata;
  always_ff @(negedge clk) begin
    rdata <= mem[address];
  end
  assign instruction = rdata;
endmodule
// Selectable program at build time
`ifndef PROGRAM_HEX
  `define PROGRAM_HEX "program.hex"
`endif

// ROM will be 1024 words = 4 EBRs
// Going for a 640x480 VGA display and storing 160x120 display data which means we need to scale 4x
module ROM(
  input logic[9:0] address,
  output logic[15:0] instruction
  );
  reg [15:0] mem [0:1023];
  initial begin
    $readmemh(`PROGRAM_HEX, mem);
  end
  assign instruction = mem[address];
endmodule
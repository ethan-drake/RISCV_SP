// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            22/09/24
// File:			     risc_v_decoder.v
// Module name:	  risc_v_decoder
// Project Name:	  risc_v_sp
// Description:	  risc_v_decoder

module risc_v_decoder(
    input [31:0] instr,
    output [4:0] rs1,
    output [4:0] rs2,
    output [4:0] rd,
    output [6:0] opcode,
    output [2:0] func3,
    output [6:0] func7
);

assign opcode = instr[6:0];
assign rd = instr[11:7];
assign func3 = instr[14:12];
assign rs1 = instr[19:15];
assign rs2 = instr[24:20];
assign func7 = instr[31:25];

endmodule
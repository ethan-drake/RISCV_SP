// Coder:           David Adrian Michel Torres, Eduardo Ethandrake Castillo Pulido
// Date:            16/03/23
// File:			     imm_gen.v
// Module name:	  imm_gen
// Project Name:	  risc_v_top
// Description:	  Risc_V immediate generator


module imm_gen (
	//inputs
	input [31:0] i_instruction,
	//outputs
	output reg [31:0] o_immediate
);

parameter I_TYPE = 7'b0010011;
parameter S_TYPE = 7'b0100011;
parameter B_TYPE = 7'b1100011;
parameter LUI_INS = 7'b0110111;
parameter AUIPC_INS = 7'b0010111;
parameter JAL_INS = 7'b1101111;
parameter JALR_INS = 7'b1100111;
parameter LOAD_INS = 7'b0000011;

always @(i_instruction) begin
	//switch case from instruction opcode
	case(i_instruction[6:0])
		I_TYPE,
		JALR_INS,
		LOAD_INS:
			begin
				o_immediate = {{20{i_instruction[31]}},i_instruction[31:20]};
			end
		S_TYPE:
			begin
				o_immediate = {{20{i_instruction[31]}},i_instruction[31:25],i_instruction[11:7]};
			end
		B_TYPE:
			begin
				o_immediate = {{20{i_instruction[31]}},i_instruction[7],i_instruction[30:25],i_instruction[11:8],1'b0};
			end
		JAL_INS:
			begin
				o_immediate = {{12{i_instruction[31]}},i_instruction[19:12],i_instruction[20],i_instruction[30:21],1'b0};
			end
		LUI_INS,
		AUIPC_INS:
			begin
				o_immediate = {i_instruction[31:12],12'h0};
			end

	default: o_immediate = 32'h0;
	endcase

end

endmodule
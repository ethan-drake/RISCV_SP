// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            09/24/24
// File:			     reg_file_rob.v
// Module name:	  reg_file_rob
// Project Name:	  risc_v_top
// Description:	  Register file that contains registers data
//64 entries
`include "utils.sv"
module reg_file_rob (
	input clk,
	input i_rst_n,
	//Write ports
	input wen_rf,
	//input [31:0] write_data_rf,
	input rob_rf_data write_data_rf,
	input [5:0] write_addr_rf,

	//Read ports
	input [5:0] rs1addr_rf,
	//output [31:0] rs1data_rf,
	output rob_rf_data rs1data_rf,

	input [5:0] rs2addr_rf,
	//output [31:0] rs2data_rf
	output rob_rf_data rs2data_rf,

	//update ports
	input cdb_bfm issue_cdb
);

//Declare our memory
rob_rf_data registers [0:63];

//Syncronus write to registers (New and update writes)
always @(posedge clk, negedge i_rst_n) begin
	if(i_rst_n)begin
		if(wen_rf)begin
			registers[write_addr_rf] <= write_data_rf;
		end
		if(issue_cdb.cdb_valid)begin
			registers[issue_cdb.cdb_tag].spec_data <= issue_cdb.cdb_result;
			registers[issue_cdb.cdb_tag].branch_taken <= issue_cdb.cdb_branch_taken;
			registers[issue_cdb.cdb_tag].spec_valid <= 1'b1;
		end
	end
end

//Initialize registers
initial begin
	registers[0] <= 32'h0;
	registers[1] <= 32'h0;
	registers[2] <= 32'h0;
	registers[3] <= 32'h0;
	registers[4] <= 32'h0;
	registers[5] <= 32'h0;
	registers[6] <= 32'h0;
	registers[7] <= 32'h0;
	registers[8] <= 32'h0;
	registers[9] <= 32'h0;
	registers[10] <= 32'h0;
	registers[11] <= 32'h0;
	registers[12] <= 32'h0;
	registers[13] <= 32'h0;
	registers[14] <= 32'h0;
	registers[15] <= 32'h0;
	registers[16] <= 32'h0;
	registers[17] <= 32'h0;
	registers[18] <= 32'h0;
	registers[19] <= 32'h0;
	registers[20] <= 32'h0;
	registers[21] <= 32'h0;
	registers[22] <= 32'h0;
	registers[23] <= 32'h0;
	registers[24] <= 32'h0;
	registers[25] <= 32'h0;
	registers[26] <= 32'h0;
	registers[27] <= 32'h0;
	registers[28] <= 32'h0;
	registers[29] <= 32'h0;
	registers[30] <= 32'h0;
	registers[31] <= 32'h0;
	registers[32] <= 32'h0;
	registers[33] <= 32'h0;
	registers[34] <= 32'h0;
	registers[35] <= 32'h0;
	registers[36] <= 32'h0;
	registers[37] <= 32'h0;
	registers[38] <= 32'h0;
	registers[39] <= 32'h0;
	registers[40] <= 32'h0;
	registers[41] <= 32'h0;
	registers[42] <= 32'h0;
	registers[43] <= 32'h0;
	registers[44] <= 32'h0;
	registers[45] <= 32'h0;
	registers[46] <= 32'h0;
	registers[47] <= 32'h0;
	registers[48] <= 32'h0;
	registers[49] <= 32'h0;
	registers[50] <= 32'h0;
	registers[51] <= 32'h0;
	registers[52] <= 32'h0;
	registers[53] <= 32'h0;
	registers[54] <= 32'h0;
	registers[55] <= 32'h0;
	registers[56] <= 32'h0;
	registers[57] <= 32'h0;
	registers[58] <= 32'h0;
	registers[59] <= 32'h0;
	registers[60] <= 32'h0;
	registers[61] <= 32'h0;
	registers[62] <= 32'h0;
	registers[63] <= 32'h0;
end

//Asyncronus read to registers
assign rs1data_rf = registers[rs1addr_rf];
assign rs2data_rf = registers[rs2addr_rf];

endmodule
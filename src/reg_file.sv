// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            09/24/24
// File:			     reg_file.v
// Module name:	  reg_file
// Project Name:	  risc_v_top
// Description:	  Register file that contains registers data

module reg_file (
	input clk,
	//Write ports
	input wen_rf,
	input [31:0] write_data_rf,
	input [4:0] write_addr_rf,

	//Read ports
	input [4:0] rs1addr_rf,
	output [31:0] rs1data_rf,

	input [4:0] rs2addr_rf,
	output [31:0] rs2data_rf
);

//Declare our memory
reg [31:0] registers [0:31];

//Syncronus write to registers
always @(posedge clk) begin
	if(wen_rf == 1'b1 && write_addr_rf!=5'h0) begin
		registers[write_addr_rf] <= write_data_rf;
	end
end

//Initialize registers
initial begin
	registers[0] <= 32'h0;
	registers[1] <= 32'h0;
	registers[2] <= 32'h7fffefe4;
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
end

//Asyncronus read to registers
assign rs1data_rf = registers[rs1addr_rf];
assign rs2data_rf = registers[rs2addr_rf];

endmodule
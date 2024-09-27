// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     rst.v
// Module name:	  register status table
// Project Name:	  risc_v_sp
// Description:	  register status table

module rst(
	input clk, 
    //write port 0
    input [6:0] wdata0_rst,
    input [4:0] waddr0_rst,
    input wen0_rst,
    //write port 1
    input [6:0] wdata1_rst,
    input [31:0] wen1_rst,//////////////

    //read ports
    input[4:0] rs1addr_rst,
    output [5:0] rs1tag_rst,
    output rs1valid_rst,
    
    input [4:0] rs2addr_rst,
    output [5:0] rs2tag_rst,
    output rs2valid_rst,

    input cdb_valid,
    input [5:0] cdb_tag_rst,
    output [31:0] wen_regfile_rst ////////

);

wire [31:0] wen_rf_rst_priority;
wire [31:0] wen1_rst_priority;
//que onda con el monton de ands para estas dos entradas, no le entendi

//Declare our memory
reg [6:0] registers [0:31];

//Syncronus write to registers
always @(posedge clk) begin
	if(wen0_rst) begin
		registers[waddr0_rst] <= wdata0_rst;
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
end

//Asyncronus read to registers
assign rs1tag_rst = registers[rs1addr_rst][5:0];
assign rs1valid_rst = registers[rs1addr_rst][6];

assign rs2tag_rst = registers[rs2addr_rst][5:0];
assign rs2valid_rst = registers[rs1addr_rst][6];

endmodule
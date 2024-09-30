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
    output reg [4:0] wen_regfile_rst 

);


//Declare our memory
reg [6:0] registers [0:31];
reg [4:0] cdb_clear_addr;

//Syncronus write to registers
always @(posedge clk) begin
	if(wen0_rst) begin
		registers[waddr0_rst] <= wdata0_rst;
	end
	registers[cdb_clear_addr] <= 7'h0;
end

//Initialize registers
initial begin
	registers[0] <= 7'h0;
	registers[1] <= 7'h0;
	registers[2] <= 7'h0;
	registers[3] <= 7'h0;
	registers[4] <= 7'h0;
	registers[5] <= 7'h0;
	registers[6] <= 7'h0;
	registers[7] <= 7'h0;
	registers[8] <= 7'h0;
	registers[9] <= 7'h0;
	registers[10] <= 7'h0;
	registers[11] <= 7'h0;
	registers[12] <= 7'h0;
	registers[13] <= 7'h0;
	registers[14] <= 7'h0;
	registers[15] <= 7'h0;
	registers[16] <= 7'h0;
	registers[17] <= 7'h0;
	registers[18] <= 7'h0;
	registers[19] <= 7'h0;
	registers[20] <= 7'h0;
	registers[21] <= 7'h0;
	registers[22] <= 7'h0;
	registers[23] <= 7'h0;
	registers[24] <= 7'h0;
	registers[25] <= 7'h0;
	registers[26] <= 7'h0;
	registers[27] <= 7'h0;
	registers[28] <= 7'h0;
	registers[29] <= 7'h0;
	registers[30] <= 7'h0;
	registers[31] <= 7'h0;
end

//obtener el id limpiado
always @(*) begin
	if(cdb_valid)begin
		if((registers[0]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd0;
			if(!((waddr0_rst == 5'd0) && wen0_rst))begin
				cdb_clear_addr=5'd0;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[1]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd1;
			if(!((waddr0_rst == 5'd1) && wen0_rst))begin
				cdb_clear_addr=5'd1;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[2]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd2;
			if(!((waddr0_rst == 5'd2) && wen0_rst))begin
				cdb_clear_addr=5'd2;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[3]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd3;
			if(!((waddr0_rst == 5'd3) && wen0_rst))begin
				cdb_clear_addr=5'd3;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[4]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd4;
			if(!((waddr0_rst == 5'd4) && wen0_rst))begin
				cdb_clear_addr=5'd4;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[5]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd5;
			if(!((waddr0_rst == 5'd5) && wen0_rst))begin
				cdb_clear_addr=5'd5;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[6]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd6;
			if(!((waddr0_rst == 5'd6) && wen0_rst))begin
				cdb_clear_addr=5'd6;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[7]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd7;
			if(!((waddr0_rst == 5'd7) && wen0_rst))begin
				cdb_clear_addr=5'd7;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[8]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd8;
			if(!((waddr0_rst == 5'd8) && wen0_rst))begin
				cdb_clear_addr=5'd8;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[9]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd9;
			if(!((waddr0_rst == 5'd9) && wen0_rst))begin
				cdb_clear_addr=5'd9;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[10]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd10;
			if(!((waddr0_rst == 5'd10) && wen0_rst))begin
				cdb_clear_addr=5'd10;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[11]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd11;
			if(!((waddr0_rst == 5'd11) && wen0_rst))begin
				cdb_clear_addr=5'd11;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[12]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd12;
			if(!((waddr0_rst == 5'd12) && wen0_rst))begin
				cdb_clear_addr=5'd12;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[13]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd13;
			if(!((waddr0_rst == 5'd13) && wen0_rst))begin
				cdb_clear_addr=5'd13;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[14]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd14;
			if(!((waddr0_rst == 5'd14) && wen0_rst))begin
				cdb_clear_addr=5'd14;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[15]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd15;
			if(!((waddr0_rst == 5'd15) && wen0_rst))begin
				cdb_clear_addr=5'd15;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[16]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd16;
			if(!((waddr0_rst == 5'd16) && wen0_rst))begin
				cdb_clear_addr=5'd16;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[17]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd17;
			if(!((waddr0_rst == 5'd17) && wen0_rst))begin
				cdb_clear_addr=5'd17;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[18]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd18;
			if(!((waddr0_rst == 5'd18) && wen0_rst))begin
				cdb_clear_addr=5'd18;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[19]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd19;
			if(!((waddr0_rst == 5'd19) && wen0_rst))begin
				cdb_clear_addr=5'd19;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[20]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd20;
			if(!((waddr0_rst == 5'd20) && wen0_rst))begin
				cdb_clear_addr=5'd20;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[21]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd21;
			if(!((waddr0_rst == 5'd21) && wen0_rst))begin
				cdb_clear_addr=5'd21;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[22]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd22;
			if(!((waddr0_rst == 5'd22) && wen0_rst))begin
				cdb_clear_addr=5'd22;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[23]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd23;
			if(!((waddr0_rst == 5'd23) && wen0_rst))begin
				cdb_clear_addr=5'd23;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[24]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd24;
			if(!((waddr0_rst == 5'd24) && wen0_rst))begin
				cdb_clear_addr=5'd24;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[25]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd25;
			if(!((waddr0_rst == 5'd25) && wen0_rst))begin
				cdb_clear_addr=5'd25;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[26]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd26;
			if(!((waddr0_rst == 5'd26) && wen0_rst))begin
				cdb_clear_addr=5'd26;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[27]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd27;
			if(!((waddr0_rst == 5'd27) && wen0_rst))begin
				cdb_clear_addr=5'd27;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[28]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd28;
			if(!((waddr0_rst == 5'd28) && wen0_rst))begin
				cdb_clear_addr=5'd28;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[29]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd29;
			if(!((waddr0_rst == 5'd29) && wen0_rst))begin
				cdb_clear_addr=5'd29;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[30]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd30;
			if(!((waddr0_rst == 5'd30) && wen0_rst))begin
				cdb_clear_addr=5'd30;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else if((registers[31]=={1'b1,cdb_tag_rst}))begin
			wen_regfile_rst = 5'd31;
			if(!((waddr0_rst == 5'd31) && wen0_rst))begin
				cdb_clear_addr=5'd31;
			end
			else begin
				cdb_clear_addr=5'h0;
			end
		end
		else begin
			wen_regfile_rst = 5'h0;
			cdb_clear_addr=5'h0;
		end
	end
	else begin
		wen_regfile_rst = 5'h0;
		cdb_clear_addr=5'h0;
	end
end

//Asyncronus read to registers
assign rs1tag_rst = registers[rs1addr_rst][5:0];
assign rs1valid_rst = registers[rs1addr_rst][6];

assign rs2tag_rst = registers[rs2addr_rst][5:0];
assign rs2valid_rst = registers[rs2addr_rst][6];

endmodule
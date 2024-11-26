// Coder:           David Adrian Michel Torres, Eduardo Ethandrake Castillo Pulido
// Date:            07/05/23
// File:			     branch_prediction.sv
// Module name:	  branch_prediction
// Project Name:	  risc_v_top
// Description:	  This is a branch predictor module using one bit

`include "utils.sv"
module branch_prediction #(parameter DATA_WIDTH = 32,parameter BRANCH_NO=8)(
    input i_clk,
    input i_rst_n,
    //input[6:0] ex_mem_opcode,//opcode of retired instr
    input logic[1:0] retired_inst_type,//type of retired instr
    //input[6:0] if_id_opcode,//opcode of dispatched instr
    input logic[1:0] dispatch_inst_type,//type of dispatched instr
    //input ex_mem_branch_taken,//retired interface branch_taken
    input retired_branch_taken,//retired interface branch_taken
    //input[31:0] ex_mem_branch_target,// retired interface pc(branch target)
    input[31:0] retired_branch_target,
    output[31:0] retired_branch_prediction,
    //input[31:0] if_pc,//pc of dispatched instr
    input[31:0] dispatch_pc,
    //input[31:0] ex_mem_pc,//pc of retired interface instr (include in interface this PC)
    input[31:0] retire_pc,
    output prediction, //taken or not taken decision
    output[31:0] branch_target,
    output prediction_checkout_ex_mem
);



//Declare our memory
//reg [31:0] registers [0:31];
//localparam B_TYPE = 7'b1100011;
reg [DATA_WIDTH-1:0] BHB [(BRANCH_NO)-1:0];
reg [BRANCH_NO-1:0] BHT = {BRANCH_NO{1'b0}};

generate
	genvar i;
	for(i=0;i<BRANCH_NO;i=i+1) begin : test
        always@(posedge i_clk, negedge i_rst_n) begin
            if(!i_rst_n)
                BHB[i] <= 32'h0;
            //else if(ex_mem_opcode==B_TYPE && ex_mem_pc[2:0]==i)
            else if(retired_inst_type==BRANCH && retire_pc[4:2]==i)
                //BHB[i] <= ex_mem_branch_target;
                BHB[i] <= retired_branch_target;
            else
                BHB[i] <= BHB[i];
        end
	end
endgenerate

always @(posedge i_clk)
begin
	//Write
	//if (ex_mem_opcode==B_TYPE) begin
	if (retired_inst_type==BRANCH) begin
		//BHT[ex_mem_pc[2:0]] <= ex_mem_branch_taken;
        BHT[retire_pc[4:2]] <= retired_branch_taken;
    end
end

/*


integer i;
initial begin
	for(i=0;i<(BRANCH_NO);i=i+1)
		BHB[i] <= 32'h0;
end

always @(posedge i_clk)
begin
	//Write
	if (ex_mem_opcode==B_TYPE) begin
		BHT[ex_mem_pc[2:0]] <= ex_mem_branch_taken;
        BHB[ex_mem_pc[2:0]] <= ex_mem_branch_target;
    end
end
	*/
// Reading if memory read enable
//assign prediction = (if_id_opcode == B_TYPE) ? BHT[if_pc[2:0]] : 1'b0;
assign prediction = (dispatch_inst_type == BRANCH) ? BHT[dispatch_pc[4:2]] : 1'b0;
//assign branch_target = (if_id_opcode == B_TYPE) ? BHB[if_pc[2:0]] : 32'b0;
assign branch_target = (dispatch_inst_type == BRANCH) ? BHB[dispatch_pc[4:2]] : 32'b0;
//assign prediction_checkout_ex_mem = (ex_mem_opcode == B_TYPE) ? BHT[ex_mem_pc[2:0]] : 1'b0;
assign prediction_checkout_ex_mem = (retired_inst_type == BRANCH) ? BHT[retire_pc[4:2]] : 1'b0;
assign retired_branch_prediction = (retired_inst_type == BRANCH) ? BHB[retire_pc[4:2]] : 32'b0;
endmodule
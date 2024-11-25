// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            21/11/24
// File:			     rob_fifo.sv
// Module name:	  taf_fifo
// Project Name:	  risc_v_sp
// Description:	  rob_fifo

//if branch mispredicted we'll flush all younger instructions in the pipeline
//redirects fetch engine to the appropriate exception handling routine
//head is the oldest one (rp)
//tail is the youngest one (wp)
//add comparators, one for rs1 and other for rs2
`include "utils.sv"
module rob_fifo #(parameter DEPTH=32)(
    input i_clk,
    input i_rst_n,
    //input rob_fifo_data data_in,
    input [5:0] data_in,//instr tag
    input w_en,
    input flush,
    //input [5:0] cdb_tag,
    //input cdb_valid,
    //input [31:0] cdb_data,
    input retire_completed,
    output [5:0] data_out,
    output o_full,
    output empty
    //output reg issue_queue_rdy
);
localparam POINTER_WIDTH = $clog2(DEPTH);

reg [5:0] fifo[DEPTH];
reg [POINTER_WIDTH:0]tail;
reg [POINTER_WIDTH:0]head;
reg full;

wire [POINTER_WIDTH:0] current_size = tail-head;


//FIFO initialization
//Initialize registers
initial begin
	fifo[0] <= 0;
	fifo[1] <= 0;
	fifo[2] <= 0;
	fifo[3] <= 0;
    fifo[4] <= 0;
	fifo[5] <= 0;
	fifo[6] <= 0;
	fifo[7] <= 0;
	fifo[8] <= 0;
	fifo[9] <= 0;
	fifo[10] <= 0;
	fifo[11] <= 0;
    fifo[12] <= 0;
	fifo[13] <= 0;
	fifo[14] <= 0;
	fifo[15] <= 0;
    fifo[16] <= 0;
    fifo[17] <= 0;
    fifo[18] <= 0;
    fifo[19] <= 0;
    fifo[20] <= 0;
    fifo[21] <= 0;
    fifo[22] <= 0;
    fifo[23] <= 0;
    fifo[24] <= 0;
    fifo[25] <= 0;
    fifo[26] <= 0;
    fifo[27] <= 0;
    fifo[28] <= 0;
    fifo[29] <= 0;
    fifo[30] <= 0;
    fifo[31] <= 0;
end

//updating
//always @(posedge i_clk) begin
//    if (cdb_valid)begin
//        //rs1 update
//        //checks if rs1 is not valid and tag is equal to cdb_tag
//        if(fifo[0] !=0 && fifo[0].common_data.rs1_data_valid==1'b0 && fifo[0].common_data.rs1_tag==cdb_tag)begin
//            fifo[0].common_data.rs1_data=cdb_data;
//            fifo[0].common_data.rs1_data_valid=1'b1; //set rs1 as valid because from cdb fwd
//        end
//        if(fifo[1] !=0 && fifo[1].common_data.rs1_data_valid==1'b0 && fifo[1].common_data.rs1_tag==cdb_tag)begin
//            fifo[1].common_data.rs1_data=cdb_data;
//            fifo[1].common_data.rs1_data_valid=1'b1; //set rs1 as valid because from cdb fwd
//        end
//        if(fifo[2] !=0 && fifo[2].common_data.rs1_data_valid==1'b0 && fifo[2].common_data.rs1_tag==cdb_tag)begin
//            fifo[2].common_data.rs1_data=cdb_data;
//            fifo[2].common_data.rs1_data_valid=1'b1; //set rs1 as valid because from cdb fwd
//        end
//        if(fifo[3] !=0 && fifo[3].common_data.rs1_data_valid==1'b0 && fifo[3].common_data.rs1_tag==cdb_tag)begin
//            fifo[3].common_data.rs1_data=cdb_data;
//            fifo[3].common_data.rs1_data_valid=1'b1; //set rs1 as valid because from cdb fwd
//        end
//
//        //rs2 update
//        //checks if rs2 is not valid and tag is equal to cdb_tag
//        if(fifo[0] !=0 && fifo[0].common_data.rs2_data_valid==1'b0 && fifo[0].common_data.rs2_tag==cdb_tag)begin
//            fifo[0].common_data.rs2_data=cdb_data;
//            fifo[0].common_data.rs2_data_valid=1'b1; //set rs2 as valid because from cdb fwd
//        end
//        if(fifo[1] !=0 && fifo[1].common_data.rs2_data_valid==1'b0 && fifo[1].common_data.rs2_tag==cdb_tag)begin
//            fifo[1].common_data.rs2_data=cdb_data;
//            fifo[1].common_data.rs2_data_valid=1'b1; //set rs2 as valid because from cdb fwd
//        end
//        if(fifo[2] !=0 && fifo[2].common_data.rs2_data_valid==1'b0 && fifo[2].common_data.rs2_tag==cdb_tag)begin
//            fifo[2].common_data.rs2_data=cdb_data;
//            fifo[2].common_data.rs2_data_valid=1'b1; //set rs2 as valid because from cdb fwd
//        end
//        if(fifo[3] !=0 && fifo[3].common_data.rs2_data_valid==1'b0 && fifo[3].common_data.rs2_tag==cdb_tag)begin
//            fifo[3].common_data.rs2_data=cdb_data;
//            fifo[3].common_data.rs2_data_valid=1'b1; //set rs2 as valid because from cdb fwd
//        end
//    end
//end
//
//writing
always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n | flush)begin
        tail = 3'h0;
    end
    //fifo write data
    else if(w_en & !full)begin
        fifo[tail[POINTER_WIDTH-1:0]] = data_in;
        tail = tail+1;
        //if(tail[POINTER_WIDTH])begin
        //    tail[POINTER_WIDTH]=0;
        //end
        //else begin
        //end
    end
    if(flush)begin
        tail = 3'h0;
    end
    //fifo 

end

always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n)begin
        head = 7'b0;
    end
    //fifo write data
    else if(retire_completed)begin
        head=head+1;
     //   if(head[POINTER_WIDTH])begin
     //       head=7'b0;
     //   end
    end

    if(flush)begin
        head = 7'b0;
    end
end

always @(*) begin
    if(!i_rst_n)begin
        full = 1;
    end
    else if(flush)begin
        full = 0;
    end
    else begin
        //full = (tail[POINTER_WIDTH:0] == head[POINTER_WIDTH:0]) ? 1 : (tail[POINTER_WIDTH] && (head[POINTER_WIDTH:0]==0)) ? 1 : 0;
        full = current_size == DEPTH;
    end
end

//review if fifo[head] is marked as complete, if so assign it to data_out
//always @(*) begin
//    if(((i_rst_n || !flush) && !empty) && (fifo[head[POINTER_WIDTH-1:0]].common_data.rs1_data_valid == 1) && (fifo[head[POINTER_WIDTH-1:0]].common_data.rs2_data_valid == 1))begin
//        data_out = fifo[head[POINTER_WIDTH-1:0]];
//        issue_queue_rdy = 1;
//    end
//    else begin
//        data_out = 0;
//        issue_queue_rdy = 0;
//    end
//end
    assign data_out = fifo[head[POINTER_WIDTH-1:0]];
	assign empty = tail[POINTER_WIDTH:0] == head[POINTER_WIDTH:0];
    assign o_full = full;

endmodule
// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            21/10/24
// File:			     exec_fifo.sv
// Module name:	  taf_fifo
// Project Name:	  risc_v_sp
// Description:	  exec_fifo

`include "utils.sv"
module exec_fifo #(parameter DEPTH=4)(
    input i_clk,
    input i_rst_n,
    input ld_st_fifo_data data_in,
    input w_en,
    input flush,
    input [5:0] cdb_tag,
    input cdb_valid,
    input [31:0] cdb_data,
    output ld_st_fifo_data data_out,
    output o_full,
    output empty,
    output reg issue_queue_rdy
);
localparam POINTER_WIDTH = $clog2(DEPTH);

ld_st_fifo_data fifo[DEPTH];
reg [POINTER_WIDTH:0]wp;
reg [POINTER_WIDTH:0]rp;
reg full;

wire [POINTER_WIDTH:0] current_size = wp-rp;


//FIFO initialization
//Initialize registers
initial begin
	fifo[0] <= 0;
	fifo[1] <= 0;
	fifo[2] <= 0;
	fifo[3] <= 0;
end

//updating
always @(posedge i_clk) begin
    if (cdb_valid)begin
        //rs1 update
        //checks if rs1 is not valid and tag is equal to cdb_tag
        if(fifo[0] !=0 && fifo[0].common_data.rs1_data_valid==1'b0 && fifo[0].common_data.rs1_tag==cdb_tag)begin
            fifo[0].common_data.rs1_data=cdb_data;
            fifo[0].common_data.rs1_data_valid=1'b1; //set rs1 as valid because from cdb fwd
        end
        if(fifo[1] !=0 && fifo[1].common_data.rs1_data_valid==1'b0 && fifo[1].common_data.rs1_tag==cdb_tag)begin
            fifo[1].common_data.rs1_data=cdb_data;
            fifo[1].common_data.rs1_data_valid=1'b1; //set rs1 as valid because from cdb fwd
        end
        if(fifo[2] !=0 && fifo[2].common_data.rs1_data_valid==1'b0 && fifo[2].common_data.rs1_tag==cdb_tag)begin
            fifo[2].common_data.rs1_data=cdb_data;
            fifo[2].common_data.rs1_data_valid=1'b1; //set rs1 as valid because from cdb fwd
        end
        if(fifo[3] !=0 && fifo[3].common_data.rs1_data_valid==1'b0 && fifo[3].common_data.rs1_tag==cdb_tag)begin
            fifo[3].common_data.rs1_data=cdb_data;
            fifo[3].common_data.rs1_data_valid=1'b1; //set rs1 as valid because from cdb fwd
        end

        //rs2 update
        //checks if rs2 is not valid and tag is equal to cdb_tag
        if(fifo[0] !=0 && fifo[0].common_data.rs2_data_valid==1'b0 && fifo[0].common_data.rs2_tag==cdb_tag)begin
            fifo[0].common_data.rs2_data=cdb_data;
            fifo[0].common_data.rs2_data_valid=1'b1; //set rs2 as valid because from cdb fwd
        end
        if(fifo[1] !=0 && fifo[1].common_data.rs2_data_valid==1'b0 && fifo[1].common_data.rs2_tag==cdb_tag)begin
            fifo[1].common_data.rs2_data=cdb_data;
            fifo[1].common_data.rs2_data_valid=1'b1; //set rs2 as valid because from cdb fwd
        end
        if(fifo[2] !=0 && fifo[2].common_data.rs2_data_valid==1'b0 && fifo[2].common_data.rs2_tag==cdb_tag)begin
            fifo[2].common_data.rs2_data=cdb_data;
            fifo[2].common_data.rs2_data_valid=1'b1; //set rs2 as valid because from cdb fwd
        end
        if(fifo[3] !=0 && fifo[3].common_data.rs2_data_valid==1'b0 && fifo[3].common_data.rs2_tag==cdb_tag)begin
            fifo[3].common_data.rs2_data=cdb_data;
            fifo[3].common_data.rs2_data_valid=1'b1; //set rs2 as valid because from cdb fwd
        end
    end
end

//writing
always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n | flush)begin
        wp = 3'h0;
    end
    //fifo write data
    else if(w_en & !full)begin
        fifo[wp[POINTER_WIDTH-1:0]] = data_in;
        wp = wp+1;
        //if(wp[POINTER_WIDTH])begin
        //    wp[POINTER_WIDTH]=0;
        //end
        //else begin
        //end
    end
    if(flush)begin
        wp = 3'h0;
    end
    //fifo 

end

always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n)begin
        rp = 7'b0;
    end
    //fifo write data
    else if(issue_queue_rdy)begin
        rp=rp+1;
     //   if(rp[POINTER_WIDTH])begin
     //       rp=7'b0;
     //   end
    end

    if(flush)begin
        rp = 7'b0;
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
        //full = (wp[POINTER_WIDTH:0] == rp[POINTER_WIDTH:0]) ? 1 : (wp[POINTER_WIDTH] && (rp[POINTER_WIDTH:0]==0)) ? 1 : 0;
        full = current_size == DEPTH;
    end
end

always @(*) begin
    if(((i_rst_n || !flush) && !empty) && (fifo[rp[POINTER_WIDTH-1:0]].common_data.rs1_data_valid == 1) && (fifo[rp[POINTER_WIDTH-1:0]].common_data.rs2_data_valid == 1))begin
        data_out = fifo[rp[POINTER_WIDTH-1:0]];
        issue_queue_rdy = 1;
    end
    else begin
        data_out = 0;
        issue_queue_rdy = 0;
    end
end

	assign empty = wp[POINTER_WIDTH:0] == rp[POINTER_WIDTH:0];
    assign o_full = full;

endmodule
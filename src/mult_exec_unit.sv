// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     mult_issue.sv
// Module name:	  mult issue module
// Project Name:	  risc_v_sp
// Description:	  mult issue module
`include "utils.sv"
module mult_exec_unit #(parameter LATENCY = 3)(
    input logic clk,
    input logic rst_n,
    input logic issue_granted,
    input common_fifo_data mult_exec_fifo_data,
    output cdb_bfm o_mult_submit
    //output reg issue_done
);

cdb_bfm [0:LATENCY-1] latency_submit;
cdb_bfm mult_submit;

always @(*) begin
    //mult_submit.issue_done=0;
    if(issue_granted)begin
        mult_submit.cdb_branch = 1'b0;
        mult_submit.cdb_valid = 1'b1;
        mult_submit.cdb_tag = mult_exec_fifo_data.rd_tag;
        mult_submit.cdb_result = mult_exec_fifo_data.rs1_data*mult_exec_fifo_data.rs2_data;
        //mult_submit.issue_done=1;
    end
    else begin
        mult_submit.cdb_branch = 1'b0;
        mult_submit.cdb_valid = 1'b0;
        mult_submit.cdb_tag = 0;
        mult_submit.cdb_result =0;
        //mult_submit.issue_done=0;
    end
end

ffd_param #(.LENGTH($bits(cdb_bfm))) latency(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_en(1'b1),
    .d(mult_submit),
    .q(latency_submit[0])
);

//latency generator
genvar i;
generate
    for (i=1; i<LATENCY; i++) begin
        ffd_param #(.LENGTH($bits(cdb_bfm))) latency(
            .i_clk(clk),
            .i_rst_n(rst_n),
            .i_en(1'b1),
            .d(latency_submit[i-1]),
            .q(latency_submit[i])
        );
    end
endgenerate

assign o_mult_submit=latency_submit[LATENCY-1];
//assign issue_done = latency_submit[LATENCY-1].issue_done;

endmodule
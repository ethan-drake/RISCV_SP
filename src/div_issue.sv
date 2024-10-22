// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     div_issue.sv
// Module name:	  div issue module
// Project Name:	  risc_v_sp
// Description:	  div issue module
`include "utils.sv"
module div_issue #(parameter LATENCY = 4)(
    input logic clk,
    input logic rst_n,
    input logic issue_queue_rdy,
    input common_fifo_data div_exec_fifo_data,
    output cdb_bfm o_div_submit,
    output reg issue_done
);

cdb_bfm [0:LATENCY-1] latency_submit;
cdb_bfm div_submit;

always @(*) begin
    div_submit.issue_done=0;
    if(issue_queue_rdy)begin
        div_submit.cdb_branch = 1'b0;
        div_submit.cdb_valid = 1'b1;
        div_submit.cdb_tag = div_exec_fifo_data.rd_tag;
        div_submit.cdb_result = div_exec_fifo_data.rs1_data / div_exec_fifo_data.rs2_data;
        div_submit.issue_done=1;
    end
    else begin
        div_submit.cdb_branch = 1'b0;
        div_submit.cdb_valid = 1'b0;
        div_submit.cdb_tag = 0;
        div_submit.cdb_result =0;
        div_submit.issue_done=0;
    end
end

ffd_param #(.LENGTH($bits(cdb_bfm))) latency(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_en(1'b1),
    .d(div_submit),
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

assign o_div_submit=latency_submit[LATENCY-1];
assign issue_done = latency_submit[LATENCY-1].issue_done;

endmodule
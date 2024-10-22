`include "utils.sv"

module riscv_sp_top(
	//Inputs - Platform
	input clk,
	input rst_n,
    //input [31:0] jmp_branch_address,
    //input jmp_branch_valid
    input [5:0] cdb_tag,
    input cdb_valid,
    input [31:0] cdb_data,
    input cdb_branch,
    input cdb_branch_taken
);
wire i_rd_en;
wire rd_en, abort, we, dout_valid;
wire [127:0] dout;
wire [31:0] pc_in;
wire [31:0] pc_out;
wire [31:0] instr;
wire [31:0] jmp_branch_address;
wire jmp_branch_valid;
wire empty;

int_issue_data exec_int_issue_data;
common_issue_data exec_mult_issue_data;
common_issue_data exec_div_issue_data;
mem_issue_data exec_mem_issue_data;
cdb_submit_data int_submit_data;
cdb_submit_data mult_submit_data;
cdb_submit_data div_submit_data;
cdb_submit_data mem_submit_data;


//BR NOT TAKEN SCENARIO
wire fetch_next_instr;

i_cache cache(
    .pc_in({pc_in[31:4],4'b0}),
	.rd_en(rd_en),
    .abort(abort),
	.we(1'b0),
    .clk(clk),
    .i_rst_n(rst_n),
	//outputs
	.dout(dout),
	.dout_valid(dout_valid)
);

ifq ifq_module(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .dout(dout),
    .dout_valid(dout_valid),
    .rd_en(i_rd_en),
    .jmp_branch_address(jmp_branch_address),
    .jmp_branch_valid(jmp_branch_valid),
    .fetch_next_instr(fetch_next_instr),
    .pc_in(pc_in),
    .o_rd_en(rd_en),
    .abort(abort),
    .pc_out(pc_out),
    .instr(instr),
    .empty(empty)
);


dispatcher dispatcher(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_fetch_pc_plus_4(pc_out),
    .i_fetch_instruction(instr),
    .i_fetch_empty_flag(empty),
    .dispatch_jmp_br_addr(jmp_branch_address),
    .dispatch_jmp_valid(jmp_branch_valid),
    .dispatch_rd_en(i_rd_en),
    .cdb_tag(cdb_tag),
    .cdb_valid(cdb_valid),
    .cdb_data(cdb_data),
    .cdb_branch(cdb_branch),
    .cdb_branch_taken(cdb_branch_taken),
    .fetch_next_instr(fetch_next_instr),
    .exec_int_issue_data(exec_int_issue_data),
    .exec_mult_issue_data(exec_mult_issue_data),
    .exec_div_issue_data(exec_div_issue_data),
    .exec_mem_issue_data(exec_mem_issue_data),
    .issue_done_int(int_submit_data.issue_done),
    .issue_done_mem(mem_submit_data.issue_done),
    .issue_done_mult(mult_submit_data.issue_done),
    .issue_done_div(div_submit_data.issue_done)
);

issue issue(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .exec_int_issue_data(exec_int_issue_data),
    .exec_mult_issue_data(exec_mult_issue_data),
    .exec_div_issue_data(exec_div_issue_data),
    .exec_mem_issue_data(exec_mem_issue_data),
    .int_submit_data(int_submit_data),
    .mult_submit_data(mult_submit_data),
    .div_submit_data(div_submit_data),
    .mem_submit_data(mem_submit_data)
);

endmodule
`include "utils.sv"

module riscv_sp_top(
	//Inputs - Platform
	input clk,
	input rst_n
    //input [31:0] jmp_branch_address,
    //input jmp_branch_valid
    //input [5:0] cdb_tag,
    //input cdb_valid,
    //input [31:0] cdb_data,
    //input cdb_branch,
    //input cdb_branch_taken
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
wire flush;

int_issue_data exec_int_issue_data;
common_issue_data exec_mult_issue_data;
common_issue_data exec_div_issue_data;
mem_issue_data exec_mem_issue_data;



cdb_bfm common_data_bus;

wire issue_granted_int;
wire issue_granted_mem;
wire issue_granted_mult;
wire issue_granted_div;

//BR NOT TAKEN SCENARIO
wire fetch_next_instr;

retire_store retire_store;

int_fifo_data exec_int_fifo_data_in;
ld_st_fifo_data exec_ld_st_fifo_data_in;
common_fifo_data exec_mult_fifo_data_in;
common_fifo_data exec_div_fifo_data_in;

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
    //.fetch_next_instr(fetch_next_instr),
    //.second_branch_instr(second_branch_instr),
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
    .flush(flush),
    //.cdb_tag(common_data_bus.cdb_tag),
    //.cdb_valid(common_data_bus.cdb_valid),
    //.cdb_data(common_data_bus.cdb_result),
    //.cdb_branch(common_data_bus.cdb_branch),
    //.cdb_branch_taken(common_data_bus.cdb_branch_taken),
    .cdb(common_data_bus),
    .exec_int_fifo_ctrl_empty(exec_int_fifo_ctrl_empty),
    .exec_ld_st_fifo_ctrl_empty(exec_ld_st_fifo_ctrl_empty),
    .exec_mult_fifo_ctrl_empty(exec_mult_fifo_ctrl_empty),
    .exec_div_fifo_ctrl_empty(exec_div_fifo_ctrl_empty),
    .any_rsv_station_full(any_rsv_station_full),
    .exec_int_fifo_data_in(exec_int_fifo_data_in),
    .exec_ld_st_fifo_data_in(exec_ld_st_fifo_data_in),
    .exec_mult_fifo_data_in(exec_mult_fifo_data_in),
    .exec_div_fifo_data_in(exec_div_fifo_data_in),
    .exec_int_fifo_ctrl_w_en(exec_int_fifo_ctrl_w_en),
    .exec_ld_st_fifo_ctrl_w_en(exec_ld_st_fifo_ctrl_w_en),
    .exec_mult_fifo_ctrl_w_en(exec_mult_fifo_ctrl_w_en),
    .exec_div_fifo_ctrl_w_en(exec_div_fifo_ctrl_w_en),
    //.fetch_next_instr(fetch_next_instr),
    //.second_branch_instr(second_branch_instr),
    //.exec_int_issue_data(exec_int_issue_data),
    //.exec_mult_issue_data(exec_mult_issue_data),
    //.exec_div_issue_data(exec_div_issue_data),
    //.exec_mem_issue_data(exec_mem_issue_data),
    //.issue_done_int(issue_granted_int),
    //.issue_done_mem(issue_granted_mem),
    //.issue_done_mult(issue_granted_mult),
    //.issue_done_div(issue_granted_div),
    .retire_store(retire_store)
);

rsv_stations rsv_stations(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .flush(flush),
    .cdb(common_data_bus),
    .exec_int_fifo_data_in(exec_int_fifo_data_in),
    .exec_int_fifo_ctrl_w_en(exec_int_fifo_ctrl_w_en),
    .exec_ld_st_fifo_data_in(exec_ld_st_fifo_data_in),
    .exec_ld_st_fifo_ctrl_w_en(exec_ld_st_fifo_ctrl_w_en),
    .exec_mult_fifo_data_in(exec_mult_fifo_data_in),
    .exec_mult_fifo_ctrl_w_en(exec_mult_fifo_ctrl_w_en),
    .exec_div_fifo_data_in(exec_div_fifo_data_in),
    .exec_div_fifo_ctrl_w_en(exec_div_fifo_ctrl_w_en),
    .issue_done_int(issue_granted_int),
    .issue_done_mem(issue_granted_mem),
    .issue_done_mult(issue_granted_mult),
    .issue_done_div(issue_granted_div),
    .exec_int_fifo_ctrl_empty(exec_int_fifo_ctrl_empty),
    .exec_ld_st_fifo_ctrl_empty(exec_ld_st_fifo_ctrl_empty),
    .exec_mult_fifo_ctrl_empty(exec_mult_fifo_ctrl_empty),
    .exec_div_fifo_ctrl_empty(exec_div_fifo_ctrl_empty),
    .exec_int_issue_data(exec_int_issue_data),
    .exec_mult_issue_data(exec_mult_issue_data),
    .exec_div_issue_data(exec_div_issue_data),
    .exec_mem_issue_data(exec_mem_issue_data),
    .any_rsv_station_full(any_rsv_station_full)
);

issue_unit issue_unit(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .flush(flush),
    .exec_int_issue_data(exec_int_issue_data),
    .exec_mult_issue_data(exec_mult_issue_data),
    .exec_div_issue_data(exec_div_issue_data),
    .exec_mem_issue_data(exec_mem_issue_data),
    //.ready_int(exec_int_issue_data.issue_rdy),
    //.ready_mult(exec_mult_issue_data.issue_rdy),
    //.ready_div(exec_div_issue_data.issue_rdy),
    //.ready_mem(exec_mem_issue_data.issue_rdy),
    //.div_exec_busy(),
    //.int_cdb_input(),
    //.div_cdb_input(),
    //.mult_cdb_input(),
    //.mem_cdb_input(),
    .issue_int(issue_granted_int),
    .issue_mult(issue_granted_mult),
    .issue_div(issue_granted_div),
    .issue_mem(issue_granted_mem),
    .cdb_output(common_data_bus),
    .retire_store(retire_store)
);



endmodule
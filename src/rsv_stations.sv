// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            22/09/24
// File:			     br_jmp_addr_calc.sv
// Module name:	  br_jmp_addr_calc
// Project Name:	  risc_v_sp
// Description:	  br_jmp_addr_calc
`include "utils.sv"
module rsv_stations(
    input i_clk,
    input i_rst_n,
    input flush,
    input cdb_bfm cdb,
    input int_fifo_data exec_int_fifo_data_in,
    input exec_int_fifo_ctrl_w_en,
    input ld_st_fifo_data exec_ld_st_fifo_data_in,
    input exec_ld_st_fifo_ctrl_w_en,
    input common_fifo_data exec_mult_fifo_data_in,
    input exec_mult_fifo_ctrl_w_en,
    input common_fifo_data exec_div_fifo_data_in,
    input exec_div_fifo_ctrl_w_en,
    input issue_done_int,
    input issue_done_mem,
    input issue_done_mult,
    input issue_done_div,
    output exec_int_fifo_ctrl_empty,
    output exec_ld_st_fifo_ctrl_empty,
    output exec_mult_fifo_ctrl_empty,
    output exec_div_fifo_ctrl_empty,
    output int_issue_data exec_int_issue_data,
    output common_issue_data exec_mult_issue_data,
    output common_issue_data exec_div_issue_data,
    output mem_issue_data exec_mem_issue_data,
    output any_rsv_station_full
);

wire int_full, mult_full, mem_full, div_full; 

//RSV STATIONS
exec_rsv_station_shift #(.DEPTH(4), .DATA_WIDTH($bits(int_fifo_data))) int_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_int_fifo_data_in),
    .w_en(exec_int_fifo_ctrl_w_en),
    //.rd_en(tb_int_rd),
    .flush(flush),//1'b0),//cdb.cdb_branch_taken),
    .data_out(exec_int_issue_data.rsv_station_data),//exec_int_fifo_data_out),
    .o_full(int_full),//exec_int_fifo_ctrl.queue_full),
    .empty(exec_int_fifo_ctrl_empty),
    .cdb_tag(cdb.cdb_tag),
    .cdb_valid(cdb.cdb_valid),
    .cdb_data(cdb.cdb_result),
    .issue_queue_rdy(exec_int_issue_data.issue_rdy),
    .issue_completed(issue_done_int)
);



exec_fifo #(.DEPTH(4)) ld_st_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_ld_st_fifo_data_in),
    .w_en(exec_ld_st_fifo_ctrl_w_en),
    .flush(flush),//retire_bus_if.flush),//1'b0),
    .cdb_tag(cdb.cdb_tag),
    .cdb_valid(cdb.cdb_valid),
    .cdb_data(cdb.cdb_result),
    .data_out(exec_mem_issue_data.rsv_station_data),//exec_ld_st_fifo_data_out),
    .o_full(mem_full),//exec_ld_st_fifo_ctrl.queue_full),
    .empty(exec_ld_st_fifo_ctrl_empty),
    .issue_queue_rdy(exec_mem_issue_data.issue_rdy),//mem_issue_rdy)
    .issue_completed(issue_done_mem)
);

exec_rsv_station_shift #(.DEPTH(4), .DATA_WIDTH($bits(common_fifo_data))) mult_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_mult_fifo_data_in),
    .w_en(exec_mult_fifo_ctrl_w_en),
    //.rd_en(tb_mult_rd),
    .flush(flush),//retire_bus_if.flush),//1'b0),//cdb.cdb_branch_taken),
    .data_out(exec_mult_issue_data.rsv_station_data),//exec_mult_fifo_data_out),
    .o_full(mult_full),//exec_mult_fifo_ctrl.queue_full),
    .empty(exec_mult_fifo_ctrl_empty),
    .cdb_tag(cdb.cdb_tag),
    .cdb_valid(cdb.cdb_valid),
    .cdb_data(cdb.cdb_result),
    .issue_queue_rdy(exec_mult_issue_data.issue_rdy),//mult_issue_rdy),
    .issue_completed(issue_done_mult)
);

exec_rsv_station_shift #(.DEPTH(4), .DATA_WIDTH($bits(common_fifo_data))) div_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_div_fifo_data_in),
    .w_en(exec_div_fifo_ctrl_w_en),
    //.rd_en(tb_div_rd),
    .flush(flush),//retire_bus_if.flush),//1'b0),//cdb.cdb_branch_taken),
    .data_out(exec_div_issue_data.rsv_station_data),//exec_div_fifo_data_out),
    .o_full(div_full),//exec_div_fifo_ctrl.queue_full),
    .empty(exec_div_fifo_ctrl_empty),
    .cdb_tag(cdb.cdb_tag),
    .cdb_valid(cdb.cdb_valid),
    .cdb_data(cdb.cdb_result),
    .issue_queue_rdy(exec_div_issue_data.issue_rdy),//div_issue_rdy),
    .issue_completed(issue_done_div)
);

//assign any_rsv_station_full=(exec_int_fifo_ctrl.queue_full | exec_ld_st_fifo_ctrl.queue_full | exec_mult_fifo_ctrl.queue_full | exec_div_fifo_ctrl.queue_full);
assign any_rsv_station_full = (int_full | mult_full | mem_full | div_full); 

endmodule
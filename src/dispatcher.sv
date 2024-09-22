// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            17/09/23
// File:			     dispatcher.sv
// Module name:	  dispatcher
// Project Name:	  mips_sp
// Description:	  dispatcher

`include "utils.sv"

module dispatcher(
    input i_clk,
    input i_rst_n,
    input [31:0]i_fetch_pc_plus_4,
    input [31:0]i_fetch_instruction,
    input i_fetch_empty_flag,
    output [31:0] dispatch_jmp_br_addr,
    output dispatch_jmp_valid,
    output dispatch_rd_en
);

//Dispatch integer structure instantiation
int_fifo_data exec_int_fifo_data_in;
int_fifo_data exec_int_fifo_data_out;
common_fifo_ctrl exec_int_fifo_ctrl;
//Dispatch load/store structure instantiation
ld_st_fifo_data exec_ld_st_fifo_data_in;
ld_st_fifo_data exec_ld_st_fifo_data_out;
common_fifo_ctrl exec_ld_st_fifo_ctrl;
//Dispatch Multiplication structure instantiation
common_fifo_data exec_mult_fifo_data_in;
common_fifo_data exec_mult_fifo_data_out;
common_fifo_ctrl exec_mult_fifo_ctrl;
//Dispatch Division structure instantiation
common_fifo_data exec_div_fifo_data_in;
common_fifo_data exec_div_fifo_data_out;
common_fifo_ctrl exec_div_fifo_ctrl;

exec_fifo #(.DEPTH(4), .DATA_WIDTH($bits(int_fifo_data))) int_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_int_fifo_data_in),
    .w_en(exec_int_fifo_ctrl.dispatch_en),
    .rd_en(1'0),
    .flush(1'b0),
    .data_out(exec_int_fifo_data_out),
    .o_full(exec_int_fifo_ctrl.queue_full),
    .empty(exec_int_fifo_ctrl.queue_empty)
);

exec_fifo #(.DEPTH(4), .DATA_WIDTH($bits(ld_st_fifo_data))) ld_st_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_ld_st_fifo_data_in),
    .w_en(exec_ld_st_fifo_ctrl.dispatch_en),
    .rd_en(1'0),
    .flush(1'b0),
    .data_out(exec_ld_st_fifo_data_out),
    .o_full(exec_ld_st_fifo_ctrl.queue_full),
    .empty(exec_ld_st_fifo_ctrl.queue_empty)
);

exec_fifo #(.DEPTH(4), .DATA_WIDTH($bits(common_fifo_data))) mult_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_mult_fifo_data_in),
    .w_en(exec_mult_fifo_ctrl.dispatch_en),
    .rd_en(1'0),
    .flush(1'b0),
    .data_out(exec_mult_fifo_data_out),
    .o_full(exec_mult_fifo_ctrl.queue_full),
    .empty(exec_mult_fifo_ctrl.queue_empty)
);

exec_fifo #(.DEPTH(4), .DATA_WIDTH($bits(common_fifo_data))) div_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_div_fifo_data_in),
    .w_en(exec_div_fifo_ctrl.dispatch_en),
    .rd_en(1'0),
    .flush(1'b0),
    .data_out(exec_div_fifo_data_out),
    .o_full(exec_div_fifo_ctrl.queue_full),
    .empty(exec_div_fifo_ctrl.queue_empty)
);


endmodule
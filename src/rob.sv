// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            21/11/24
// File:			     rob.sv
// Module name:	  taf_fifo
// Project Name:	  risc_v_sp
// Description:	  rob

`include "utils.sv"
module rob(
    input i_clk,
    input i_rst_n,
    input cdb_bfm issue_cdb,
    output rob_fifo_full,
    dispatch_w_to_rob.rob dispatch_w_to_rob_if,
    dispatch_check_rs_status.rob dispatch_check_rs_status_if,
    retire_bus.rob retire_bus_if
);


//rob_fifo_data rob_fifo_input;
//assign rob_fifo_input.valid = 1'b0;
//assign rob_fifo_input.instr_type = dispatch_type'(dispatch_w_to_rob_if.dispatch_instr_type);
//assign rob_fifo_input.state = rob_state'(0);
//assign rob_fifo_input.rd = dispatch_w_to_rob_if.dispatch_rd_reg;
//assign rob_fifo_input.rd_tag = dispatch_w_to_rob_if.dispatch_rd_tag;
//assign rob_fifo_input.rd_value = 0;
//assign rob_fifo_input.store_addr = 0;
//assign rob_fifo_input.store_data = 0;
//assign rob_fifo_input.pc = dispatch_w_to_rob_if.dispatch_pc;
//assign rob_fifo_input.exception = 0;
//
logic [5:0] rob_fifo_output;
//wire rob_fifo_full;
wire rob_fifo_empty;
wire retire_enable;

rob_fifo rob_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(dispatch_w_to_rob_if.dispatch_rd_tag),
    //.w_en(exec_int_fifo_ctrl.dispatch_en | exec_mult_fifo_ctrl.dispatch_en | exec_div_fifo_ctrl.dispatch_en | exec_ld_st_fifo_ctrl.dispatch_en),//dispatch_rd_en),
//    .w_en(dispatch_w_to_rob_if.dispatch_en),
    .w_en(dispatch_w_to_rob_if.dispatch_en && (dispatch_type'(dispatch_w_to_rob_if.dispatch_instr_type) != JUMP)),
    .flush(retire_bus_if.flush),
    .retire_completed(retire_enable),
    .data_out(rob_fifo_output),
    .o_full(rob_fifo_full),
    .empty(rob_fifo_empty)
);

rob_rf_data rob_rf_data_input;
assign rob_rf_data_input.rd_reg = dispatch_w_to_rob_if.dispatch_rd_reg;
assign rob_rf_data_input.pc = dispatch_w_to_rob_if.dispatch_pc;
assign rob_rf_data_input.inst_type = dispatch_type'(dispatch_w_to_rob_if.dispatch_instr_type);
assign rob_rf_data_input.spec_data = 0;
assign rob_rf_data_input.spec_valid = 1'b0;
assign rob_rf_data_input.branch_taken = 1'b0;
assign rob_rf_data_input.valid = 1'b1;
//assign rob_rf_data_input.store_data = 0;
rob_rf_data rob_rf_rs1_output;
rob_rf_data rob_rf_rs2_output;

rob_rf_data rob_rf_retire_output;

reg_file_rob rf_temp(
	.clk(i_clk),
    .i_rst_n(i_rst_n),
    .flush(retire_bus_if.flush),
	//Write ports (New entry)
   // .wen_rf(dispatch_w_to_rob_if.dispatch_en),
    .wen_rf(dispatch_w_to_rob_if.dispatch_en && (dispatch_type'(dispatch_w_to_rob_if.dispatch_instr_type) != JUMP)),
	.write_data_rf(rob_rf_data_input),
	.write_addr_rf(dispatch_w_to_rob_if.dispatch_rd_tag),
	//Read ports (Consult_rs(1)(2))
	.rs1addr_rf(dispatch_check_rs_status_if.rs1_token),
	.rs1data_rf(rob_rf_rs1_output),
    .rs2addr_rf(dispatch_check_rs_status_if.rs2_token),
    .rs2data_rf(rob_rf_rs2_output),
    //update entry
    .issue_cdb(issue_cdb),
    //retire
    .rob_fifo_head(rob_fifo_output),
    .rob_rf_retire_valid(retire_enable),
    .rob_retire_data(rob_rf_retire_output)
);

assign dispatch_check_rs_status_if.rs1_data_valid = rob_rf_rs1_output.valid & rob_rf_rs1_output.spec_valid;
assign dispatch_check_rs_status_if.rs2_data_valid = rob_rf_rs2_output.valid & rob_rf_rs2_output.spec_valid;
assign dispatch_check_rs_status_if.rs1_data_spec = rob_rf_rs1_output.spec_data;
assign dispatch_check_rs_status_if.rs2_data_spec = rob_rf_rs2_output.spec_data;

assign retire_bus_if.rd_tag = (retire_enable==1'b1) ? rob_fifo_output: 0;
assign retire_bus_if.rd_reg = rob_rf_retire_output.rd_reg;
assign retire_bus_if.data = rob_rf_retire_output.spec_data;
assign retire_bus_if.pc = rob_rf_retire_output.pc;
assign retire_bus_if.branch = (rob_rf_retire_output.inst_type==BRANCH) ? 1'b1: 0;
assign retire_bus_if.branch_taken = rob_rf_retire_output.branch_taken;
assign retire_bus_if.store_ready = (rob_rf_retire_output.inst_type==STORE) ? rob_rf_retire_output.spec_valid : 0;
//assign retire_bus_if.store_data = (rob_rf_retire_output.inst_type==STORE) ? rob_rf_retire_output.store_data : 0;
assign retire_bus_if.valid = rob_rf_retire_output.valid;
assign retire_bus_if.spec_valid = rob_rf_retire_output.spec_valid;
assign retire_bus_if.retire_instr_type = rob_rf_retire_output.inst_type;
assign retire_bus_if.flush = (retire_bus_if.branch == 1'b1 && retire_bus_if.branch_taken) ? 1'b1 : 1'b0;


endmodule
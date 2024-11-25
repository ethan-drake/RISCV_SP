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
logic [4:0] rob_fifo_output;
//wire rob_fifo_full;
wire rob_fifo_empty;

rob_fifo rob_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(dispatch_w_to_rob_if.dispatch_rd_tag),
    //.w_en(exec_int_fifo_ctrl.dispatch_en | exec_mult_fifo_ctrl.dispatch_en | exec_div_fifo_ctrl.dispatch_en | exec_ld_st_fifo_ctrl.dispatch_en),//dispatch_rd_en),
    .w_en(dispatch_w_to_rob_if.dispatch_en),
    .flush(1'b0),
    .issue_completed(1'b0),
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
rob_rf_data rob_rf_rs1_output;
rob_rf_data rob_rf_rs2_output;

reg_file_rob rf_temp(
	.clk(i_clk),
    .i_rst_n(i_rst_n),
	//Write ports (New entry)
    .wen_rf(dispatch_w_to_rob_if.dispatch_en),
	.write_data_rf(rob_rf_data_input),
	.write_addr_rf(dispatch_w_to_rob_if.dispatch_rd_tag),
	//Read ports (Consult_rs(1)(2))
	.rs1addr_rf(dispatch_check_rs_status_if.rs1_token),
	.rs1data_rf(rob_rf_rs1_output),
    .rs2addr_rf(dispatch_check_rs_status_if.rs2_token),
    .rs2data_rf(rob_rf_rs2_output),
    //update entry
    .issue_cdb(issue_cdb)
);

assign dispatch_check_rs_status_if.rs1_data_valid = rob_rf_rs1_output.valid & rob_rf_rs1_output.spec_valid;
assign dispatch_check_rs_status_if.rs2_data_valid = rob_rf_rs2_output.valid & rob_rf_rs2_output.spec_valid;
assign dispatch_check_rs_status_if.rs1_data_spec = rob_rf_rs1_output.spec_data;
assign dispatch_check_rs_status_if.rs2_data_spec = rob_rf_rs2_output.spec_data;

endmodule
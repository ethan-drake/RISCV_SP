// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            07/11/24
// File:			     issue_unit.sv
// Module name:	  taf_fifo
// Project Name:	  risc_v_sp
// Description:	  issue_unit

`include "utils.sv"

module issue_unit (
    input i_clk,
    input i_rst_n,
    input ready_int,
    input ready_mult,
    input ready_div,
    input ready_mem,
    input div_exec_busy,
    input cdb_bfm int_cdb_input,
    input cdb_bfm div_cdb_input,
    input cdb_bfm mult_cdb_input,
    input cdb_bfm mem_cdb_input,
    output issue_int,
    output issue_mult,
    output issue_div,
    output issue_mem,
    output cdb_bfm cdb_output
);



//Issue logic
//CDB_slot: CDB reservation registers

cdb_rsv_station cdb_rsv_station(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .ready_int(ready_int),
    .ready_mult(ready_mult),
    .ready_div(ready_div),
    .ready_mem(ready_mem),
    .div_exec_busy(div_exec_busy),
    .issue_int_done(issue_int),
    .issue_mult_done(issue_mult),
    .issue_div_done(issue_div),
    .issue_mem_done(issue_mem),
    .current_op()
);

//CDB control
//Enable signal propagation

wire int_cdb_ctrl = issue_int;
logic [5:0] signal_div;
wire div_cdb_ctrl = signal_div[0];

ffd_param #(.LENGTH(6)) sign_prop_div(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en(1'b1),
    .d({issue_div,signal_div[5:1]}),
    .q(signal_div)
);

logic [2:0] signal_mult;
wire mult_cdb_ctrl = signal_mult[0];

ffd_param #(.LENGTH(3)) sign_prop_mult(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en(1'b1),
    .d({issue_mult,signal_mult[2:1]}),
    .q(signal_mult)
);

wire mem_cdb_ctrl = issue_mem;

//MUX 4 to 1 one hot encoded
double_multiplexor_param_one_hot #(.LENGTH($bits(cdb_bfm))) cdb_mux(
    .i_a(int_cdb_input),
    .i_b(div_cdb_input),
    .i_c(mult_cdb_input),
    .i_d(mem_cdb_input),
    .i_selector({mem_cdb_ctrl,mult_cdb_ctrl,div_cdb_ctrl,int_cdb_ctrl}),
    .out(cdb_output)//output to CDB
);

endmodule
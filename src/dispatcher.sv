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
    output dispatch_rd_en,
    //CDB
    input [5:0] cdb_tag,
    input cdb_valid,
    input [31:0] cdb_data,
    input cdb_branch,
    input cdb_branch_taken,
    input tb_int_rd,
    input tb_ld_sw_rd,
    input tb_mult_rd,
    input tb_div_rd,
    output fetch_next_instr
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

//wire definition
wire [6:0] opcode;
wire [31:0] immediate;
wire [31:0] jmp_br_addr;
wire sel_rs1_cdb_mux,sel_rs2_cdb_mux;
wire [5:0] rs1_tag_rst,rs2_tag_rst;
wire [31:0] dispatch_rs1_data, dispatch_rs2_data;
wire [4:0] decode_rs1_addr,decode_rs2_addr, decode_rd_addr;
wire [2:0]decode_func3;
wire [6:0]decode_func7;
wire [5:0] tag_out_tf;
wire fifo_full_tf;
wire empty_fifo_tf;
wire rd_enable;
wire rs1valid_rst, rs2valid_rst;
wire [31:0] rs1data_rf, rs2data_rf;
wire [4:0] wen_regfile_rst;
wire jmp_detected,branch_detected;
wire br_stall_one_shot;
wire any_rsv_station_full;

//Decoder
risc_v_decoder decoder(
    .instr(i_fetch_instruction),
    .rs1(decode_rs1_addr),
    .rs2(decode_rs2_addr),
    .rd(decode_rd_addr),
    .opcode(opcode),
    .func3(decode_func3),
    .func7(decode_func7)
);

rst rst_module(
	.clk(i_clk), 
    //write port 0
    .wdata0_rst({1'b1,tag_out_tf}),
    .waddr0_rst(decode_rd_addr),
    .wen0_rst(rd_enable & (~any_rsv_station_full)),
    //write port 1
    .wdata1_rst(7'h0),
    .wen1_rst(),

    //read ports
    .rs1addr_rst(decode_rs1_addr),
    .rs1tag_rst(rs1_tag_rst),
    .rs1valid_rst(rs1valid_rst),
    
    .rs2addr_rst(decode_rs2_addr),
    .rs2tag_rst(rs2_tag_rst),
    .rs2valid_rst(rs2valid_rst),

    .cdb_valid(cdb_valid),
    .cdb_tag_rst(cdb_tag),
    .wen_regfile_rst(wen_regfile_rst)

);

rd_enabled rd_en_module(
    .rd(decode_rd_addr),
    .opcode(opcode),
    .rd_enable(rd_enable)
);

tag_fifo #(.DEPTH(64), .DATA_WIDTH(6)) tag_fifo_module(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .cdb_tag_data_tf(cdb_tag),
    .cdb_tag_valid_tf(cdb_valid),
    .rd_en_tf(rd_enable & (~any_rsv_station_full)),
    .flush(1'b0),
    .tag_out_tf(tag_out_tf),
    .fifo_full_tf(fifo_full_tf),
    .empty_fifo_tf(empty_fifo_tf)
);

assign sel_rs1_cdb_mux = ({rs1valid_rst,rs1_tag_rst}== {1'b1,cdb_tag});
assign sel_rs2_cdb_mux = ({rs2valid_rst,rs2_tag_rst}== {1'b1,cdb_tag});


multiplexor_param #(.LENGTH(32)) rs1_cdb_mux(
    .i_a(rs1data_rf),
    .i_b(cdb_data),
    .i_selector(sel_rs1_cdb_mux),
    .out(dispatch_rs1_data)
);

multiplexor_param #(.LENGTH(32)) rs2_cdb_mux(
    .i_a(rs2data_rf),
    .i_b(cdb_data),
    .i_selector(sel_rs2_cdb_mux),
    .out(dispatch_rs2_data)
);

reg_file rf_module(
	.clk(i_clk),
	//Write ports
	.wen_rf(),
	.write_data_rf(cdb_data),
	.write_addr_rf(wen_regfile_rst),
	.rs1addr_rf(decode_rs1_addr),
	.rs1data_rf(rs1data_rf),
	.rs2addr_rf(decode_rs2_addr),
	.rs2data_rf(rs2data_rf)
);


//Immediate generator
imm_gen immediate_generator(
	//inputs
	.i_instruction(i_fetch_instruction),
	//outputs
	.o_immediate(immediate)
);

//JMP & BRANCH ADDRESS CALCULATOR
br_jmp_addr_calc br_jmp_addr_calc(
    .pc(i_fetch_pc_plus_4),
    .opcode(opcode),
    .immediate(immediate),
    .jmp_br_addr(jmp_br_addr),
    .jmp_detected(jmp_detected),
    .branch_detected(branch_detected)
);

//one shot signal for branch stalling
//this is to allow just one branch operation to enter int fifo
ffd_one_shot branch_detected_one_shot(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_en(branch_detected),
    .d(1'b1),
    .hold(~exec_int_fifo_ctrl.queue_full),
    .release_one_shot(cdb_branch),
    .q(br_stall_one_shot)
);

//Dispatch packet generator

dispatch_gen dispatch_gen(
    .rs1(decode_rs1_addr),
    .rs2(decode_rs2_addr),
    .rs1_data(dispatch_rs1_data),
    .rs2_data(dispatch_rs2_data),
    .opcode(opcode),
    .func3(decode_func3),
    .func7(decode_func7),
    .immediate(immediate),
    .jmp_br_addr(jmp_br_addr),
    .rs1_tag({rs1valid_rst,rs1_tag_rst}),
    .rs2_tag({rs2valid_rst,rs2_tag_rst}),
    .rd_tag(tag_out_tf),
    .branch_stall(branch_detected),
    .br_stall_one_shot(br_stall_one_shot),
    .o_mult_fifo_data(exec_mult_fifo_data_in),
    .o_div_fifo_data(exec_div_fifo_data_in),
    .int_dispatch_en(exec_int_fifo_ctrl.dispatch_en),
    .mult_dispatch_en(exec_mult_fifo_ctrl.dispatch_en),
    .div_dispatch_en(exec_div_fifo_ctrl.dispatch_en),
    .ld_st_dispatch_en(exec_ld_st_fifo_ctrl.dispatch_en),
    .o_int_fifo_data(exec_int_fifo_data_in),
    .o_ld_st_fifo_data(exec_ld_st_fifo_data_in)
);


//Dispatch FIFOs
exec_rsv_station #(.DEPTH(4), .DATA_WIDTH($bits(int_fifo_data))) int_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_int_fifo_data_in),
    .w_en(exec_int_fifo_ctrl.dispatch_en),
    .rd_en(tb_int_rd),
    .flush(1'b0),//cdb_branch_taken),
    .data_out(exec_int_fifo_data_out),
    .o_full(exec_int_fifo_ctrl.queue_full),
    .empty(exec_int_fifo_ctrl.queue_empty),
    .cdb_tag(cdb_tag),
    .cdb_valid(cdb_valid),
    .cdb_data(cdb_data)
);

exec_rsv_station #(.DEPTH(4), .DATA_WIDTH($bits(ld_st_fifo_data))) ld_st_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_ld_st_fifo_data_in),
    .w_en(exec_ld_st_fifo_ctrl.dispatch_en),
    .rd_en(tb_ld_sw_rd),
    .flush(1'b0),//cdb_branch_taken),
    .data_out(exec_ld_st_fifo_data_out),
    .o_full(exec_ld_st_fifo_ctrl.queue_full),
    .empty(exec_ld_st_fifo_ctrl.queue_empty),
    .cdb_tag(cdb_tag),
    .cdb_valid(cdb_valid),
    .cdb_data(cdb_data)
);

exec_rsv_station #(.DEPTH(4), .DATA_WIDTH($bits(common_fifo_data))) mult_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_mult_fifo_data_in),
    .w_en(exec_mult_fifo_ctrl.dispatch_en),
    .rd_en(tb_mult_rd),
    .flush(1'b0),//cdb_branch_taken),
    .data_out(exec_mult_fifo_data_out),
    .o_full(exec_mult_fifo_ctrl.queue_full),
    .empty(exec_mult_fifo_ctrl.queue_empty),
    .cdb_tag(cdb_tag),
    .cdb_valid(cdb_valid),
    .cdb_data(cdb_data)
);

exec_rsv_station #(.DEPTH(4), .DATA_WIDTH($bits(common_fifo_data))) div_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_div_fifo_data_in),
    .w_en(exec_div_fifo_ctrl.dispatch_en),
    .rd_en(tb_div_rd),
    .flush(1'b0),//cdb_branch_taken),
    .data_out(exec_div_fifo_data_out),
    .o_full(exec_div_fifo_ctrl.queue_full),
    .empty(exec_div_fifo_ctrl.queue_empty),
    .cdb_tag(cdb_tag),
    .cdb_valid(cdb_valid),
    .cdb_data(cdb_data)
);

assign dispatch_jmp_valid = jmp_detected | cdb_branch_taken;//or branch cdb logic TBD
assign dispatch_jmp_br_addr = jmp_br_addr; //cdb branch logic TBD

assign any_rsv_station_full=(exec_int_fifo_ctrl.queue_full | exec_ld_st_fifo_ctrl.queue_full | exec_mult_fifo_ctrl.queue_full | exec_div_fifo_ctrl.queue_full);

//assign dispatch_rd_en = cdb_branch | (~branch_detected & (~(exec_int_fifo_ctrl.queue_full | exec_ld_st_fifo_ctrl.queue_full | exec_mult_fifo_ctrl.queue_full | exec_div_fifo_ctrl.queue_full)));

assign dispatch_rd_en = cdb_branch | (~branch_detected & (~any_rsv_station_full));

assign fetch_next_instr = (cdb_branch==1) && (cdb_branch_taken==0) ? 1:0;

endmodule
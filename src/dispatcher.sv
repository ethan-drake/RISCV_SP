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
    output flush,
    //CDB
    //input [5:0] cdb_tag,
    //input cdb_valid,
    //input [31:0] cdb_result,
    //input cdb_branch,
    //input cdb_branch_taken,
    input cdb_bfm cdb,
    //output fetch_next_instr,
    //output second_branch_instr,
    output int_issue_data exec_int_issue_data,
    output common_issue_data exec_mult_issue_data,
    output common_issue_data exec_div_issue_data,
    output mem_issue_data exec_mem_issue_data,
    input issue_done_int,
    input issue_done_mem,
    input issue_done_mult,
    input issue_done_div,
    output retire_store retire_store
);



//Dispatch integer structure instantiation
int_fifo_data exec_int_fifo_data_in;
//int_fifo_data exec_int_fifo_data_out;
common_fifo_ctrl exec_int_fifo_ctrl;
//Dispatch load/store structure instantiation
ld_st_fifo_data exec_ld_st_fifo_data_in;
//ld_st_fifo_data exec_ld_st_fifo_data_out;
common_fifo_ctrl exec_ld_st_fifo_ctrl;
//Dispatch Multiplication structure instantiation
common_fifo_data exec_mult_fifo_data_in;
//common_fifo_data exec_mult_fifo_data_out;
common_fifo_ctrl exec_mult_fifo_ctrl;
//Dispatch Division structure instantiation
common_fifo_data exec_div_fifo_data_in;
//common_fifo_data exec_div_fifo_data_out;
common_fifo_ctrl exec_div_fifo_ctrl;

//CDB_BFM structures
//cdb_bfm int_submit;
//cdb_bfm mult_submit;
//cdb_bfm div_submit;
//cdb_bfm mem_submit;

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
wire br_stall_one_shot_2;
wire [1:0] dispatch_instr_type;
//wire int_issue_rdy,mem_issue_rdy,mult_issue_rdy,div_issue_rdy;


//Decoder
risc_v_decoder decoder(
    .instr(i_fetch_instruction),
    .rs1(decode_rs1_addr),
    .rs2(decode_rs2_addr),
    .rd(decode_rd_addr),
    .opcode(opcode),
    .func3(decode_func3),
    .func7(decode_func7),
    .dispatch_instr_type(dispatch_instr_type)
);

//always @(*) begin
//    case (riscv_opcode'(opcode))
//        R_TYPE,
//        I_TYPE,
//        LOAD_TYPE,
//        J_TYPE,
//        JALR_TYPE,
//        LUI_TYPE,
//        AUIPC_TYPE:begin
//            dispatch_instr_type = NON_VALID_RD_TAG;
//        end
//        STORE_TYPE: begin
//            dispatch_instr_type = STORE;
//        end
//        BRANCH_TYPE: begin
//            dispatch_instr_type = BRANCH;
//        end
//        default:begin
//            dispatch_instr_type = NON_VALID_RD_TAG;
//        end 
//    endcase
//end

wire rob_fifo_full;



dispatch_w_to_rob #(.DTYPE(dispatch_type)) dispatch_w_to_rob_if();
//assign dispatch_w_to_rob_if.dispatch_en = 1'b1;//como ya no se hara hold nunca esta señal siempre es 1 dispatch_rd_en;//exec_int_fifo_ctrl.dispatch_en | exec_mult_fifo_ctrl.dispatch_en | exec_div_fifo_ctrl.dispatch_en | exec_ld_st_fifo_ctrl.dispatch_en;
assign dispatch_w_to_rob_if.dispatch_en = dispatch_rd_en; //only pauses when rsv stations are full or rob fifo is full
assign dispatch_w_to_rob_if.dispatch_rd_reg = decode_rd_addr;
assign dispatch_w_to_rob_if.dispatch_rd_tag = tag_out_tf;
assign dispatch_w_to_rob_if.dispatch_instr_type = dispatch_type'(dispatch_instr_type);
assign dispatch_w_to_rob_if.dispatch_pc = dispatch_jmp_br_addr;//i_fetch_pc_plus_4;

dispatch_check_rs_status dispatch_check_rs_status_if();
assign dispatch_check_rs_status_if.rs1_token = rs1_tag_rst;
assign dispatch_check_rs_status_if.rs2_token = rs2_tag_rst;

retire_bus retire_bus_if();

rob rob(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .issue_cdb(cdb),
    .rob_fifo_full(rob_fifo_full),
    .dispatch_w_to_rob_if(dispatch_w_to_rob_if),
    .dispatch_check_rs_status_if(dispatch_check_rs_status_if),
    .retire_bus_if(retire_bus_if)
);

rst rst_module(
	.clk(i_clk), 
    .flush(retire_bus_if.flush),
    //write port 0
    .wdata0_rst({1'b1,tag_out_tf}),
    .waddr0_rst(decode_rd_addr),
    .wen0_rst(rd_enable & (~any_rsv_station_full) & (~rob_fifo_full)),
    //write port 1
    //.wdata1_rst(7'h0),
    //.wen1_rst(),

    //read ports
    .rs1addr_rst(decode_rs1_addr),
    .rs1tag_rst(rs1_tag_rst),
    .rs1valid_rst(rs1valid_rst),
    
    .rs2addr_rst(decode_rs2_addr),
    .rs2tag_rst(rs2_tag_rst),
    .rs2valid_rst(rs2valid_rst),

    // remove in meantime until rob finishes .cdb_valid(cdb_valid),              //to be changed to ROB
    // remove in meantime until rob finishes .cdb_tag_rst(cdb_tag),              //to be changed to ROB
    //.cdb_valid(retire_bus_if.valid & retire_bus_if.spec_valid),
    .cdb_valid(retire_bus_if.valid && retire_bus_if.spec_valid && (dispatch_type'(retire_bus_if.retire_instr_type) == NON_VALID_RD_TAG)),
    .cdb_tag_rst(retire_bus_if.rd_tag)
    //.wen_regfile_rst(wen_regfile_rst)

);

rd_enabled rd_en_module(
    .rd(decode_rd_addr),
    .opcode(opcode),
    .rd_enable(rd_enable)
);

tag_fifo #(.DEPTH(64), .DATA_WIDTH(6)) tag_fifo_module(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    // remove in meantime until rob finishes design .cdb_tag_data_tf(cdb_tag),
    // remove in meantime until rob finishes design .cdb_tag_valid_tf(cdb_valid),
    .cdb_tag_data_tf(retire_bus_if.rd_tag),
    .cdb_tag_valid_tf(retire_bus_if.valid & retire_bus_if.spec_valid),
    //.rd_en_tf(rd_enable & (~any_rsv_station_full)),
    .rd_en_tf((~any_rsv_station_full) && (~rob_fifo_full) && (dispatch_type'(dispatch_instr_type) != JUMP)),//always enable for ROB to work
    .flush(retire_bus_if.flush),
    .tag_out_tf(tag_out_tf),
    .fifo_full_tf(fifo_full_tf),
    .empty_fifo_tf(empty_fifo_tf)
);



//now it will be updated by rob
reg_file rf_module(
	.clk(i_clk),
	//Write ports
	//.wen_rf(),
	//.write_data_rf(cdb.cdb_result),       //to be changed to ROB
	//.write_addr_rf(wen_regfile_rst),    //to be changed to ROB
    .wen_rf(retire_bus_if.valid && retire_bus_if.spec_valid && (dispatch_type'(retire_bus_if.retire_instr_type) == NON_VALID_RD_TAG)),
    .write_data_rf(retire_bus_if.data),
    .write_addr_rf(retire_bus_if.rd_reg),
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
//ffd_one_shot branch_detected_one_shot(
//    .i_clk(i_clk),
//    .i_rst_n(i_rst_n),
//    .i_en(branch_detected),
//    .d(1'b1),
//    .hold(~exec_int_fifo_ctrl.queue_full),
//    .release_one_shot(cdb.cdb_branch),
//    .q(br_stall_one_shot)
//);
//assign second_branch_instr = cdb.cdb_branch & ~cdb.cdb_branch_taken & branch_detected & fetch_next_instr;
//
//ffd_one_shot second_branch_detected_one_shot(
//    .i_clk(i_clk),
//    .i_rst_n(i_rst_n),
//    .i_en(second_branch_instr),
//    .d(1'b1),
//    .hold(~exec_int_fifo_ctrl.queue_full),
//    .release_one_shot(cdb.cdb_branch),
//    .q(br_stall_one_shot_2)
//);

dispatch_gen_str dispatch_gen_str_input;
assign dispatch_gen_str_input.rs1 = decode_rs1_addr;
assign dispatch_gen_str_input.rs2 = decode_rs2_addr;
assign dispatch_gen_str_input.rd = decode_rd_addr;

reg [31:0] rs1data_tmp;
reg rs1_valid_tmp;
reg [31:0] rs2data_tmp;
reg rs2_valid_tmp;

//checking results for rs1
always @(*) begin
    if(rs1valid_rst == 1'b0)begin
        //data is located in RF get that data and set valid flag to 1
        rs1data_tmp = rs1data_rf;
        rs1_valid_tmp = 1'b1;
    end
    else begin
        if(dispatch_check_rs_status_if.rs1_data_valid==1'b1)begin
            //data is located in spec_data get that data and set valid flag to 1
            rs1data_tmp = dispatch_check_rs_status_if.rs1_data_spec;
            rs1_valid_tmp = 1'b1;
        end
        else begin
            //data not yet published by cdb, doesnt matter the data cause valid flag will be 0
            rs1data_tmp = 0;
            rs1_valid_tmp = 1'b0;
        end
    end
end

//checking results for rs2
always @(*) begin
    //if operation is of kind immediate
    if(opcode == I_TYPE) begin
        rs2_valid_tmp = 1'b1;
    end
    else begin
        if(rs2valid_rst == 1'b0)begin
            //data is located in RF get that data and set valid flag to 1
            rs2data_tmp = rs2data_rf;
            rs2_valid_tmp = 1'b1;
        end
        else begin
            if(dispatch_check_rs_status_if.rs2_data_valid==1'b1)begin
                //data is located in spec_data get that data and set valid flag to 1
                rs2data_tmp = dispatch_check_rs_status_if.rs2_data_spec;
                rs2_valid_tmp = 1'b1;
            end
            else begin
                //data not yet published by cdb, doesnt matter the data cause valid flag will be 0
                rs2data_tmp = 0;
                rs2_valid_tmp = 1'b0;
            end
        end
    end
end

//assign dispatch_gen_str_input.rs1_data =  ;
//assign dispatch_gen_str_input.rs2_data = ;
//assign dispatch_gen_str_input.cdb_rs1_sel = ;
//assign dispatch_gen_str_input.cdb_rs2_sel = ;
assign dispatch_gen_str_input.opcode = opcode;
assign dispatch_gen_str_input.func3 = decode_func3; 
assign dispatch_gen_str_input.func7 = decode_func7; 
assign dispatch_gen_str_input.immediate = immediate; 
assign dispatch_gen_str_input.rs1_tag = rs1_tag_rst;
assign dispatch_gen_str_input.rs2_tag = rs2_tag_rst;
assign dispatch_gen_str_input.rd_tag = tag_out_tf;
assign dispatch_gen_str_input.jmp_br_addr = jmp_br_addr;


//HERE IT WILL BE THE FIRST BYPASS

assign sel_rs1_cdb_mux = (~rs1_valid_tmp) & ({rs1valid_rst,rs1_tag_rst}== {1'b1,cdb.cdb_tag}) && cdb.cdb_valid;
assign sel_rs2_cdb_mux = (~rs2_valid_tmp) & ({rs2valid_rst,rs2_tag_rst}== {1'b1,cdb.cdb_tag}) && cdb.cdb_valid;


multiplexor_param #(.LENGTH(32)) rs1_cdb_mux(
    .i_a(rs1data_tmp),
    .i_b(cdb.cdb_result),
    .i_selector(sel_rs1_cdb_mux),
    .out(dispatch_gen_str_input.rs1_data)
);

assign dispatch_gen_str_input.rs1_valid = rs1_valid_tmp | sel_rs1_cdb_mux;
assign dispatch_gen_str_input.rs2_valid = rs2_valid_tmp | sel_rs2_cdb_mux;

multiplexor_param #(.LENGTH(32)) rs2_cdb_mux(
    .i_a(rs2data_tmp),
    .i_b(cdb.cdb_result),
    .i_selector(sel_rs2_cdb_mux),
    .out(dispatch_gen_str_input.rs2_data)
);

//ffd to separate dispatch 1 and dispatch 2 stages
dispatch_gen_str bypass_2_result_if_any_output;
dispatch_gen_str bypass_2_result_if_any_output_floped;
dispatch_gen_str dispatch_gen_str_output;

ffd_dispatch_stage ffd_dispatch_gen(
	//inputs
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
    .flush(flush),
	//.i_en(1'b1),
	.i_en(dispatch_rd_en),
//    .i_en(dispatch_rd_en | post_feedback_sel),
//    .d(dispatch_gen_str_post_feedback),
    .d(dispatch_gen_str_input),
	//outputs
    .q(dispatch_gen_str_output)
);
// HERE WILL BE THE SECOND BYPASS

dispatch_gen_str dispatch_gen_str_bypass_2;
assign dispatch_gen_str_bypass_2.rs1 = dispatch_gen_str_output.rs1;
assign dispatch_gen_str_bypass_2.rs2 = dispatch_gen_str_output.rs2;
assign dispatch_gen_str_bypass_2.rd = dispatch_gen_str_output.rd;
assign dispatch_gen_str_bypass_2.opcode = dispatch_gen_str_output.opcode;
assign dispatch_gen_str_bypass_2.func3 = dispatch_gen_str_output.func3;
assign dispatch_gen_str_bypass_2.func7 = dispatch_gen_str_output.func7;
assign dispatch_gen_str_bypass_2.immediate = dispatch_gen_str_output.immediate;
assign dispatch_gen_str_bypass_2.rs1_tag = dispatch_gen_str_output.rs1_tag;
assign dispatch_gen_str_bypass_2.rs2_tag = dispatch_gen_str_output.rs2_tag;
assign dispatch_gen_str_bypass_2.rd_tag = dispatch_gen_str_output.rd_tag;
assign dispatch_gen_str_bypass_2.jmp_br_addr = dispatch_gen_str_output.jmp_br_addr;

assign sel_rs1_cdb_mux_bypass2 = (~dispatch_gen_str_output.rs1_valid) & (dispatch_gen_str_output.rs1_tag== cdb.cdb_tag) && cdb.cdb_valid;
assign sel_rs2_cdb_mux_bypass2 = (~dispatch_gen_str_output.rs2_valid) & (dispatch_gen_str_output.rs2_tag== cdb.cdb_tag) && cdb.cdb_valid;


multiplexor_param #(.LENGTH(32)) rs1_cdb_mux_bypass2(
    .i_a(dispatch_gen_str_output.rs1_data),
    .i_b(cdb.cdb_result),
    .i_selector(sel_rs1_cdb_mux_bypass2),
    .out(dispatch_gen_str_bypass_2.rs1_data)
);

assign dispatch_gen_str_bypass_2.rs1_valid = dispatch_gen_str_output.rs1_valid | sel_rs1_cdb_mux_bypass2;
assign dispatch_gen_str_bypass_2.rs2_valid = dispatch_gen_str_output.rs2_valid | sel_rs2_cdb_mux_bypass2;

multiplexor_param #(.LENGTH(32)) rs2_cdb_mux_bypass_2(
    .i_a(dispatch_gen_str_output.rs2_data),
    .i_b(cdb.cdb_result),
    .i_selector(sel_rs2_cdb_mux_bypass2),
    .out(dispatch_gen_str_bypass_2.rs2_data)
);

//assign dispatch_gen_str_bypass_2.rs2_data = sel_rs2_cdb_mux_bypass2 ? cdb.cdb_result : dispatch_gen_str_output.rs2_data;
wire bypass_2_result_if_any_sel;
assign bypass_2_result_if_any_sel = (dispatch_rd_en == 1'b0) && (sel_rs1_cdb_mux_bypass2 || sel_rs2_cdb_mux_bypass2);

multiplexor_param #(.LENGTH($bits(dispatch_gen_str))) mux_bypass_2_result_if_any(
    .i_a(180'h0),
    .i_b(dispatch_gen_str_bypass_2),
    .i_selector(bypass_2_result_if_any_sel),
    .out(bypass_2_result_if_any_output)
);



ffd_dispatch_stage ffd_dispatch_gen_bp2_if_any(
	//inputs
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
    .flush(flush),
	.i_en(1'b1),
	//.i_en(dispatch_rd_en),
//    .i_en(dispatch_rd_en | post_feedback_sel),
//    .d(dispatch_gen_str_post_feedback),
    .d(bypass_2_result_if_any_output),
	//outputs
    .q(bypass_2_result_if_any_output_floped)
);

////////////// BYPASS 2.1

dispatch_gen_str dispatch_gen_str_bypass_2_1;
assign dispatch_gen_str_bypass_2_1.rs1 = bypass_2_result_if_any_output_floped.rs1;
assign dispatch_gen_str_bypass_2_1.rs2 = bypass_2_result_if_any_output_floped.rs2;
assign dispatch_gen_str_bypass_2_1.rd = bypass_2_result_if_any_output_floped.rd;

assign dispatch_gen_str_bypass_2_1.opcode = bypass_2_result_if_any_output_floped.opcode;
assign dispatch_gen_str_bypass_2_1.func3 = bypass_2_result_if_any_output_floped.func3;
assign dispatch_gen_str_bypass_2_1.func7 = bypass_2_result_if_any_output_floped.func7;
assign dispatch_gen_str_bypass_2_1.immediate = bypass_2_result_if_any_output_floped.immediate;
assign dispatch_gen_str_bypass_2_1.rs1_tag = bypass_2_result_if_any_output_floped.rs1_tag;
assign dispatch_gen_str_bypass_2_1.rs2_tag = bypass_2_result_if_any_output_floped.rs2_tag;
assign dispatch_gen_str_bypass_2_1.rd_tag = bypass_2_result_if_any_output_floped.rd_tag;
assign dispatch_gen_str_bypass_2_1.jmp_br_addr = bypass_2_result_if_any_output_floped.jmp_br_addr;


wire sel_rs1_cdb_mux_bypass2_1;
wire sel_rs2_cdb_mux_bypass2_1;

assign sel_rs1_cdb_mux_bypass2_1 = (bypass_2_result_if_any_output_floped != 0) && (~bypass_2_result_if_any_output_floped.rs1_valid) && (bypass_2_result_if_any_output_floped.rs1_tag== cdb.cdb_tag) && cdb.cdb_valid;
assign sel_rs2_cdb_mux_bypass2_1 = (bypass_2_result_if_any_output_floped != 0) && (~bypass_2_result_if_any_output_floped.rs2_valid) && (bypass_2_result_if_any_output_floped.rs2_tag== cdb.cdb_tag) && cdb.cdb_valid;


multiplexor_param #(.LENGTH(32)) rs1_cdb_mux_bypass2_1(
    .i_a(bypass_2_result_if_any_output_floped.rs1_data),
    .i_b(cdb.cdb_result),
    .i_selector(sel_rs1_cdb_mux_bypass2_1),
    .out(dispatch_gen_str_bypass_2_1.rs1_data)
);

assign dispatch_gen_str_bypass_2_1.rs1_valid = bypass_2_result_if_any_output_floped.rs1_valid | sel_rs1_cdb_mux_bypass2_1;
assign dispatch_gen_str_bypass_2_1.rs2_valid = bypass_2_result_if_any_output_floped.rs2_valid | sel_rs2_cdb_mux_bypass2_1;

multiplexor_param #(.LENGTH(32)) rs2_cdb_mux_bypass_2_1(
    .i_a(bypass_2_result_if_any_output_floped.rs2_data),
    .i_b(cdb.cdb_result),
    .i_selector(sel_rs2_cdb_mux_bypass2_1),
    .out(dispatch_gen_str_bypass_2_1.rs2_data)
);
//////////////////////////////////////////////////

wire mux_bypass_2_1_output_sel;
assign mux_bypass_2_1_output_sel = (dispatch_gen_str_bypass_2_1 != 0) ? 1'b1 : 1'b0;
dispatch_gen_str final_dispatch_gen;

multiplexor_param #(.LENGTH($bits(dispatch_gen_str))) mux_bypass_2_1_output(
    .i_a(dispatch_gen_str_bypass_2),
    .i_b(dispatch_gen_str_bypass_2_1),
    .i_selector(mux_bypass_2_1_output_sel),
    .out(final_dispatch_gen)
);


//Dispatch packet generator
dispatch_gen dispatch_gen(
    //.rs1(decode_rs1_addr),
    //.rs2(decode_rs2_addr),
    //.rd(decode_rd_addr),
    //.rs1_data(dispatch_rs1_data),
    //.rs2_data(dispatch_rs2_data),
    //.cdb_rs1_sel(sel_rs1_cdb_mux),
    //.cdb_rs2_sel(sel_rs2_cdb_mux),
    //.opcode(opcode),
    //.func3(decode_func3),
    //.func7(decode_func7),
    //.immediate(immediate),
    //.jmp_br_addr(jmp_br_addr),
    //.rs1_tag({rs1valid_rst,rs1_tag_rst}),
    //.rs2_tag({rs2valid_rst,rs2_tag_rst}),
    //.rd_tag(tag_out_tf),
    //.branch_stall(branch_detected),
    //.br_stall_one_shot(br_stall_one_shot),
    //.br_stall_one_shot_2(br_stall_one_shot_2),
    //.i_dispatch_gen_str(dispatch_gen_str_bypass_2),
    //.i_dispatch_gen_str(dispatch_gen_str_post_feedback),
    .i_dispatch_gen_str(final_dispatch_gen),
    .o_mult_fifo_data(exec_mult_fifo_data_in),
    .o_div_fifo_data(exec_div_fifo_data_in),
    .int_dispatch_en(exec_int_fifo_ctrl.dispatch_en),
    .mult_dispatch_en(exec_mult_fifo_ctrl.dispatch_en),
    .div_dispatch_en(exec_div_fifo_ctrl.dispatch_en),
    .ld_st_dispatch_en(exec_ld_st_fifo_ctrl.dispatch_en),
    .o_int_fifo_data(exec_int_fifo_data_in),
    .o_ld_st_fifo_data(exec_ld_st_fifo_data_in)
);


//Receive information from ROB for roll-back process

//Dispatch FIFOs
exec_rsv_station_shift #(.DEPTH(4), .DATA_WIDTH($bits(int_fifo_data))) int_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_int_fifo_data_in),
    .w_en(exec_int_fifo_ctrl.dispatch_en),
    //.rd_en(tb_int_rd),
    .flush(retire_bus_if.flush),//1'b0),//cdb.cdb_branch_taken),
    .data_out(exec_int_issue_data.rsv_station_data),//exec_int_fifo_data_out),
    .o_full(exec_int_fifo_ctrl.queue_full),
    .empty(exec_int_fifo_ctrl.queue_empty),
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
    .w_en(exec_ld_st_fifo_ctrl.dispatch_en),
    .flush(retire_bus_if.flush),//1'b0),
    .cdb_tag(cdb.cdb_tag),
    .cdb_valid(cdb.cdb_valid),
    .cdb_data(cdb.cdb_result),
    .data_out(exec_mem_issue_data.rsv_station_data),//exec_ld_st_fifo_data_out),
    .o_full(exec_ld_st_fifo_ctrl.queue_full),
    .empty(exec_ld_st_fifo_ctrl.queue_empty),
    .issue_queue_rdy(exec_mem_issue_data.issue_rdy),//mem_issue_rdy)
    .issue_completed(issue_done_mem)
);

exec_rsv_station_shift #(.DEPTH(4), .DATA_WIDTH($bits(common_fifo_data))) mult_exec_fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(exec_mult_fifo_data_in),
    .w_en(exec_mult_fifo_ctrl.dispatch_en),
    //.rd_en(tb_mult_rd),
    .flush(retire_bus_if.flush),//1'b0),//cdb.cdb_branch_taken),
    .data_out(exec_mult_issue_data.rsv_station_data),//exec_mult_fifo_data_out),
    .o_full(exec_mult_fifo_ctrl.queue_full),
    .empty(exec_mult_fifo_ctrl.queue_empty),
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
    .w_en(exec_div_fifo_ctrl.dispatch_en),
    //.rd_en(tb_div_rd),
    .flush(retire_bus_if.flush),//1'b0),//cdb.cdb_branch_taken),
    .data_out(exec_div_issue_data.rsv_station_data),//exec_div_fifo_data_out),
    .o_full(exec_div_fifo_ctrl.queue_full),
    .empty(exec_div_fifo_ctrl.queue_empty),
    .cdb_tag(cdb.cdb_tag),
    .cdb_valid(cdb.cdb_valid),
    .cdb_data(cdb.cdb_result),
    .issue_queue_rdy(exec_div_issue_data.issue_rdy),//div_issue_rdy),
    .issue_completed(issue_done_div)
);



//assign dispatch_jmp_valid = jmp_detected | cdb.cdb_branch_taken;//or branch cdb logic TBD
//assign dispatch_jmp_valid = jmp_detected;
assign dispatch_jmp_valid = jmp_detected | retire_bus_if.flush;

//assign dispatch_jmp_br_addr = jmp_br_addr; //cdb branch logic TBD

//assign dispatch_jmp_br_addr = (retire_bus_if.flush) ? retire_bus_if.pc : (jmp_detected) ? jmp_br_addr : 0;
assign dispatch_jmp_br_addr = (retire_bus_if.flush == 1'b1) ? retire_bus_if.pc : jmp_br_addr;


assign any_rsv_station_full=(exec_int_fifo_ctrl.queue_full | exec_ld_st_fifo_ctrl.queue_full | exec_mult_fifo_ctrl.queue_full | exec_div_fifo_ctrl.queue_full);

//assign dispatch_rd_en = cdb.cdb_branch | (~branch_detected & (~(exec_int_fifo_ctrl.queue_full | exec_ld_st_fifo_ctrl.queue_full | exec_mult_fifo_ctrl.queue_full | exec_div_fifo_ctrl.queue_full)));
//assign fetch_next_instr = (cdb.cdb_branch==1) && (cdb.cdb_branch_taken==0) ? 1:0;

//assign dispatch_rd_en = (~(fetch_next_instr & branch_detected)) & (cdb.cdb_branch | (~branch_detected & (~any_rsv_station_full) & (~rob_fifo_full)));

assign dispatch_rd_en = (~any_rsv_station_full) & (~rob_fifo_full);

assign retire_store.store_ready = retire_bus_if.store_ready;
//assign retire_store.retire_rs2_data = retire_bus_if.store_data;
assign retire_store.mem_address = retire_bus_if.data;
assign flush = retire_bus_if.flush;

//always @(*) begin
//    if (cdb.cdb_branch==1'b1 && any_rsv_station_full==1'b0) begin
//        
//    end
//    else begin
//        dispatch_rd_en = 1'b1;
//    end
//end

//dispatch_sm dispatch_branch_sm(
//    .clk(i_clk),
//    .rst_n(i_rst_n),
//    .branch_detected(branch_detected),
//    .queue_full(any_rsv_station_full|rob_fifo_full),
//    .cdb_branch(cdb.cdb_branch),
//    .cdb_branch_taken(cdb.cdb_branch_taken),
//    .stall_br(),
//    .dispatch_next_instr()
//);

//cdb.cdb_branch & branch_detected //scenario were cdb branch is high at same time as branch detected | any_rsv_station_full


endmodule
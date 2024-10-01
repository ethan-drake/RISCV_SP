// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     ifq.sv
// Module name:	  ifq
// Project Name:	  mips_sp
// Description:	  ifq

module ifq(
    input i_clk,
    input i_rst_n,
    input [127:0] dout,
    input dout_valid,
    input rd_en,
    input [31:0] jmp_branch_address,
    input jmp_branch_valid,
    input fetch_next_instr,
    output [31:0] pc_in,
    output o_rd_en,
    output abort,
    output [31:0] pc_out,
    output [31:0] instr,
    output empty
);

wire is_full;
wire fifo_empty;
wire[31:0] pc_out_w;
wire[31:0] pc_out_w_d;
wire[31:0] pc_in_w;
wire[31:0] pc_in_w_d;
wire[127:0] fifo_out;
wire[4:0] rp,wp;
wire [31:0] ifq_mux_out;
wire [31:0] ifq_mux_bypass_out;

//BYPASS FOR BR NOT TAKEN SCENARIO
wire [31:0] normal_instr,ifq_mux_out_br_not_taken;
wire empty_rd_plus_1;

sync_fifo #(.DEPTH(4),.DATA_WIDTH(128)) fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(dout),
    .w_en(dout_valid),
    .rd_en(rd_en),
    .flush(jmp_branch_valid),
    .jmp_branch_address_b_3_2(jmp_branch_address[3:2]),
    .data_out(fifo_out),
    .o_rp(rp),
    .o_wp(wp),
    .o_full(is_full),
    .empty(fifo_empty),
    .empty_rd_plus_1(empty_rd_plus_1),
    .fetch_next_instr(fetch_next_instr)
);

ffd_param_pc #(.LENGTH(32)) ffd_pc_out(
	//inputs
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en(rd_en|jmp_branch_valid),
	.d(pc_out_w_d),
	.q(pc_out_w)
);

ffd_param_pc #(.LENGTH(32)) ffd_pc_in(
	//inputs
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en(~is_full),
	.d(pc_in_w_d+16),
	.q(pc_in_w)
);

double_multiplexor_param #(.LENGTH(32)) ifq_mux (
    .i_a(fifo_out[31:0]),
    .i_b(fifo_out[63:32]),
	.i_c(fifo_out[95:64]),
	.i_d(fifo_out[127:96]),
    .i_selector(rp[1:0]),
    .out(ifq_mux_out)
);

double_multiplexor_param #(.LENGTH(32)) ifq_mux_bypass (
    .i_a(dout[31:0]),
    .i_b(dout[63:32]),
	.i_c(dout[95:64]),
	.i_d(dout[127:96]),
    .i_selector(rp[1:0]),
    .out(ifq_mux_bypass_out)
);


multiplexor_param #(.LENGTH(32)) bypass_instr_mux (
    .i_a(ifq_mux_out),
    .i_b(ifq_mux_bypass_out),
    .i_selector(fifo_empty),
    .out(normal_instr)
);


double_multiplexor_param #(.LENGTH(32)) ifq_mux_br_not_taken (
    .i_a(fifo_out[31:0]),
    .i_b(fifo_out[63:32]),
	.i_c(fifo_out[95:64]),
	.i_d(fifo_out[127:96]),
    .i_selector(rp[1:0]+2'h1),
    .out(ifq_mux_out_br_not_taken)
);

multiplexor_param #(.LENGTH(32)) branch_not_taken_bypass (
    .i_a(normal_instr),
    .i_b(ifq_mux_out_br_not_taken),
    .i_selector(!empty_rd_plus_1 & fetch_next_instr),
    .out(instr)
);

assign pc_out = fetch_next_instr ? (pc_out_w+4) : pc_out_w;
assign pc_out_w_d = fetch_next_instr? (pc_out_w+8) : jmp_branch_valid ? jmp_branch_address : (pc_out_w+4);
assign pc_in_w_d = jmp_branch_valid ? jmp_branch_address : pc_in_w;
assign pc_in = jmp_branch_valid ? jmp_branch_address : pc_in_w;
assign o_rd_en = ~is_full;
assign abort = 1'b0;
assign empty = fifo_empty;
//assign is_full = (rp[3:2]==2'b00 && wp[3:2]==2'b11) ? 1'b1 : 1'b0;
//assign o_rd_en = (is_full) ? 1'b0 : 1'b1;

endmodule
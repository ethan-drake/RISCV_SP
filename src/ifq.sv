module ifq(
    input i_clk,
    input i_rst_n,
    input [127:0] dout,
    input dout_valid,
    input rd_en,
    input jmp_branch_address,
    input jmp_branch_valid,
    output [31:0] pc_in,
    output o_rd_en,
    output reg abort,
    output [31:0] pc_out,
    output [31:0] instr,
    output reg empty
);

reg is_full;
reg flush;
wire fifo_empty;
wire[31:0] pc_out_w;
wire[31:0] pc_in_w;
wire[127:0] fifo_out;
wire[4:0] rp;
wire [31:0] dispatcher_out;
wire [31:0] dispatcher_bypass_out;


sync_fifo #(.DEPTH(4),.DATA_WIDTH(128)) fifo(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .data_in(dout),
    .w_en(dout_valid),
    .rd_en(rd_en),
    .flush(flush),
    .data_out(fifo_out),
    .o_rp(rp),
    .full(),
    .empty(fifo_empty)
);

ffd_param_pc #(.LENGTH(32)) ffd_pc_out(
	//inputs
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en(rd_en),
	.d(pc_out_w+4),
	.q(pc_out_w)
);

ffd_param_pc #(.LENGTH(32)) ffd_pc_in(
	//inputs
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en(rd_en),
	.d(pc_in_w+16),
	.q(pc_in_w)
);

double_multiplexor_param #(.LENGTH(32)) dispatcher (
    .i_a(fifo_out[31:0]),
    .i_b(fifo_out[63:32]),
	.i_c(fifo_out[95:64]),
	.i_d(fifo_out[127:96]),
    .i_selector(rp[1:0]),
    .out(dispatcher_out)
);

double_multiplexor_param #(.LENGTH(32)) dispatcher_bypass (
    .i_a(dout[31:0]),
    .i_b(dout[63:32]),
	.i_c(dout[95:64]),
	.i_d(dout[127:96]),
    .i_selector(rp[1:0]),
    .out(dispatcher_bypass_out)
);


multiplexor_param #(.LENGTH(32)) bypass_instr_mux (
    .i_a(dispatcher_out),
    .i_b(dispatcher_bypass_out),
    .i_selector(fifo_empty),
    .out(instr)
);

assign pc_out = pc_out_w;
assign pc_in = pc_in_w;
assign o_rd_en = rd_en;
//assign is_full = (rp[3:2]==2'b00 && wp[3:2]==2'b11) ? 1'b1 : 1'b0;
//assign o_rd_en = (is_full) ? 1'b0 : 1'b1;

endmodule
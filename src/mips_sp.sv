module mips_sp(
	//Inputs - Platform
	input clk,
	input rst_n,
    input [31:0] pc_in
);

wire rd_en, abort, we, dout_valid;
wire [127:0] dout;

i_cache cache(
    .pc_in({pc_in[31:4],4'b0}),
	.rd_en(1'b1),
    .abort(1'b0),
	.we(1'b0),
    .clk(clk),
	//outputs
	.dout(dout),
	.dout_valid(dout_valid)
);

endmodule
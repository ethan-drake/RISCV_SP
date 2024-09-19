module sync_fifo #(parameter DEPTH=4, DATA_WIDTH=128)(
    input i_clk,
    input i_rst_n,
    input [DATA_WIDTH-1:0] data_in,
    input w_en,
    input rd_en,
    input flush,
    output [DATA_WIDTH-1:0] data_out,
    output full,
    output [4:0] o_rp,
    output empty
);

reg [DATA_WIDTH-1:0] fifo[DEPTH];
reg [4:0]wp;
reg [4:0]rp;
//writing
always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n | flush)begin
        wp = 4'b0;
    end
    //fifo write data
    else if(w_en & !full)begin
        fifo[wp[3:2]] = data_in;
        wp = wp+4;
    end
end

ffd_param_pc #(.LENGTH(5)) ffd_rp(
	//inputs
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en(rd_en),
	.d(rp+1),
	.q(rp)
);

    assign data_out = ((i_rst_n | !flush) & rd_en) ? fifo[rp[3:2]]:0;
    assign full = wp[4];
    assign empty = (wp[4:2] == rp[4:2]);
    assign o_rp = rp;

endmodule
module sync_fifo #(parameter DEPTH=4, DATA_WIDTH=128)(
    input i_clk,
    input i_rst_n,
    input [DATA_WIDTH-1:0] data_in,
    input w_en,
    input rd_en,
    input flush,
    output [DATA_WIDTH-1:0] data_out,
    output o_full,
    output [4:0] o_rp,
    output [4:0] o_wp,
    output empty
);

reg [DATA_WIDTH-1:0] fifo[DEPTH];
reg [4:0]wp;
reg [4:0]rp;
reg full;
reg overflow;
//writing
always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n | flush)begin
        wp = 5'b0;
        overflow = 0;
    end
    //fifo write data
    else if(w_en & !full)begin
        fifo[wp[3:2]] = data_in;
        wp = wp+4;
        if(wp[4])begin
            wp=0;
            overflow = 1;
        end
        else begin
            overflow=0;
        end
            
        
    end
end

always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n | flush)begin
        rp = 5'b0;
    end
    //fifo write data
    else if(rd_en)begin
        rp=rp+1;
        if(rp==5'h10)begin
            rp=5'b0;
        end
    end
end
/*
ffd_param_pc #(.LENGTH(5)) ffd_rp(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
	.i_en(rd_en),
	.d(rp+1),
	.q(rp)
);*/
always @(*) begin
    if(!i_rst_n)begin
        full = 1;
    end
    else begin
        full = (overflow && (rp[4:2]==0)) ? 1 : (wp[4:2]+1 == rp[4:2]) ? 1 : 0;
    end
end



    assign data_out = ((i_rst_n | !flush) & rd_en) ? fifo[rp[3:2]]:0;
    //assign full = ((wp[4]) && (rp[4:2]==0)) ? 1 : (wp[4:2]+1 == rp[4:2]) ? 1 : 0;
    assign empty = (wp == rp);
    assign o_rp = rp;
    assign o_wp = wp;
    assign o_full = full;

endmodule
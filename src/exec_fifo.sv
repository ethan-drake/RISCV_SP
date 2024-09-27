// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     exec_fifo.sv
// Module name:	  exec_fifo
// Project Name:	  mips_sp
// Description:	  execution fifo

module exec_fifo #(parameter DEPTH=4, DATA_WIDTH=128)(
    input i_clk,
    input i_rst_n,
    input [DATA_WIDTH-1:0] data_in,
    input w_en,
    input rd_en,
    input flush,
    output [DATA_WIDTH-1:0] data_out,
    output o_full,
    output empty
);
localparam POINTER_WIDTH = $clog2(DEPTH);
reg [DATA_WIDTH-1:0] fifo[DEPTH];
reg [POINTER_WIDTH:0]wp;
reg [POINTER_WIDTH:0]rp;
reg full;
reg overflow;
//writing
always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n | flush)begin
        wp = 0;
        overflow = 0;
        fifo[0] = 0;
        fifo[1] = 0;
        fifo[2] = 0;
        fifo[3] = 0;
    end
    //fifo write data
    else if(w_en & !full)begin
        fifo[wp[POINTER_WIDTH-1:0]] = data_in;
        wp = wp+1;
        if(wp[POINTER_WIDTH])begin
            wp=0;
            overflow = 1;
        end
        else begin
            overflow=0;
        end
    end
    if(flush)begin
        wp = 0;
        overflow = 0;
        fifo[0] = 0;
        fifo[1] = 0;
        fifo[2] = 0;
        fifo[3] = 0;
    end
    //fifo 

end

always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n)begin
        rp = 0;
    end
    //fifo write data
    else if(rd_en)begin
        rp=rp+1;
        if(rp[POINTER_WIDTH])begin
            rp=5'b0;
        end
    end

    if(flush)begin
        rp = 0;
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
    else if(flush)begin
        full = 0;
    end
    else begin
        full = (overflow && (rp[POINTER_WIDTH:0]==0)) ? 1 : (wp[POINTER_WIDTH:0]+1 == rp[POINTER_WIDTH:0]) ? 1 : 0;
    end
end



    assign data_out = ((i_rst_n | !flush) & rd_en) ? fifo[rp[POINTER_WIDTH-1:0]]:0;
    //assign full = ((wp[4]) && (rp[4:2]==0)) ? 1 : (wp[4:2]+1 == rp[4:2]) ? 1 : 0;
    assign empty = ({overflow,wp[POINTER_WIDTH-1:0]} == rp[POINTER_WIDTH:0]);
    assign o_full = full;

endmodule
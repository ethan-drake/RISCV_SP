// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            24/09/24
// File:			     tag_fifo.sv
// Module name:	  taf_fifo
// Project Name:	  risc_v_sp
// Description:	  tag_fifo

module tag_fifo #(parameter DEPTH=64, DATA_WIDTH=6)(
    input i_clk,
    input i_rst_n,
    input [DATA_WIDTH-1:0] cdb_tag_data_tf,
    input cdb_tag_valid_tf,
    input rd_en_tf,
    input flush,
    output [DATA_WIDTH-1:0] tag_out_tf,
    output fifo_full_tf,
    output empty_fifo_tf
);

reg [DATA_WIDTH-1:0] fifo[DEPTH];
reg [DEPTH:0]wp;
reg [DEPTH:0]rp;
reg full;
reg overflow;

//FIFO initialization
//Initialize registers
initial begin
	fifo[0] <= 32'd0;
	fifo[1] <= 32'd1;
	fifo[2] <= 32'd2;
	fifo[3] <= 32'd3;
	fifo[4] <= 32'd4;
	fifo[5] <= 32'd5;
	fifo[6] <= 32'd6;
	fifo[7] <= 32'd7;
	fifo[8] <= 32'd8;
	fifo[9] <= 32'd9;
	fifo[10] <= 32'd10;
	fifo[11] <= 32'd11;
	fifo[12] <= 32'd12;
	fifo[13] <= 32'd13;
	fifo[14] <= 32'd14;
	fifo[15] <= 32'd15;
	fifo[16] <= 32'd16;
	fifo[17] <= 32'd17;
	fifo[18] <= 32'd18;
	fifo[19] <= 32'd19;
	fifo[20] <= 32'd20;
	fifo[21] <= 32'd21;
	fifo[22] <= 32'd22;
	fifo[23] <= 32'd23;
	fifo[24] <= 32'd24;
	fifo[25] <= 32'd25;
	fifo[26] <= 32'd26;
	fifo[27] <= 32'd27;
	fifo[28] <= 32'd28;
	fifo[29] <= 32'd29;
	fifo[30] <= 32'd30;
	fifo[31] <= 32'd31;
    fifo[32] <= 32'd32;
	fifo[33] <= 32'd33;
	fifo[34] <= 32'd34;
	fifo[35] <= 32'd35;
	fifo[36] <= 32'd36;
	fifo[37] <= 32'd37;
	fifo[38] <= 32'd38;
	fifo[39] <= 32'd39;
	fifo[40] <= 32'd40;
	fifo[41] <= 32'd41;
	fifo[42] <= 32'd42;
	fifo[43] <= 32'd43;
	fifo[44] <= 32'd44;
	fifo[45] <= 32'd45;
	fifo[46] <= 32'd46;
	fifo[47] <= 32'd47;
	fifo[48] <= 32'd48;
	fifo[49] <= 32'd49;
	fifo[50] <= 32'd50;
	fifo[51] <= 32'd51;
	fifo[52] <= 32'd52;
	fifo[53] <= 32'd53;
	fifo[54] <= 32'd54;
	fifo[55] <= 32'd55;
	fifo[56] <= 32'd56;
	fifo[57] <= 32'd57;
	fifo[58] <= 32'd58;
	fifo[59] <= 32'd59;
	fifo[60] <= 32'd60;
	fifo[61] <= 32'd61;
	fifo[62] <= 32'd62;
	fifo[63] <= 32'd63;
end

//writing
always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n | flush)begin
        wp = 7'b1000000;
        overflow = 0;
    end
    //fifo write data
    else if(cdb_tag_valid_tf & !full)begin
        fifo[wp[DEPTH-1:0]] = cdb_tag_data_tf;
        wp = wp+1;
        if(wp[DEPTH])begin
            wp=0;
            overflow = 1;
        end
        else begin
            overflow=0;
        end
    end
    if(flush)begin
        wp = 7'b1000000;
        overflow = 0;
    end
    //fifo 

end

always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n)begin
        rp = 7'b0;
    end
    //fifo write data
    else if(rd_en_tf)begin
        rp=rp+1;
        if(rp==7'b1000000)begin
            rp=7'b0;
        end
    end

    if(flush)begin
        rp = 7'b0;
    end
end

always @(*) begin
    if(!i_rst_n)begin
        full = 1;
    end
    else if(flush)begin
        full = 0;
    end
    else begin
        full = (overflow && (rp==0)) ? 1 : (wp+1 == rp) ? 1 : 0;
    end
end



    assign tag_out_tf = ((i_rst_n | !flush) & rd_en_tf) ? fifo[rp[DEPTH-1:0]]:0;
    //assign full = ((wp[4]) && (rp[4:2]==0)) ? 1 : (wp[4:2]+1 == rp[4:2]) ? 1 : 0;
    assign empty_fifo_tf = ({overflow,wp[DEPTH-1:0]} == rp);
    assign fifo_full_tf = full;

endmodule
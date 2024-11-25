// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            07/11/24
// File:			     cdb_rsv_station.sv
// Module name:	  cdb_rsv_station
// Project Name:	  risc_v_sp
// Description:	  cdb_rsv_station

module cdb_rsv_station (
    input i_clk,
    input i_rst_n,
    input flush,
    input ready_int,
    input ready_mult,
    input ready_div,
    input ready_mem,
    input div_exec_busy,
    output reg issue_int_done,
    output reg issue_mem_done,
    output reg issue_mult_done,
    output reg issue_div_done,
    output reg current_op
);

wire [2:0] rsv_mult;
wire [2:0] rsv_div;

wire issue_oneclk_write = (ready_int|ready_mem) & ~rsv_mult[0];
wire issue_mult_write = ready_mult & ~rsv_div[0];
wire issue_div_write = ready_div & ~div_exec_busy;
wire rsv_station_0;


//LRU_bit 
// 1: int operation has priority (initial value)
// 0: mem operation has priority
logic lru = 1;

always @(*) begin
    if(ready_int & ready_mem)begin
        case (lru)
            1:begin
                issue_int_done = ready_int & ~rsv_mult[0];
                issue_mem_done = 0;
            end
            0:begin
                issue_int_done = 0;
                issue_mem_done = ready_mem & ~rsv_mult[0];
            end 
            default:begin
                issue_int_done = 0;
                issue_mem_done = 0;
            end 
        endcase
    end
    else begin
        issue_int_done = ready_int & ~rsv_mult[0];
        issue_mem_done = ready_mem & ~rsv_mult[0];
    end
end

//LRU value change logic
always @(posedge i_clk) begin
    if(!i_rst_n | flush)begin
		lru <= 1'b1; 
    end
	else if(lru == 1'b1 && issue_int_done == 1'b1)begin
        lru <= 1'b0;
    end
	else if(lru == 1'b0 && issue_mem_done == 1'b1)begin
        lru <= 1'b1;
    end
    else begin
        lru <= lru;
    end
end

//Location 0
ffd_param #(.LENGTH(1)) rsv_int_mem_reg(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
    .flush(flush),
	.i_en(1'b1),
    .d(rsv_mult[0]),
    .q(rsv_station_0)
);

assign current_op = issue_oneclk_write|rsv_station_0;

//Location 3,2,1
ffd_param #(.LENGTH(3)) rsv_mult_reg(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
    .flush(flush),
	.i_en(1'b1),
    .d({(issue_mult_write|rsv_div[0]),rsv_mult[2:1]}),
    .q(rsv_mult)
);
//Location 6,5,4
ffd_param #(.LENGTH(3)) rsv_div_reg(
	.i_clk(i_clk),
	.i_rst_n(i_rst_n),
    .flush(flush),
	.i_en(1'b1),
    .d({issue_div_write,rsv_div[2:1]}),
    .q(rsv_div)
);


assign issue_mult_done = issue_mult_write;
assign issue_div_done = issue_div_write;


endmodule
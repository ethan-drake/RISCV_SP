// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            25/11/24
// File:			     write_cache.sv
// Module name:	  write_cache
// Project Name:	  risc_v_sp
// Description:	  Memory write cache implementation
`include "utils.sv"
module write_cache #(parameter ADDR_WIDTH = 32) (
	input clk,
	input flush,
	//write ports to cache
	input wc_array wc_data,
	input [31:0] w_cache_address,
	input wc_en, 
	//read ports to cache
	input [31:0] rd_cache_address,
	output [31:0] rd,
	output hit,
	//update cache and ram ports when retired
	input store_ready,
	input [31:0] retired_address,
	output reg [31:0] ram_w_address,
	output reg [31:0] ram_w_data,
	output reg ram_w_en
);

// Declare the Write cache array
//reg [DATA_WIDTH-1:0] ram[0:(ADDR_WIDTH*ADDR_WIDTH)-1];
wc_array cache [0:(ADDR_WIDTH*ADDR_WIDTH)-1];
wc_array clean_value = {0,0,0};
integer i;
initial begin
	for(i=0;i<((ADDR_WIDTH*ADDR_WIDTH));i=i+1)
		//cache[i] <= 32'h0;
		cache[i] <= clean_value;
end 

always @(posedge clk)
begin
	//flush when incorrect branch prediction
	if (flush)begin
		for(i=0;i<((ADDR_WIDTH*ADDR_WIDTH));i=i+1)
			cache[i] <= clean_value;
	end
	else begin
		//Write
		if (wc_en)
			//ram[address] <= wd;
			cache[w_cache_address] <= wc_data;
	end
end
	
// Reading if memory read enable
//assign rd = ram[address];
assign rd = cache[rd_cache_address].data;
assign hit = cache[rd_cache_address].valid;

//updating RAM whenaddress is retired
always @(*) begin
	if(store_ready)begin
		ram_w_address = cache[retired_address].address;
		ram_w_data = cache[retired_address].data;
		ram_w_en = 1'b1;
	end
	else begin
		ram_w_address = 0;
		ram_w_data = 0;
		ram_w_en = 1'b0;
	end
end

endmodule
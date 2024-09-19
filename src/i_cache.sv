// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            17/09/23
// File:			     i_cache.v
// Module name:	  i_cache
// Project Name:	  mips_sp
// Description:	  i_cache

module i_cache #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 32) (
	//inputs
	input [(DATA_WIDTH-1):0] pc_in,
	input rd_en,abort,
	input we, clk,
	input i_rst_n,
	//outputs
	output reg [127:0] dout,
	output reg dout_valid
);

// Declare the RAM array
reg [127:0] cache_memory [0:63];
reg [DATA_WIDTH-1:0] map_Address;

//Initial data with program to execute
//initial begin
	// program
	//$readmemh("../asm/a_multiply.txt", cache_memory);
//end

always @(posedge clk)
begin
	//Write
	if (we)begin
		cache_memory[pc_in] <= {DATA_WIDTH{1'b0}};  //RO memory
	end
end

always @(*) begin
	if(rd_en & i_rst_n)begin
		map_Address = (pc_in + (~32'h400_000 + 1'b1)) >> 4'h4;
		dout = cache_memory[map_Address];
		dout_valid = 1'b1;
	end
	else begin
		map_Address = 0;
		dout=0;
		dout_valid=0;
	end
end


endmodule
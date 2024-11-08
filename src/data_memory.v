// Coder:           David Adrian Michel Torres, Eduardo Ethandrake Castillo Pulido
// Date:            16/03/23
// File:			     instr_data_memory.v
// Module name:	  instr_data_memory
// Project Name:	  risc_v_top
// Description:	  Memory that contains instructions to perform

module data_memory #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 32) (
	//inputs
	input [(DATA_WIDTH-1):0] wd, address,
	input we, re, clk,
	//outputs
	output [(DATA_WIDTH-1):0] rd
);

// Declare the RAM array
reg [DATA_WIDTH-1:0] ram[0:(ADDR_WIDTH*ADDR_WIDTH)-1];

integer i;
initial begin
	for(i=0;i<((ADDR_WIDTH*ADDR_WIDTH));i=i+1)
		ram[i] <= 32'h0;
end

always @(posedge clk)
begin
	//Write
	if (we)
		ram[address] <= wd;
end
	
// Reading if memory read enable
assign rd = ram[address];

endmodule
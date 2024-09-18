// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            08/27/2024
// File:			     mips_pipeline_TB.v
// Module name:	  mips_pipeline_TB
// Project Name:	  mips_top
// Description:	  TB to test mips implementation

 `timescale 1ns / 1ps
module ifq_tb();

reg clk, rst_n;
reg[31:0] pc_in;

mips_sp procesador (
	//Inputs - Platform
	.clk(clk),
	.rst_n(rst_n),
	.pc_in(pc_in)
);

initial begin
	clk = 0;
	rst_n = 1;
	#1 rst_n = 0;
	#1 rst_n = 1;
	pc_in = 32'h400_014;

end

always begin
	#1 clk = ~clk;
end

endmodule
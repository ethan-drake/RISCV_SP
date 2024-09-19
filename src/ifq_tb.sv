// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            08/27/2024
// File:			     mips_pipeline_TB.v
// Module name:	  mips_pipeline_TB
// Project Name:	  mips_top
// Description:	  TB to test mips implementation

 `timescale 1ns / 1ps
module ifq_tb();

reg clk, rst_n,rd_en;

mips_sp procesador (
	//Inputs - Platform
	.clk(clk),
	.rst_n(rst_n),
	.i_rd_en(rd_en)
);

initial begin
	fill_cache();
	clk = 0;
	rst_n = 1;
	clear_rd_enable();
	#1 rst_n = 0;
	#2 rst_n = 1;
	#0 set_rd_enable();
	
end

task fill_cache;
	procesador.cache.cache_memory[0] = 128'h00000004000000030000000200000001;
	procesador.cache.cache_memory[1] = 128'h00000008000000070000000600000005; 
	procesador.cache.cache_memory[2] = 128'h0000000c0000000b0000000a00000009; 
	procesador.cache.cache_memory[3] = 128'h000000100000000f0000000e0000000d;  
endtask

task set_rd_enable;
	rd_en = 1'b1;
endtask

task clear_rd_enable;
	rd_en = 1'b0;
endtask

always begin
	#1 clk = ~clk;
end

endmodule
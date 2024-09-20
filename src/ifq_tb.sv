// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            08/27/2024
// File:			     mips_pipeline_TB.v
// Module name:	  mips_pipeline_TB
// Project Name:	  mips_top
// Description:	  TB to test mips implementation

 `timescale 1ns / 1ps
module ifq_tb();

reg clk, rst_n,rd_en;
reg [31:0] jmp_branch_address;
reg jmp_branch_valid;

mips_sp procesador (
	//Inputs - Platform
	.clk(clk),
	.rst_n(rst_n),
	.i_rd_en(rd_en),
	.jmp_branch_address(jmp_branch_address),
    .jmp_branch_valid(jmp_branch_valid)
);

initial begin
	fill_cache();
	init_values();
	clear_rd_enable();
	reset_device();
	set_rd_enable();
	create_branch_scenario();
	create_branch_scenario();
end

task fill_cache;
	procesador.cache.cache_memory[0] = 128'h00000004000000030000000200000001;
	procesador.cache.cache_memory[1] = 128'h00000008000000070000000600000005; 
	procesador.cache.cache_memory[2] = 128'h0000000c0000000b0000000a00000009; 
	procesador.cache.cache_memory[3] = 128'h000000100000000f0000000e0000000d;  
	procesador.cache.cache_memory[4] = 128'h00000014000000130000001200000011;  
	procesador.cache.cache_memory[5] = 128'h00000018000000170000001600000015;  
	procesador.cache.cache_memory[6] = 128'h0000001c0000001b0000001a00000019;  
	procesador.cache.cache_memory[7] = 128'h000000200000001f0000001e0000001d;  
endtask

task init_values();
	clk = 0;
	rst_n = 1;
	jmp_branch_address = 0;
	jmp_branch_valid = 0;
endtask

task reset_device();
	#1 rst_n = 0;
	#2 rst_n = 1;
endtask

task set_rd_enable;
	#0 rd_en = 1'b1;
endtask

task clear_rd_enable;
	rd_en = 1'b0;
endtask

task create_branch_scenario;
	#($urandom_range(10,30) * 1ns);
	@(posedge clk)begin
		jmp_branch_address = 32'h400_000+($urandom_range(1,15)<<2);
		jmp_branch_valid = 1'b1;
	end
	@(posedge clk)begin
		jmp_branch_valid = 1'b0;
	end
endtask

always begin
	#1 clk = ~clk;
end

endmodule
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

riscv_sp_top procesador(
	//Inputs - Platform
	.clk(clk),
	.rst_n(rst_n),
    .i_rd_en(rd_en),
    //input [31:0] jmp_branch_address,
    //input jmp_branch_valid
    .cdb_tag(0),
    .cdb_valid(0),
    .cdb_data(0),
    .cdb_branch(0),
    .cdb_branch_taken(0)
);

initial begin
	fill_cache();
	init_values();
	clear_rd_enable();
	reset_device();
	set_rd_enable();
	//create_branch_scenario();
	//create_branch_scenario();
end

task fill_cache;
	procesador.cache.cache_memory[0] = 128'h007302b303c0039301e0031301400293;
	procesador.cache.cache_memory[1] = 128'h000000000062f4330072e3b306400513; 
	procesador.cache.cache_memory[2] = 128'h00000000000000000000000000000000; 
	procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;  
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
		jmp_branch_address = 32'h40_0000+($urandom_range(1,15)<<2);
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
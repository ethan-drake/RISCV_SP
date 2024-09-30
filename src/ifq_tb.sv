// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            08/27/2024
// File:			     mips_pipeline_TB.v
// Module name:	  mips_pipeline_TB
// Project Name:	  mips_top
// Description:	  TB to test mips implementation

`include "utils.sv"
 `timescale 1ns / 1ps
module ifq_tb();

reg clk, rst_n,rd_en;
reg [31:0] jmp_branch_address;
reg jmp_branch_valid;
reg tb_int_rd, tb_ld_sw_rd, tb_mult_rd, tb_div_rd;
reg [31:0] tb_int_result, tb_ld_sw_result, tb_mult_result, tb_div_result;
reg [5:0] cdb_tag;
reg cdb_valid;
riscv_sp_top procesador(
	//Inputs - Platform
	.clk(clk),
	.rst_n(rst_n),
    //.i_rd_en(rd_en),
    //input [31:0] jmp_branch_address,
    //input jmp_branch_valid
    .cdb_tag(cdb_tag),
    .cdb_valid(cdb_valid),
    .cdb_data(tb_int_result),
    .cdb_branch(0),
    .cdb_branch_taken(0),
	.tb_int_rd(tb_int_rd),
    .tb_ld_sw_rd(tb_ld_sw_rd),
    .tb_mult_rd(tb_mult_rd),
    .tb_div_rd(tb_div_rd)
);

initial begin
	fill_cache();
	init_values();
	//clear_rd_enable();
	reset_device();
	//set_rd_enable();
	//create_branch_scenario();
	//create_branch_scenario();
end
int_fifo_data int_exec_fifo_data;

always @(posedge clk) begin
	cdb_valid = 1'b0;
	tb_int_result = 0;
	cdb_tag = 6'h0;
	tb_int_rd=1'b0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	execute_int_fifo();
	execute_ld_sw_fifo();
	execute_mult_fifo();
	execute_div_fifo();
end

task execute_int_fifo;
	
	if((!procesador.dispatcher.int_exec_fifo.empty))begin
		tb_int_rd=1'b1;
		#0 int_exec_fifo_data = procesador.dispatcher.int_exec_fifo.data_out;
		$display("%h",int_exec_fifo_data);
		$display("rs1 data xx: %h",procesador.dispatcher.int_exec_fifo.data_out[83:52]);
		$display("rs1 data valid xx: %h",procesador.dispatcher.int_exec_fifo.data_out[51]);
		$display("rs1 tag xx: %h",procesador.dispatcher.int_exec_fifo.data_out[50:45]);
		$display("rs2 data xx: %h",procesador.dispatcher.int_exec_fifo.data_out[44:13]);
		$display("rs2 data valid xx: %h",procesador.dispatcher.int_exec_fifo.data_out[12]);
		$display("rs2 tag xx: %h",procesador.dispatcher.int_exec_fifo.data_out[11:6]);
		$display("rd tag xx: %h",procesador.dispatcher.int_exec_fifo.data_out[5:0]);

		if(int_exec_fifo_data.opcode!=0)begin
			$display("int operation detected, reading");
			$display("%h",int_exec_fifo_data);
			//$display("%b",int_exec_fifo_data.opcode);
			//$display("%h",int_exec_fifo_data.func3);
			//$display("%h",int_exec_fifo_data.func7);
			exec_alu(int_exec_fifo_data.opcode,int_exec_fifo_data.func3,int_exec_fifo_data.func7,int_exec_fifo_data.common_data.rs1_data,int_exec_fifo_data.common_data.rs2_data,tb_int_result);
			cdb_tag = int_exec_fifo_data.common_data.rd_tag;
			cdb_valid = 1'b1;
		end
		
	end
	else begin
		tb_int_rd = 1'b0;
		cdb_valid = 1'b0;
	end
endtask

task execute_ld_sw_fifo;
endtask

task execute_mult_fifo;
endtask

task execute_div_fifo;
endtask

task exec_alu(input logic[6:0] opcode,input logic[6:0] func3,input logic[6:0] func7,input logic[31:0] a,input logic[31:0] b,output logic[31:0] c);
	case (opcode)
		R_TYPE:begin
			case (func3)
				3'h0:begin
					if(func7==7'h20)begin
						$display("executing SUB with:");
						$display("rs1: %h",a);
						$display("rs2: %h",b);
						c=a-b;
						$display("RESULT: %h",c);
					end
					else if(func7==7'h00)begin
						$display("executing ADD with:");
						$display("rs1: %h",a);
						$display("rs2: %h",b);
						c=a+b;
						$display("RESULT: %h",c);
					end
					else begin
						c=0;
					end
				end
				3'h4:begin
					$display("executing XOR with:");
					$display("rs1: %h",a);
					$display("rs2: %h",b);
					c=a^b;
					$display("RESULT: %h",c);
				end
				3'h6:begin
					$display("executing OR with:");
					$display("rs1: %h",a);
					$display("rs2: %h",b);
					c=a|b;
					$display("RESULT: %h",c);
				end
				3'h7:begin
					$display("executing AND with:");
					$display("rs1: %h",a);
					$display("rs2: %h",b);
					c=a&b;
					$display("RESULT: %h",c);
				end
				default:begin
					c=0;
				end
			endcase
		end 
		I_TYPE:begin
			case (func3)
				3'h0:begin
					$display("executing ADDI with:");
					$display("rs1: %h",a);
					$display("rs2: %h",b);
					c=a+b;
					$display("RESULT: %h",c);
				end
				3'h4:begin
					$display("executing XORI with:");
					$display("rs1: %h",a);
					$display("rs2: %h",b);
					c=a^b;
					$display("RESULT: %h",c);
				end
				3'h6:begin
					$display("executing ORI with:");
					$display("rs1: %h",a);
					$display("rs2: %h",b);
					c=a|b;
					$display("RESULT: %h",c);
				end
				3'h7:begin
					$display("executing ANDI with:");
					$display("rs1: %h",a);
					$display("rs2: %h",b);
					c=a&b;
					$display("RESULT: %h",c);
				end
				default:begin
					c=0;
				end
			endcase
		end
		default:begin
			c=0;
		end
	endcase
endtask


task fill_cache;
	procesador.cache.cache_memory[0] = 128'hfe528ae303c0039301e0031301400293;
	procesador.cache.cache_memory[1] = 128'h0062f4330072e3b306400513007302b3; 
	procesador.cache.cache_memory[2] = 128'h0000000000000000000000000000006f; 
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
	tb_int_rd = 1'b0;
	tb_ld_sw_rd = 1'b0;
	tb_mult_rd = 1'b0;
	tb_div_rd = 1'b0;
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
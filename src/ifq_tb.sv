// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            08/27/2024
// File:			     mips_pipeline_TB.v
// Module name:	  mips_pipeline_TB
// Project Name:	  mips_top
// Description:	  TB to test mips implementation

`include "utils.sv"
 `timescale 1ns / 1ps
 //`define DEBUG
module ifq_tb();

reg clk, rst_n,rd_en;
reg [31:0] jmp_branch_address;
reg jmp_branch_valid;
reg tb_int_rd, tb_ld_sw_rd, tb_mult_rd, tb_div_rd;
reg [31:0] tb_int_result, tb_ld_sw_result, tb_mult_result, tb_div_result;
reg [31:0] bfm_result;
reg [5:0] cdb_tag;
reg cdb_valid, cdb_branch, cdb_branch_taken;

bit [31:0] memory [0:31];

riscv_sp_top procesador(
	//Inputs - Platform
	.clk(clk),
	.rst_n(rst_n),
    //.i_rd_en(rd_en),
    //input [31:0] jmp_branch_address,
    //input jmp_branch_valid
    .cdb_tag(cdb_tag),
    .cdb_valid(cdb_valid),
    .cdb_data(bfm_result),
    .cdb_branch(cdb_branch),
    .cdb_branch_taken(cdb_branch_taken),
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
common_fifo_data mult_fifo_data;
common_fifo_data div_fifo_data;
ld_st_fifo_data mem_fifo_data;

//2 bits para ver la info
int fifo_opts[$];
int current_opt;

reg branch_lock;

always @(posedge clk) begin
	if(procesador.dispatcher.exec_int_fifo_ctrl.dispatch_en)begin
		if(!branch_lock | procesador.dispatcher.fetch_next_instr)begin
			$display("Adding INSTR: %h",procesador.dispatcher.i_fetch_instruction);
			fifo_opts.push_back(0);
		end
		if(procesador.dispatcher.branch_detected)begin
			branch_lock=1;
		end
	end
	else if(procesador.dispatcher.exec_mult_fifo_ctrl.dispatch_en)begin
		$display("Adding INSTR: %h",procesador.dispatcher.i_fetch_instruction);
		fifo_opts.push_back(1);
	end
	else if(procesador.dispatcher.exec_div_fifo_ctrl.dispatch_en)begin
		$display("Adding INSTR: %h",procesador.dispatcher.i_fetch_instruction);
		fifo_opts.push_back(2);
	end
	else if(procesador.dispatcher.exec_ld_st_fifo_ctrl.dispatch_en)begin
		$display("Adding INSTR: %h",procesador.dispatcher.i_fetch_instruction);
		fifo_opts.push_back(3);
		
	end
	if(cdb_branch)begin
		branch_lock=0;
	end
	$display("FIFO: %p", fifo_opts);
end

always @(posedge clk) begin
	cdb_valid = 1'b0;
	tb_int_result = 0;
	cdb_tag = 6'h0;
	tb_int_rd=1'b0;
	cdb_branch=1'b0;
	cdb_branch_taken=1'b0;
	if(fifo_opts.size()>0)begin
	@(posedge clk);
	@(posedge clk);
	current_opt = fifo_opts.pop_front();
	case (current_opt)
		0: begin
			$display("ATTENDING INT FIFO");
			execute_int_fifo();
		end
		1: begin
			$display("ATTENDING MULT FIFO");
			execute_mult_fifo();
		end
		2: begin
			$display("ATTENDING DIV FIFO");
			execute_div_fifo();
		end
		3: begin
			$display("ATTENDING MEM FIFO");
			execute_ld_sw_fifo();
		end
		default: begin
		end
	endcase
	end
end

task get_inf_fifo_data();
	tb_int_rd=1'b1;
	#0 int_exec_fifo_data = procesador.dispatcher.int_exec_fifo.data_out;
	@(posedge clk);
	tb_int_rd=1'b0;
endtask

task get_mult_fifo_data();
	tb_mult_rd=1'b1;
	#0 mult_fifo_data = procesador.dispatcher.mult_exec_fifo.data_out;
	@(posedge clk);
	tb_mult_rd=1'b0;
endtask

task get_div_fifo_data();
	tb_div_rd=1'b1;
	#0 div_fifo_data = procesador.dispatcher.div_exec_fifo.data_out;
	@(posedge clk);
	tb_div_rd=1'b0;
endtask

task get_mem_fifo_data();
	tb_ld_sw_rd=1'b1;
	#0 mem_fifo_data = procesador.dispatcher.ld_st_exec_fifo.data_out;
	@(posedge clk);
	tb_ld_sw_rd=1'b0;
endtask

task set_cdb_valid;
	cdb_valid = 1'b1;
	@(posedge clk);
	cdb_valid = 1'b0;
endtask

task execute_int_fifo;
	
	if((!procesador.dispatcher.int_exec_fifo.empty))begin
		get_inf_fifo_data();
		`ifdef DEBUG
		$display("%h",int_exec_fifo_data);
		$display("rs1 data xx: %h",procesador.dispatcher.int_exec_fifo.data_out[83:52]);
		$display("rs1 data valid xx: %h",procesador.dispatcher.int_exec_fifo.data_out[51]);
		$display("rs1 tag xx: %h",procesador.dispatcher.int_exec_fifo.data_out[50:45]);
		$display("rs2 data xx: %h",procesador.dispatcher.int_exec_fifo.data_out[44:13]);
		$display("rs2 data valid xx: %h",procesador.dispatcher.int_exec_fifo.data_out[12]);
		$display("rs2 tag xx: %h",procesador.dispatcher.int_exec_fifo.data_out[11:6]);
		$display("rd tag xx: %h",procesador.dispatcher.int_exec_fifo.data_out[5:0]);
		`endif
		if(int_exec_fifo_data.opcode!=0)begin
			
			//$display("%h",int_exec_fifo_data);
			if(int_exec_fifo_data.opcode != BRANCH_TYPE)begin
				$display("int operation detected, reading");
				exec_alu(int_exec_fifo_data.opcode,int_exec_fifo_data.func3,int_exec_fifo_data.func7,int_exec_fifo_data.common_data.rs1_data,int_exec_fifo_data.common_data.rs2_data,bfm_result);
				cdb_tag = int_exec_fifo_data.common_data.rd_tag;
				set_cdb_valid();
			end
			else begin
				$display("branch operation detected, reading");
				calculate_branch(int_exec_fifo_data.func3,int_exec_fifo_data.common_data.rs1_data,int_exec_fifo_data.common_data.rs2_data,cdb_branch_taken);
				cdb_branch = 1'b1;
			end
		end
		
	end
	else begin
		tb_int_rd = 1'b0;
		//cdb_valid = 1'b0;
	end
endtask

task execute_ld_sw_fifo;
	if((!procesador.dispatcher.ld_st_exec_fifo.empty))begin
		get_mem_fifo_data();
		`ifdef DEBUG
		$display("%h",mem_fifo_data);
		$display("rs1 data xx: %h",procesador.dispatcher.ld_st_exec_fifo.data_out[83:52]);
		$display("rs1 data valid xx: %h",procesador.dispatcher.ld_st_exec_fifo.data_out[51]);
		$display("rs1 tag xx: %h",procesador.dispatcher.ld_st_exec_fifo.data_out[50:45]);
		$display("rs2 data xx: %h",procesador.dispatcher.ld_st_exec_fifo.data_out[44:13]);
		$display("rs2 data valid xx: %h",procesador.dispatcher.ld_st_exec_fifo.data_out[12]);
		$display("rs2 tag xx: %h",procesador.dispatcher.ld_st_exec_fifo.data_out[11:6]);
		$display("rd tag xx: %h",procesador.dispatcher.ld_st_exec_fifo.data_out[5:0]);
		`endif
		//0:LOAD
		//1:STORE
		if(mem_fifo_data.ld_st_opcode)begin
			$display("STORE operation detected");
			store_mem(mem_fifo_data.common_data.rs1_data,mem_fifo_data.common_data.rs2_data,mem_fifo_data.immediate);
		end
		else begin
			$display("LOAD operation detected");
			load_mem(mem_fifo_data.common_data.rs1_data,mem_fifo_data.immediate, bfm_result);
			cdb_tag = mem_fifo_data.common_data.rd_tag;
			set_cdb_valid();
		end
	end
	else begin
		tb_ld_sw_rd = 1'b0;
		//cdb_valid = 1'b0;
	end
endtask

task execute_mult_fifo;
	if((!procesador.dispatcher.mult_exec_fifo.empty))begin
		get_mult_fifo_data();
		`ifdef DEBUG
		$display("%h",mult_fifo_data);
		$display("rs1 data xx: %h",procesador.dispatcher.mult_exec_fifo.data_out[83:52]);
		$display("rs1 data valid xx: %h",procesador.dispatcher.mult_exec_fifo.data_out[51]);
		$display("rs1 tag xx: %h",procesador.dispatcher.mult_exec_fifo.data_out[50:45]);
		$display("rs2 data xx: %h",procesador.dispatcher.mult_exec_fifo.data_out[44:13]);
		$display("rs2 data valid xx: %h",procesador.dispatcher.mult_exec_fifo.data_out[12]);
		$display("rs2 tag xx: %h",procesador.dispatcher.mult_exec_fifo.data_out[11:6]);
		$display("rd tag xx: %h",procesador.dispatcher.mult_exec_fifo.data_out[5:0]);
		`endif
		if(mult_fifo_data!=0)begin
			$display("MULT operation detected, reading");
			execute_mult(mult_fifo_data.rs1_data, mult_fifo_data.rs2_data, bfm_result);
			cdb_tag = mult_fifo_data.rd_tag;
			set_cdb_valid();
		end
		
	end
	else begin
		tb_mult_rd = 1'b0;
		//cdb_valid = 1'b0;
	end
endtask

task execute_div_fifo;
	if((!procesador.dispatcher.div_exec_fifo.empty))begin
		get_div_fifo_data();
		`ifdef DEBUG
		$display("%h",div_fifo_data);
		$display("rs1 data xx: %h",procesador.dispatcher.div_exec_fifo.data_out[83:52]);
		$display("rs1 data valid xx: %h",procesador.dispatcher.div_exec_fifo.data_out[51]);
		$display("rs1 tag xx: %h",procesador.dispatcher.div_exec_fifo.data_out[50:45]);
		$display("rs2 data xx: %h",procesador.dispatcher.div_exec_fifo.data_out[44:13]);
		$display("rs2 data valid xx: %h",procesador.dispatcher.div_exec_fifo.data_out[12]);
		$display("rs2 tag xx: %h",procesador.dispatcher.div_exec_fifo.data_out[11:6]);
		$display("rd tag xx: %h",procesador.dispatcher.div_exec_fifo.data_out[5:0]);
		`endif
		$display("DIV operation detected, reading");
		execute_div(div_fifo_data.rs1_data, div_fifo_data.rs2_data, bfm_result);
		cdb_tag = div_fifo_data.rd_tag;
		set_cdb_valid();

		
	end
	else begin
		tb_div_rd = 1'b0;
		//cdb_valid = 1'b0;
	end
endtask

//0:LOAD
//1:STORE
task load_mem(input logic[31:0] rs1,input logic[31:0] immediate, output logic[31:0] data);
	$display("executing LOAD with:");
	$display("rs1: %h",rs1);
	$display("immediate: %h",immediate);
	data=memory[rs1+immediate-32'h10010000];
	$display("RESULT: %h",data);
	
endtask

task store_mem(input logic[31:0] rs1, input logic[31:0] rs2, input logic[31:0] immediate);
	$display("executing STORE with:");
	$display("rs1: %h",rs1);
	$display("rs2: %h",rs2);
	$display("immediate: %h",immediate);
	memory[rs1+immediate-32'h10010000]=rs2;
	$display("RESULT IN MEMORY[%h]: %h",rs1+immediate,memory[rs1+immediate-32'h10010000]);

endtask

task execute_mult(input logic [31:0] a, input logic [31:0] b, output logic [31:0] c);
	$display("executing MULT with:");
	$display("rs1: %h",a);
	$display("rs2: %h",b);
	c = a*b;
	$display("RESULT: %h",c);
endtask

task execute_div(input logic [31:0] a, input logic [31:0] b, output logic [31:0] c);
	$display("executing DIV with:");
	$display("rs1: %h",a);
	$display("rs2: %h",b);
	c = a/b;
	$display("RESULT: %h",c);
endtask

task calculate_branch(input logic[6:0] func3,input logic[31:0] a,input logic[31:0] b,output logic take_branch);
	case (func3)
		3'h0:begin
			$display("executing BEQ with:");
			$display("rs1: %h",a);
			$display("rs2: %h",b);
			take_branch=(a==b);
			$display("RESULT: %h",take_branch);
		end
		3'h1:begin
			$display("executing BNE with:");
			$display("rs1: %h",a);
			$display("rs2: %h",b);
			take_branch=(a!=b);
			$display("RESULT: %h",take_branch);
		end 
		default:begin
			take_branch=1'b0;
		end 
	endcase
	if(take_branch)begin
		$display("BRANCH TAKEN, FLUSHIIIIIING");
	end
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
		LUI_TYPE:begin
			$display("executing LUI with:");
			$display("imm: %h",b);
			c=b;
			$display("RESULT: %h",c);
		end
		default:begin
			c=0;
		end
	endcase
endtask


task fill_cache;
	procesador.cache.cache_memory[0] = 128'h01e003130058a223100108b700400293;
	procesador.cache.cache_memory[1] = 128'h00200513007302b3fe0286e300300393; 
	procesador.cache.cache_memory[2] = 128'h0063046302734633027285b30048a803; 
	procesador.cache.cache_memory[3] = 128'h000000000000006f0062f4330072e3b3;  
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
	current_opt=0;
	bfm_result=0;
	branch_lock=0;
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
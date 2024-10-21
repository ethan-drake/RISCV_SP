// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            08/27/2024
// File:			     mips_pipeline_TB.v
// Module name:	  mips_pipeline_TB
// Project Name:	  mips_top
// Description:	  TB to test mips implementation

`include "utils.sv"
 `timescale 1ns / 1ps
 //`define DEBUG
module risc_v_sp_tb();

reg clk, rst_n,rd_en;
reg [31:0] jmp_branch_address;
reg jmp_branch_valid;
reg tb_int_rd, tb_ld_sw_rd, tb_mult_rd, tb_div_rd;
reg [31:0] tb_int_result, tb_ld_sw_result, tb_mult_result, tb_div_result;
reg [31:0] bfm_result;
reg [5:0] cdb_tag;
reg cdb_valid, cdb_branch, cdb_branch_taken;

bit [31:0] memory [0:31];
bit [31:0] expected_rf [0:31];
bit [31:0] expected_mem [0:31];

`define TEST "TEST_1"

`ifdef PRUEBA
	$display("AQUI ESTOOOOOOOOOOOY");
`endif

initial begin
	string test_name;
	if($value$plusargs("TEST_NAME=%s",test_name))
	begin
		$display("TEST_NAME received");
	end
  	case (test_name)
		"TEST_1":begin
			$display("EXECUTING: FE first verification");
			init_test_1_cache();
			fill_up_expected_rf_test_1();
			fill_up_expected_mem_test_1();
		end 
		"TEST_2":begin
			$display("EXECUTING: FE second verification (full int rsv station)");
			init_test_2_cache();
			fill_up_expected_rf_test_2();
		end 
		"TEST_3":begin
			$display("EXECUTING: FE third verification (full mult rsv station)");
			init_test_3_cache();
			fill_up_expected_rf_test_3();
		end 
		"TEST_4":begin
			$display("EXECUTING: FE fourth verification (full div rsv station)");
			init_test_4_cache();
			fill_up_expected_rf_test_4();
		end 
		"TEST_5":begin
			$display("EXECUTING: FE fifth verification (full mem rsv station)");
			init_test_5_cache();
			fill_up_expected_rf_test_5();
			fill_up_expected_mem_test_5();
		end 
		"TEST_6":begin
			$display("EXECUTING: FE sixth verification (sw and lw with adds after)");
			init_test_6_cache();
			fill_up_expected_rf_test_6();
			fill_up_expected_mem_test_6();
		end 
		"TEST_7":begin
			$display("EXECUTING: FE seventh verification (Two stores led by two loads with toggling base address between them)");
			init_test_7_cache();
			fill_up_expected_rf_test_7();
			fill_up_expected_mem_test_7();
		end 
		default:begin
			$warning("NO MATCH TEST FOUND, executing first test by default");
			init_test_1_cache();
		end 
	endcase 

	init_values();
	reset_device();
end


riscv_sp_top procesador(
	//Inputs - Platform
	.clk(clk),
	.rst_n(rst_n),
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

int_fifo_data int_exec_fifo_data;
common_fifo_data mult_fifo_data;
common_fifo_data div_fifo_data;
ld_st_fifo_data mem_fifo_data;

//cdb output queue
cdb_bfm cdb_publish[$];
cdb_bfm current_publish;
cdb_bfm int_submit;
cdb_bfm mult_submit;
cdb_bfm div_submit;
cdb_bfm mem_submit;

//2 bits para ver la info
int fifo_opts[$];
int current_opt;

reg branch_lock;

always @(posedge clk) begin
	`ifdef DEBUG
	$display("READING FROM INT ISSUE TO CDB");
	`endif
	//execute_int_fifo();
	read_int_execution_unit();
end

always @(posedge clk)begin
	//two cycles of latency
	//@(posedge clk);
	//@(posedge clk);
	`ifdef DEBUG
	$display("READING FROM MULT ISSUE TO CDB");
	`endif
	//execute_mult_fifo();
	read_mult_execution_unit();
end

always @(posedge clk)begin
	//three cycles of latency
	//@(posedge clk);
	//@(posedge clk);
	//@(posedge clk);
	`ifdef DEBUG
	$display("READING FROM DIV ISSUE TO CDB");
	`endif
	//execute_div_fifo();
	read_div_execution_unit();
end

always @(posedge clk)begin
	//four cycles of latency
	//@(posedge clk);
	//@(posedge clk);
	//@(posedge clk);
	//@(posedge clk);
	`ifdef DEBUG
	$display("READING FROM MEM ISSUE TO CDB");
	`endif
	//execute_ld_sw_fifo();
	read_ld_sw_execution_unit();
end

always @(posedge clk) begin
	//handling for cdb queue from bfm
	cdb_tag=0;
	bfm_result=0;
	cdb_branch=0;
	cdb_branch_taken=0;
	cdb_valid=0;
	if(cdb_publish.size()>0)begin
		`ifdef DEBUG
		$display("CDB BRANCH PUBLISH RESULTS: %p", cdb_publish);
		`endif
		current_publish = cdb_publish.pop_front();
		cdb_tag = current_publish.cdb_tag;
		bfm_result = current_publish.cdb_result;
		cdb_branch = current_publish.cdb_branch;
		cdb_branch_taken = current_publish.cdb_branch_taken;
		if(current_publish.cdb_valid)begin
			set_cdb_valid();
		end
		
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

task read_int_execution_unit();
	if(procesador.dispatcher.exec_int_issue.issue_done)begin
		int_submit.cdb_result = procesador.dispatcher.exec_int_issue.o_int_submit.cdb_result;
		int_submit.cdb_tag = procesador.dispatcher.exec_int_issue.o_int_submit.cdb_tag;
		int_submit.cdb_valid = procesador.dispatcher.exec_int_issue.o_int_submit.cdb_valid;
		int_submit.cdb_branch = procesador.dispatcher.exec_int_issue.o_int_submit.cdb_branch;
		int_submit.cdb_branch_taken = procesador.dispatcher.exec_int_issue.o_int_submit.cdb_branch_taken;
		cdb_publish.push_back(int_submit);
	end
endtask

task read_mult_execution_unit();
	if(procesador.dispatcher.exec_mult_issue.issue_done)begin
		mult_submit.cdb_result = procesador.dispatcher.exec_mult_issue.o_mult_submit.cdb_result;
		mult_submit.cdb_tag = procesador.dispatcher.exec_mult_issue.o_mult_submit.cdb_tag;
		mult_submit.cdb_valid = procesador.dispatcher.exec_mult_issue.o_mult_submit.cdb_valid;
		mult_submit.cdb_branch = procesador.dispatcher.exec_mult_issue.o_mult_submit.cdb_branch;
		mult_submit.cdb_branch_taken = procesador.dispatcher.exec_mult_issue.o_mult_submit.cdb_branch_taken;
		cdb_publish.push_back(mult_submit);
	end
endtask

task read_ld_sw_execution_unit();
	if(procesador.dispatcher.exec_mem_issue.issue_done)begin
		mem_submit.cdb_result = procesador.dispatcher.exec_mem_issue.o_mem_submit.cdb_result;
		mem_submit.cdb_tag = procesador.dispatcher.exec_mem_issue.o_mem_submit.cdb_tag;
		mem_submit.cdb_valid = procesador.dispatcher.exec_mem_issue.o_mem_submit.cdb_valid;
		mem_submit.cdb_branch = procesador.dispatcher.exec_mem_issue.o_mem_submit.cdb_branch;
		mem_submit.cdb_branch_taken = procesador.dispatcher.exec_mem_issue.o_mem_submit.cdb_branch_taken;
		cdb_publish.push_back(mem_submit);
	end
endtask

task read_div_execution_unit();
	if(procesador.dispatcher.exec_div_issue.issue_done)begin
		div_submit.cdb_result = procesador.dispatcher.exec_div_issue.o_div_submit.cdb_result;
		div_submit.cdb_tag = procesador.dispatcher.exec_div_issue.o_div_submit.cdb_tag;
		div_submit.cdb_valid = procesador.dispatcher.exec_div_issue.o_div_submit.cdb_valid;
		div_submit.cdb_branch = procesador.dispatcher.exec_div_issue.o_div_submit.cdb_branch;
		div_submit.cdb_branch_taken = procesador.dispatcher.exec_div_issue.o_div_submit.cdb_branch_taken;
		cdb_publish.push_back(div_submit);
	end
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
		if(int_exec_fifo_data != 0)begin
			if(int_exec_fifo_data.opcode != BRANCH_TYPE)begin
				$display("int operation detected, reading");				
				exec_alu(int_exec_fifo_data.opcode,int_exec_fifo_data.func3,int_exec_fifo_data.func7,int_exec_fifo_data.common_data.rs1_data,int_exec_fifo_data.common_data.rs2_data,int_submit.cdb_result);
				int_submit.cdb_tag = int_exec_fifo_data.common_data.rd_tag;
				int_submit.cdb_valid = 1;
				int_submit.cdb_branch = 0;
				int_submit.cdb_branch_taken = 0;
				cdb_publish.push_back(int_submit);
			end
			else begin
				$display("branch operation detected, reading");
				calculate_branch(int_exec_fifo_data.func3,int_exec_fifo_data.common_data.rs1_data,int_exec_fifo_data.common_data.rs2_data,int_submit.cdb_branch_taken);
				int_submit.cdb_branch = 1'b1;
				int_submit.cdb_valid = 1'b0;
				int_submit.cdb_tag = 0;
				int_submit.cdb_result =0;
				cdb_publish.push_back(int_submit);
			end
		end
		
	end
	else begin
		tb_int_rd = 1'b0;
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
			load_mem(mem_fifo_data.common_data.rs1_data,mem_fifo_data.immediate, mem_submit.cdb_result);
			mem_submit.cdb_tag = mem_fifo_data.common_data.rd_tag;
			mem_submit.cdb_valid = 1;
			mem_submit.cdb_branch = 0;
			mem_submit.cdb_branch_taken = 0;
			cdb_publish.push_back(mem_submit);
		end
	end
	else begin
		tb_ld_sw_rd = 1'b0;
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
		//	if(cdb_valid)begin
		//			$error("CDB VALID IS ALREADY SET !!!");
		//	end
			execute_mult(mult_fifo_data.rs1_data, mult_fifo_data.rs2_data, mult_submit.cdb_result);
			mult_submit.cdb_tag = mult_fifo_data.rd_tag;
			mult_submit.cdb_valid = 1;
			mult_submit.cdb_branch = 0;
			mult_submit.cdb_branch_taken = 0;
			cdb_publish.push_back(mult_submit);
			//set_cdb_valid();
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
		//if(cdb_valid)begin
		//	$error("CDB VALID IS ALREADY SET !!!");
		//end
		execute_div(div_fifo_data.rs1_data, div_fifo_data.rs2_data, div_submit.cdb_result);
		div_submit.cdb_tag = div_fifo_data.rd_tag;
		div_submit.cdb_valid = 1;
		div_submit.cdb_branch = 0;
		div_submit.cdb_branch_taken = 0;
		cdb_publish.push_back(div_submit);
		//set_cdb_valid();

		
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

//-*************** FE first verification ***********************************//
task init_test_1_cache;
	procesador.cache.cache_memory[0] = 128'h01e003130058a223100108b700400293;
	procesador.cache.cache_memory[1] = 128'h00200513007302b3fe0286e300300393; 
	procesador.cache.cache_memory[2] = 128'h0063046302734633027285b30048a803; 
	procesador.cache.cache_memory[3] = 128'h000000000000006f0062f4330072e3b3;  
	procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;  
endtask

//-*************** FE second verification (full int rsv station) ***********************************//
task init_test_2_cache;
	procesador.cache.cache_memory[0] = 128'h01e60313027346330030039301e00313;
	procesador.cache.cache_memory[1] = 128'h01b603130056039301a6031300460393; 
	procesador.cache.cache_memory[2] = 128'h00000000000000000000006f00660393; 
	procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;  
endtask

//-*************** FE third verification (full mult rsv station) ***********************************//
task init_test_3_cache;
	procesador.cache.cache_memory[0] = 128'h027305b3027305330030039301e00313;
	procesador.cache.cache_memory[1] = 128'h0000006f02730733027306b302730633; 
	procesador.cache.cache_memory[2] = 128'h00000000000000000000000000000000; 
	procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;  
endtask

//-*************** FE fourth verification (full div rsv station) ***********************************//
task init_test_4_cache;
	procesador.cache.cache_memory[0] = 128'h027345b3027345330040039302c00313;
	procesador.cache.cache_memory[1] = 128'h0000006f02734733027346b302734633; 
	procesador.cache.cache_memory[2] = 128'h00000000000000000000000000000000; 
	procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;  
endtask

//-*************** FE fifth verification (full mem rsv station) ***********************************//
task init_test_5_cache;
	procesador.cache.cache_memory[0] = 128'h0063a2230063a023100103b702c00313;
	procesador.cache.cache_memory[1] = 128'h0000006f0063a8230063a6230063a423; 
	procesador.cache.cache_memory[2] = 128'h00000000000000000000000000000000; 
	procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;  
endtask

//-*************** FE sixth verification (sw and lw with adds after) ***********************************//
task init_test_6_cache;
	procesador.cache.cache_memory[0] = 128'h0003a5030063a023100103b702c00313;
	procesador.cache.cache_memory[1] = 128'h00a3073300a306b300a3063300a305b3; 
	procesador.cache.cache_memory[2] = 128'h00000000000000000000006f00a307b3; 
	procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;  
endtask


//-*************** FE seventh verification (Two stores led by two loads with toggling base address between them) ***********************************//
task init_test_7_cache;
	procesador.cache.cache_memory[0] = 128'h0062a02300438293100103b702c00313;
	procesador.cache.cache_memory[1] = 128'h0000006f0003a5830002a5030063a023; 
	procesador.cache.cache_memory[2] = 128'h00000000000000000000000000000000; 
	procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;  
	procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;  
endtask

task fill_up_expected_rf_test_1;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[5] =32'h21;
	expected_rf[6] =32'h1E;
	expected_rf[7] =32'h03;
	expected_rf[10] =32'h02;
	expected_rf[11] =32'h63;
	expected_rf[12] =32'h0A;
	expected_rf[16] =32'h04;
	expected_rf[17] = 32'h10010000;
endtask

task fill_up_expected_mem_test_1;
	expected_mem[1] =32'h04;
endtask

task fill_up_expected_rf_test_2;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[6] =32'h25;
	expected_rf[7] =32'h10;
	expected_rf[12] =32'h0A;
endtask

task fill_up_expected_rf_test_3;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[6] =32'h1E;
	expected_rf[7] =32'h03;
	expected_rf[10] =32'h5A;
	expected_rf[11] =32'h5A;
	expected_rf[12] =32'h5A;
	expected_rf[13] =32'h5A;
	expected_rf[14] =32'h5A;
endtask

task fill_up_expected_rf_test_4;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[6] =32'h2C;
	expected_rf[7] =32'h04;
	expected_rf[10] =32'h0B;
	expected_rf[11] =32'h0B;
	expected_rf[12] =32'h0B;
	expected_rf[13] =32'h0B;
	expected_rf[14] =32'h0B;
endtask

task fill_up_expected_rf_test_5;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[6] =32'h2C;
	expected_rf[7] =32'h10010000;
endtask

task fill_up_expected_mem_test_5;
	expected_mem[0] =32'h2C;
	expected_mem[1] =32'h2C;
	expected_mem[2] =32'h2C;
	expected_mem[3] =32'h2C;
	expected_mem[4] =32'h2C;
endtask

task fill_up_expected_rf_test_6;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[6] =32'h2C;
	expected_rf[7] =32'h10010000;
	expected_rf[10] =32'h2C;
	expected_rf[11] =32'h58;
	expected_rf[12] =32'h58;
	expected_rf[13] =32'h58;
	expected_rf[14] =32'h58;
	expected_rf[15] =32'h58;
endtask

task fill_up_expected_mem_test_6;
	expected_mem[0] =32'h2C;
endtask

task fill_up_expected_rf_test_7;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[5] =32'h10010004;
	expected_rf[6] =32'h2C;
	expected_rf[7] =32'h10010000;
	expected_rf[10] =32'h2C;
	expected_rf[11] =32'h2C;
endtask

task fill_up_expected_mem_test_7;
	expected_mem[0] =32'h2C;
	expected_mem[1] =32'h2C;
endtask
always @(procesador.dispatcher.i_fetch_instruction) begin
	 //validate_test_1_rf_and_mem;
	if(procesador.dispatcher.i_fetch_instruction == 32'h6f)begin
		//@(posedge clk);
		wait(procesador.dispatcher.int_exec_fifo.occupied == 0);
		wait(procesador.dispatcher.ld_st_exec_fifo.empty == 1);
		wait(procesador.dispatcher.mult_exec_fifo.occupied == 0);
		wait(procesador.dispatcher.div_exec_fifo.occupied == 0);
		wait(procesador.dispatcher.tag_fifo_module.fifo_full_tf==1);
		wait(cdb_publish.size() == 0);
		@(posedge clk)
		@(posedge clk)
//		@(posedge clk)
//		@(posedge clk)
		$display("CDB PUBLISH SIZE: %h", cdb_publish.size());
		check_values();
	end
end

task check_values();
	$display("***** Analyzing test results *****");
	for (int i = 0; i<32; i++) begin
		assert(procesador.dispatcher.rf_module.registers[i]==expected_rf[i]) else $error("Unexpected value in RF[%d], read: %h, expected: %h",i, procesador.dispatcher.rf_module.registers[i],expected_rf[i]);	
		assert(procesador.dispatcher.exec_mem_issue.memory_ram.ram[i]==expected_mem[i]) else $error("Unexpected value in MEM[%d], read: %h, expected: %h",i, procesador.dispatcher.exec_mem_issue.memory_ram.ram[i],expected_mem[i]);	
	end
	$display("################### TEST CHECK COMPLETED ####################");
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

	cdb_valid = 1'b0;
	tb_int_result = 0;
	cdb_tag = 6'h0;
	cdb_branch=1'b0;
	cdb_branch_taken=1'b0;
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
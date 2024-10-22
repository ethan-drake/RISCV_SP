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
reg [31:0] tb_int_result, tb_ld_sw_result, tb_mult_result, tb_div_result;
reg [31:0] bfm_result;
reg [5:0] cdb_tag;
reg cdb_valid, cdb_branch, cdb_branch_taken;

bit [31:0] memory [0:31];
bit [31:0] expected_rf [0:31];
bit [31:0] expected_mem [0:31];


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
		"TEST_8":begin
			$display("EXECUTING: FE eight verification (Try to leave old int instrs unexecuted)");
			init_test_8_cache();
			fill_up_expected_rf_test_8();
		end 
		"TEST_9":begin
			$display("EXECUTING: FE ninth verification (Update int rsv station and shift at same time)");
			init_test_9_cache();
			fill_up_expected_rf_test_9();
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
    .cdb_branch_taken(cdb_branch_taken)
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
	read_int_execution_unit();
end

always @(posedge clk)begin
	`ifdef DEBUG
	$display("READING FROM MULT ISSUE TO CDB");
	`endif
	read_mult_execution_unit();
end

always @(posedge clk)begin
	`ifdef DEBUG
	$display("READING FROM DIV ISSUE TO CDB");
	`endif
	read_div_execution_unit();
end

always @(posedge clk)begin
	`ifdef DEBUG
	$display("READING FROM MEM ISSUE TO CDB");
	`endif
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

task set_cdb_valid;
	cdb_valid = 1'b1;
	@(posedge clk);
	cdb_valid = 1'b0;
endtask

task read_int_execution_unit();
	if(procesador.issue.exec_int_issue.issue_done)begin
		int_submit.cdb_result = procesador.issue.exec_int_issue.o_int_submit.cdb_result;
		int_submit.cdb_tag = procesador.issue.exec_int_issue.o_int_submit.cdb_tag;
		int_submit.cdb_valid = procesador.issue.exec_int_issue.o_int_submit.cdb_valid;
		int_submit.cdb_branch = procesador.issue.exec_int_issue.o_int_submit.cdb_branch;
		int_submit.cdb_branch_taken = procesador.issue.exec_int_issue.o_int_submit.cdb_branch_taken;
		cdb_publish.push_back(int_submit);
	end
endtask

task read_mult_execution_unit();
	if(procesador.issue.exec_mult_issue.issue_done)begin
		mult_submit.cdb_result = procesador.issue.exec_mult_issue.o_mult_submit.cdb_result;
		mult_submit.cdb_tag = procesador.issue.exec_mult_issue.o_mult_submit.cdb_tag;
		mult_submit.cdb_valid = procesador.issue.exec_mult_issue.o_mult_submit.cdb_valid;
		mult_submit.cdb_branch = procesador.issue.exec_mult_issue.o_mult_submit.cdb_branch;
		mult_submit.cdb_branch_taken = procesador.issue.exec_mult_issue.o_mult_submit.cdb_branch_taken;
		cdb_publish.push_back(mult_submit);
	end
endtask

task read_ld_sw_execution_unit();
	if(procesador.issue.exec_mem_issue.issue_done)begin
		mem_submit.cdb_result = procesador.issue.exec_mem_issue.o_mem_submit.cdb_result;
		mem_submit.cdb_tag = procesador.issue.exec_mem_issue.o_mem_submit.cdb_tag;
		mem_submit.cdb_valid = procesador.issue.exec_mem_issue.o_mem_submit.cdb_valid;
		mem_submit.cdb_branch = procesador.issue.exec_mem_issue.o_mem_submit.cdb_branch;
		mem_submit.cdb_branch_taken = procesador.issue.exec_mem_issue.o_mem_submit.cdb_branch_taken;
		cdb_publish.push_back(mem_submit);
	end
endtask

task read_div_execution_unit();
	if(procesador.issue.exec_div_issue.issue_done)begin
		div_submit.cdb_result = procesador.issue.exec_div_issue.o_div_submit.cdb_result;
		div_submit.cdb_tag = procesador.issue.exec_div_issue.o_div_submit.cdb_tag;
		div_submit.cdb_valid = procesador.issue.exec_div_issue.o_div_submit.cdb_valid;
		div_submit.cdb_branch = procesador.issue.exec_div_issue.o_div_submit.cdb_branch;
		div_submit.cdb_branch_taken = procesador.issue.exec_div_issue.o_div_submit.cdb_branch_taken;
		cdb_publish.push_back(div_submit);
	end
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

//-*************** FE eight verification (Try to leave old int instrs unexecuted) ***********************************//
task init_test_8_cache;
    procesador.cache.cache_memory[0] = 128'h01e60293027346330030039301e00313;
    procesador.cache.cache_memory[1] = 128'h005605930040051301a6049300400413;
    procesador.cache.cache_memory[2] = 128'h006607930040071301b6069300400613;
    procesador.cache.cache_memory[3] = 128'h00400993003009130020089300100813;
    procesador.cache.cache_memory[4] = 128'h0000006f00700b1300600a9300500a13;
    procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;
endtask

task init_test_9_cache;
    procesador.cache.cache_memory[0] = 128'h01e60293027346330030039301e00313;
    procesador.cache.cache_memory[1] = 128'h00400b930040051301a6049300400413;
    procesador.cache.cache_memory[2] = 128'h00100813006607930040071301bb8693;
    procesador.cache.cache_memory[3] = 128'h00500a13004009930030091300200893;
    procesador.cache.cache_memory[4] = 128'h000000000000006f00700b1300600a93;
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


task fill_up_expected_rf_test_8;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[5] =32'h28;
	expected_rf[6] =32'h1E;
	expected_rf[7] =32'h03;
	expected_rf[8] =32'h04;
	expected_rf[9] =32'h24;
	expected_rf[10] =32'h04;
	expected_rf[11] =32'h0F;
	expected_rf[12] =32'h04;
	expected_rf[13] =32'h1F;
	expected_rf[14] =32'h04;
	expected_rf[15] =32'h0A;
	expected_rf[16] =32'h01;
	expected_rf[17] =32'h02;
	expected_rf[18] =32'h03;
	expected_rf[19] =32'h04;
	expected_rf[20] =32'h05;
	expected_rf[21] =32'h06;
	expected_rf[22] =32'h07;
endtask

task fill_up_expected_rf_test_9;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[5] =32'h28;
	expected_rf[6] =32'h1E;
	expected_rf[7] =32'h03;
	expected_rf[8] =32'h04;
	expected_rf[9] =32'h24;
	expected_rf[10] =32'h04;
	//expected_rf[11] =32'h0F;
	expected_rf[12] =32'h0A;
	expected_rf[13] =32'h1F;
	expected_rf[14] =32'h04;
	expected_rf[15] =32'h10;
	expected_rf[16] =32'h01;
	expected_rf[17] =32'h02;
	expected_rf[18] =32'h03;
	expected_rf[19] =32'h04;
	expected_rf[20] =32'h05;
	expected_rf[21] =32'h06;
	expected_rf[22] =32'h07;
	expected_rf[23] =32'h04;
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
		assert(procesador.issue.exec_mem_issue.memory_ram.ram[i]==expected_mem[i]) else $error("Unexpected value in MEM[%d], read: %h, expected: %h",i, procesador.issue.exec_mem_issue.memory_ram.ram[i],expected_mem[i]);	
	end
	$display("################### TEST CHECK COMPLETED ####################");
endtask

task init_values();
	clk = 0;
	rst_n = 1;
	jmp_branch_address = 0;
	jmp_branch_valid = 0;
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

always begin
	#1 clk = ~clk;
end

endmodule
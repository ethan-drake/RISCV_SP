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

reg clk, rst_n;//,rd_en;
//reg [31:0] jmp_branch_address;
//reg jmp_branch_valid;
//reg [31:0] tb_int_result, tb_ld_sw_result, tb_mult_result, tb_div_result;
//reg [31:0] bfm_result;
//reg [5:0] cdb_tag;
//reg cdb_valid, cdb_branch, cdb_branch_taken;

bit [31:0] memory [0:31];
bit [31:0] expected_rf [0:31];
bit [31:0] expected_mem [0:31];
int simulation_errors=0;
bit [7:0] pc_instr_lookup;
reg [31:0] expected_rom_memory [0:(32*32)-1];
bit sort_test=0;

//Initial data with program to execute
//initial begin
//	// program
//	$readmemh("../asm/sort_final_project.txt", expected_rom_memory);
//end

initial begin
	string test_name;
	if($value$plusargs("TEST_NAME=%s",test_name))
	begin
		$display("TEST_NAME received");
	end
  	case (test_name)
		"TEST_1":begin
			$display("EXECUTING:  first verification");
			$readmemh("../asm/riscv_dispatch.txt", expected_rom_memory);
			init_test_1_cache();
			init_test_11_RAM();
			fill_up_expected_rf_test_1();
			fill_up_expected_mem_test_1();
		end 
		"TEST_2":begin
			$display("EXECUTING:  second verification (full int rsv station)");
			$readmemh("../asm/int_full_fifo.txt", expected_rom_memory);
			init_test_2_cache();
			fill_up_expected_rf_test_2();
		end 
		"TEST_3":begin
			$display("EXECUTING:  third verification (full mult rsv station)");
			$readmemh("../asm/mult_full_fifo.txt", expected_rom_memory);
			init_test_3_cache();
			fill_up_expected_rf_test_3();
		end 
		"TEST_4":begin
			$display("EXECUTING:  fourth verification (full div rsv station)");
			$readmemh("../asm/div_full_fifo.txt", expected_rom_memory);
			init_test_4_cache();
			fill_up_expected_rf_test_4();
		end 
		"TEST_5":begin
			$display("EXECUTING:  fifth verification (full mem rsv station)");
			$readmemh("../asm/mem_full_fifo.txt", expected_rom_memory);
			init_test_5_cache();
			fill_up_expected_rf_test_5();
			fill_up_expected_mem_test_5();
		end 
		"TEST_6":begin
			$display("EXECUTING:  sixth verification (sw and lw with adds after)");
			$readmemh("../asm/int_full_invalid.txt", expected_rom_memory);
			init_test_6_cache();
			fill_up_expected_rf_test_6();
			fill_up_expected_mem_test_6();
		end 
		"TEST_7":begin
			$display("EXECUTING:  seventh verification (Two stores led by two loads with toggling base address between them)");
			$readmemh("../asm/mem_ops.txt", expected_rom_memory);
			init_test_7_cache();
			fill_up_expected_rf_test_7();
			fill_up_expected_mem_test_7();
		end 
		"TEST_8":begin
			$display("EXECUTING:  eight verification (Try to leave old int instrs unexecuted)");
			$readmemh("../asm/test_8.txt", expected_rom_memory);
			init_test_8_cache();
			fill_up_expected_rf_test_8();
		end 
		"TEST_9":begin
			$display("EXECUTING:  ninth verification (Update int rsv station and shift at same time)");
			$readmemh("../asm/test_9.txt", expected_rom_memory);
			init_test_9_cache();
			fill_up_expected_rf_test_9();
		end 
		"TEST_10":begin
			$display("EXECUTING:  tenth verification (More that one ready at the same time for the  issue unit)");
			$readmemh("../asm/test_10.txt", expected_rom_memory);
			init_test_10_cache();
			fill_up_expected_rf_test_10();
		end 
		"TEST_11":begin
			$display("EXECUTING:  FINAL verification (FINAL SORT CODE)");
			$readmemh("../asm/sort_final_project.txt", expected_rom_memory);
			sort_test =1;
			init_test_11_RAM();
			init_test_11_cache();
			fill_up_expected_rf_test_11();
			fill_up_expected_mem_test_11();
		end 
		"TEST_12":begin
			$display("EXECUTING:  verification 12 (non taken branch followed by taken branch)");
			init_test_12_cache();
			
			//fill_up_expected_rf_test_11();
		end 
		default:begin
			$display("NO MATCH TEST FOUND, EXECUTING:  FINAL verification (FINAL SORT CODE) by default");
			$display("To try other tests please use +TEST_NAME=TEST_<1..11> when simulating");
			$readmemh("../asm/sort_final_project.txt", expected_rom_memory);
			sort_test =1;
			init_test_11_RAM();
			init_test_11_cache();
			fill_up_expected_rf_test_11();
			fill_up_expected_mem_test_11();
		end 
	endcase 
	init_values();
	reset_device();
	init_RAM(test_name);
end


riscv_sp_top procesador(
	//Inputs - Platform
	.clk(clk),
	.rst_n(rst_n)
    //.cdb_tag(cdb_tag),
    //.cdb_valid(cdb_valid),
    //.cdb_data(bfm_result),
    //.cdb_branch(cdb_branch),
    //.cdb_branch_taken(cdb_branch_taken)
);
/*
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
*/

//-***************  first verification ***********************************//
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

//-***************  second verification (full int rsv station) ***********************************//
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

//-***************  third verification (full mult rsv station) ***********************************//
task init_test_3_cache;
    procesador.cache.cache_memory[0] = 128'h027305b3027305330030039301e00313;
    procesador.cache.cache_memory[1] = 128'h027706b302768733027606b302758633;
    procesador.cache.cache_memory[2] = 128'h00000000000000000000006f02730733;
    procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;
endtask

//-***************  fourth verification (full div rsv station) ***********************************//
task init_test_4_cache;
    procesador.cache.cache_memory[0] = 128'h027545b3027345330040039302c00313;
    procesador.cache.cache_memory[1] = 128'h027346b30276c733027646b30275c633;
    procesador.cache.cache_memory[2] = 128'h00000000000000000000006f02734733;
    procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;
endtask

//-***************  fifth verification (full mem rsv station) ***********************************//
task init_test_5_cache;
    procesador.cache.cache_memory[0] = 128'h0063a2230063a023100103b702c00313;
    procesador.cache.cache_memory[1] = 128'h0263a2230263a0230063a6230063a423;
    procesador.cache.cache_memory[2] = 128'h000000000000006f0263a6230263a423;
    procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000; 
endtask

//-***************  sixth verification (sw and lw with adds after) ***********************************//
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


//-***************  seventh verification (Two stores led by two loads with toggling base address between them) ***********************************//
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

//-***************  eight verification (Try to leave old int instrs unexecuted) ***********************************//
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

task init_test_10_cache;
    procesador.cache.cache_memory[0] = 128'h01e60293027346330030039301e00313;
    procesador.cache.cache_memory[1] = 128'h0046051301a60493027346b3027605b3;
    procesador.cache.cache_memory[2] = 128'h00000000000000000000006f00460b93;
    procesador.cache.cache_memory[3] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;
endtask

task init_test_11_cache;
    procesador.cache.cache_memory[0] = 128'h00400213003001930020011300100093;
    procesador.cache.cache_memory[1] = 128'h00800413007003930060031300500293;
    procesador.cache.cache_memory[2] = 128'h00c0061300b0059300a0051300900493;
    procesador.cache.cache_memory[3] = 128'h0100081300f0079300e0071300d00693;
    procesador.cache.cache_memory[4] = 128'h01400a13013009930120091301100893;
    procesador.cache.cache_memory[5] = 128'h01800c1301700b9301600b1301500a93;
    procesador.cache.cache_memory[6] = 128'h01c00e1301b00d9301a00d1301900c93;
    procesador.cache.cache_memory[7] = 128'h0000003301f00f9301e00f1301d00e93;
    procesador.cache.cache_memory[8] = 128'h0031013303f28133100101b700020fb3;
    procesador.cache.cache_memory[9] = 128'h0022233301f18233100101b700000033;
    procesador.cache.cache_memory[10] = 128'h00d72333000227030001a68302030a63;
    procesador.cache.cache_memory[11] = 128'h01f181b300d2202300e1a02300030663;
    procesador.cache.cache_memory[12] = 128'h41f10133fc130ee30022233301f20233;
    procesador.cache.cache_memory[13] = 128'h01fd0db310010d3700000033fc1ff06f;
    procesador.cache.cache_memory[14] = 128'h000daf03000d2e8301ae0e3303f28e33;
    procesador.cache.cache_memory[15] = 128'h01fd0d3300000063000c846301df2cb3;
    procesador.cache.cache_memory[16] = 128'h00000033fe0000e301cd846301fd8db3;
    procesador.cache.cache_memory[17] = 128'h01f284b3000281330000003300000033;
    procesador.cache.cache_memory[18] = 128'h00118233000281b30000033300148533;
    procesador.cache.cache_memory[19] = 128'h0006ab83008686b31001043703f186b3;
    procesador.cache.cache_memory[20] = 128'h0087073303f20733000b8b3300068633;
    procesador.cache.cache_memory[21] = 128'h0007063300030663016c233300072c03;
    procesador.cache.cache_memory[22] = 128'hfc000ee300a2046300120233000c0b33;
    procesador.cache.cache_memory[23] = 128'h001181b3017620230166a02300000033;
    procesador.cache.cache_memory[24] = 128'h00000033fa0004e30091846300118233;
    procesador.cache.cache_memory[25] = 128'h03f28e3301fd0db303f28d3300000033;
    procesador.cache.cache_memory[26] = 128'h008d88330007ae83008d07b301ae0e33;
    procesador.cache.cache_memory[27] = 128'h00000063001c846301eeacb300082f03;
    procesador.cache.cache_memory[28] = 128'hfc000ce301cd846301fd8db301fd0d33;
    procesador.cache.cache_memory[29] = 128'h10010fb7000000330000003300000033;
    procesador.cache.cache_memory[30] = 128'h0000053300470f330090059300400213;
    procesador.cache.cache_memory[31] = 128'h000fa183004f8fb302b50263000fa103;
    procesador.cache.cache_memory[32] = 128'hfe9ff06f00128463001505330021a2b3;
    procesador.cache.cache_memory[33] = 128'h004f0833002f2023fe1ff06f00018133;
    procesador.cache.cache_memory[34] = 128'h000000000000006ffc6108e300082303;
endtask

task init_test_12_cache;
    procesador.cache.cache_memory[0] = 128'h01300993000004630030031300900293;
    procesador.cache.cache_memory[1] = 128'h0002806301600b1301500a9301400a13;
    procesador.cache.cache_memory[2] = 128'h0002806301900c9301800c1301700b93;
    procesador.cache.cache_memory[3] = 128'h000000000000000000000000fc0008e3;
    procesador.cache.cache_memory[4] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[5] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[6] = 128'h00000000000000000000000000000000;
    procesador.cache.cache_memory[7] = 128'h00000000000000000000000000000000;
endtask

task init_test_11_RAM;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[0] = 32'h4;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[1] = 32'h2;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[2] = 32'h5;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[3] = 32'h3;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[4] = 32'h1;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[5] = 32'h4;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[6] = 32'h2;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[7] = 32'h5;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[8] = 32'h3;
	procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[9] = 32'h1;
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
	expected_rf[12] =32'h10E;
	expected_rf[13] =32'h1C7A;
	expected_rf[14] =32'h5A;
endtask

task fill_up_expected_rf_test_4;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[6] =32'h2C;
	expected_rf[7] =32'h04;
	expected_rf[10] =32'h0B;
	expected_rf[11] =32'h02;
	expected_rf[12] =32'h00;
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
	expected_mem[8] =32'h2C;
	expected_mem[9] =32'h2C;
	expected_mem[10] =32'h2C;
	expected_mem[11] =32'h2C;
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

task fill_up_expected_rf_test_10;
	expected_rf[2] =32'h7fffefe4;
	expected_rf[5] =32'h28;
	expected_rf[6] =32'h1E;
	expected_rf[7] =32'h03;
	expected_rf[9] =32'h24;
	expected_rf[10] =32'h0E;
	expected_rf[11] =32'h1E;
	expected_rf[12] =32'h0A;
	expected_rf[13] =32'h0A;
	expected_rf[23] =32'h0E;
endtask

task fill_up_expected_rf_test_11;
	expected_rf[1] =32'h1;
	expected_rf[2] =32'h1;
	expected_rf[3] =32'h5;
	expected_rf[4] =32'h4;
	expected_rf[5] =32'h0;
	expected_rf[6] =32'h0;
	expected_rf[7] =32'h7;
	expected_rf[8] =32'h10010000;
	expected_rf[9] =32'h9;
	expected_rf[10] =32'h9;
	expected_rf[11] =32'h9;
	expected_rf[12] =32'h10010024;
	expected_rf[13] =32'h10010020;
	expected_rf[14] =32'h10010024;
	expected_rf[15] =32'h10010020;
	expected_rf[16] =32'h1001002c;
	expected_rf[17] =32'h11;
	expected_rf[18] =32'h12;
	expected_rf[19] =32'h13;
	expected_rf[20] =32'h14;
	expected_rf[21] =32'h15;
	expected_rf[22] =32'h4;
	expected_rf[23] =32'h5;
	expected_rf[24] =32'h4;
	expected_rf[25] =32'h1;
	expected_rf[26] =32'h24;
	expected_rf[27] =32'h28;
	expected_rf[28] =32'h28;
	expected_rf[29] =32'h4;
	expected_rf[30] =32'h10010028;
	expected_rf[31] =32'h10010024;
endtask

task fill_up_expected_mem_test_11;
	expected_mem[0] =32'h01;
	expected_mem[1] =32'h02;
	expected_mem[2] =32'h03;
	expected_mem[3] =32'h04;
	expected_mem[4] =32'h05;
	expected_mem[5] =32'h01;
	expected_mem[6] =32'h02;
	expected_mem[7] =32'h03;
	expected_mem[8] =32'h04;
	expected_mem[9] =32'h05;
	expected_mem[10] =32'h01;
endtask

always @(posedge clk, negedge rst_n) begin
	if(rst_n==1)begin		 
		pc_instr_lookup = procesador.dispatcher.i_fetch_pc_plus_4>>2;
		if(procesador.dispatcher.i_fetch_pc_plus_4 == 32'h400000 && procesador.dispatcher.i_fetch_instruction==0)begin
		end
		else begin
			//$display("Instr in PC[%h]:%h",procesador.dispatcher.i_fetch_pc_plus_4,procesador.dispatcher.i_fetch_instruction);
			
			assert(procesador.dispatcher.i_fetch_instruction == expected_rom_memory[pc_instr_lookup]) else begin
				$error("Unexpected Instr in PC[%h], read: %h, expected: %h",procesador.dispatcher.i_fetch_pc_plus_4, procesador.dispatcher.i_fetch_instruction, expected_rom_memory[pc_instr_lookup]);
				simulation_errors++;
			end	
		end		
	end
end

always @(procesador.dispatcher.i_fetch_instruction) begin
	 //wait for end of program to check values, last isntr is 0x6F (fin: j fin)
	if(procesador.dispatcher.i_fetch_instruction == 32'h6f)begin
		wait(procesador.rsv_stations.int_exec_fifo.occupied == 0);
		wait(procesador.rsv_stations.ld_st_exec_fifo.empty == 1);
		wait(procesador.rsv_stations.mult_exec_fifo.occupied == 0);
		wait(procesador.rsv_stations.div_exec_fifo.occupied == 0);
		wait(procesador.dispatcher.tag_fifo_module.fifo_full_tf==1);
		wait(procesador.dispatcher.rob.rob_fifo.empty==1);
		//wait(cdb_publish.size() == 0);
		if(procesador.dispatcher.i_fetch_instruction == 32'h6f)begin
			$display("Total run time: ", $time," ns");
			@(posedge clk)
			@(posedge clk)
			check_values();
		end
	end
end

task check_values();
	$display("***** Analyzing test results *****");
	
	for (int i = 0; i<32; i++) begin
		assert(procesador.dispatcher.rf_module.registers[i]==expected_rf[i]) else begin
			$error("Unexpected value in RF[%d], read: %h, expected: %h",i, procesador.dispatcher.rf_module.registers[i],expected_rf[i]);	
			simulation_errors++;
		end
		assert(procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[i]==expected_mem[i]) else begin
			$error("Unexpected value in MEM[%d], read: %h, expected: %h",i, procesador.issue_unit.functional_unit_group.exec_mem_issue.memory_ram.ram[i],expected_mem[i]);
			simulation_errors++;
		end	
	end
	$display("################### TEST CHECK COMPLETED ####################");
	if (simulation_errors == 0) begin
		$display("################### TEST PASSED ####################");
	end
	else if (simulation_errors > 0) begin
		$display("################### TEST FAILED ####################");
	end
endtask

task init_RAM(string test);
	if(sort_test == 1)begin
		init_test_11_RAM();
	end
endtask

task init_values();
	clk = 0;
	rst_n = 1;
endtask

task reset_device();
	#1 rst_n = 0;
	#2 rst_n = 1;
endtask

always begin
	#1 clk = ~clk;
end

endmodule
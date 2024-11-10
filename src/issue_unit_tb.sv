// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            07/11/24
// File:			     issue_unit_TB.v
// Module name:	  issue_unit_TB
// Project Name:	  issue unit
// Description:	  TB to test issue unit implementation

`include "utils.sv"
`timescale 1ns / 1ps

module issue_unit_tb();

reg clk, rst_n;
reg ready_int, ready_mult, ready_div, ready_mem, div_exec_busy;
reg issue_int, issue_mult, issue_div, issue_mem;
reg remove_rdy_when_done;
cdb_bfm cdb_output;

cdb_bfm int_cdb_input;
cdb_bfm div_cdb_input;
cdb_bfm mult_cdb_input;
cdb_bfm mem_cdb_input;

issue_unit issue_unit(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .ready_int(ready_int),
    .ready_mult(ready_mult),
    .ready_div(ready_div),
    .ready_mem(ready_mem),
    .div_exec_busy(div_exec_busy),
    .issue_int(issue_int),
    .issue_mult(issue_mult),
    .issue_div(issue_div),
    .issue_mem(issue_mem),
    .int_cdb_input(int_cdb_input),
    .div_cdb_input(div_cdb_input),
    .mult_cdb_input(mult_cdb_input),
    .mem_cdb_input(mem_cdb_input),
    .cdb_output(cdb_output)
);

initial begin
	string test_name;
	if($value$plusargs("TEST_NAME=%s",test_name))
	begin
		$display("TEST_NAME received");
	end
	
    init_values();
	reset_device();  	
    
    case (test_name)
		"TEST_1":begin
			$display("EXECUTING: FE first verification (each ready has its own cycle)");
			perform_test_1();
		end 
		"TEST_2":begin
			$display("EXECUTING: FE second verification (all readys at the same time)");
			perform_test_2();
		end 
        "TEST_3":begin
			$display("EXECUTING: FE third verification (each ready has its own cycle and stay up)");
			perform_test_3();
		end 
		"TEST_4":begin
			$display("EXECUTING: FE fourth verification (all readys at the same time and stay up)");
			perform_test_4();
		end 
		default:begin
			$warning("NO MATCH TEST FOUND, executing first test by default");
			perform_test_1();
		end 
	endcase 
end

always @(posedge clk) begin
    if (issue_div) begin
        for (int i = 0; i < 5; i++) begin
            div_exec_busy = 1;
            @(posedge clk);
        end
        div_exec_busy = 0;
    end
    else
        div_exec_busy = 0;
end

// remove rdy from int
always @(posedge clk) begin
    if(remove_rdy_when_done)begin
        if(issue_int)begin
            ready_int = 1'b0;
        end
    end
end

//remove rdy from mult
always @(posedge clk) begin
    if(remove_rdy_when_done)begin
        if(issue_mult)begin
            ready_mult = 1'b0;
        end
    end
end

//remove rdy from div
always @(posedge clk) begin
    if(remove_rdy_when_done)begin
        if(issue_div)begin
            ready_div = 1'b0;
        end
    end
end

//remove rsy from mem
always @(posedge clk) begin
    if(remove_rdy_when_done)begin
        if(issue_mem)begin
            ready_mem = 1'b0;
        end
    end
end

task perform_test_1();
    remove_rdy_when_done=1;
    @(posedge clk);
    ready_int = 1;
    @(posedge clk);
    ready_mult = 1;
    @(posedge clk);
    ready_div = 1;
    @(posedge clk);
    ready_mem = 1;

endtask

task perform_test_2();
    remove_rdy_when_done=1;
    @(posedge clk);
    ready_int = 1;
    ready_mult = 1;
    ready_div = 1;
    ready_mem = 1;

endtask

task perform_test_3();
    remove_rdy_when_done=0;
    @(posedge clk);
    ready_int = 1;
    @(posedge clk);
    ready_mult = 1;
    @(posedge clk);
    ready_div = 1;
    @(posedge clk);
    ready_mem = 1;

endtask

task perform_test_4();
    remove_rdy_when_done=0;
    @(posedge clk);
    ready_int = 1;
    ready_mult = 1;
    ready_div = 1;
    ready_mem = 1;

endtask

task init_values();
	clk = 0;
	rst_n = 1;
	ready_int = 1'b0;
    ready_mult = 1'b0;
    ready_div = 1'b0;
    ready_mem = 1'b0;
    div_exec_busy = 1'b0;
    int_cdb_input =  {6'hA, 1'b1, 32'h01, 1'b0, 1'b0, 1'b0};
    div_cdb_input =  {6'hB, 1'b1, 32'h02, 1'b0, 1'b0, 1'b0};
    mult_cdb_input = {6'hC, 1'b1, 32'h03, 1'b0, 1'b0, 1'b0};
    mem_cdb_input =  {6'hD, 1'b1, 32'h04, 1'b0, 1'b0, 1'b0};
endtask

task reset_device();
	#1 rst_n = 0;
	#2 rst_n = 1;
endtask

always begin
	#1 clk = ~clk;
end

endmodule
// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     mem_issue.sv
// Module name:	  mem issue module
// Project Name:	  risc_v_sp
// Description:	  mem issue module
`include "utils.sv"
module mem_issue #(parameter LATENCY = 4)(
    input logic clk,
    input logic rst_n,
    input logic issue_queue_rdy,
    input ld_st_fifo_data mem_exec_fifo_data,
    output cdb_bfm o_mem_submit,
    output reg issue_done
);

cdb_bfm [0:LATENCY-1] latency_submit;
cdb_bfm mem_submit;
wire [31:0] data_memory_2_slave, address_memory_2_slave, data_return_ram, data_return_uart;
wire we_memory_2_ram, re_memory_2_ram, we_memory_2_uart, re_memory_2_uart;

wire [31:0] mem_address = mem_exec_fifo_data.common_data.rs1_data+mem_exec_fifo_data.immediate;

//Memory map
master_memory_map #(.DATA_WIDTH(32), .ADDR_WIDTH(7)) memory_map (
	//CORES <--> Memory map
	.wd(mem_exec_fifo_data.common_data.rs2_data),
	.address(mem_address),
	.we(mem_exec_fifo_data.ld_st_opcode),
	.re(~mem_exec_fifo_data.ld_st_opcode),
	.clk(clk),
	.rd(mem_submit.cdb_result),
	//Memory_map <--> Slaves
	.map_Data(data_memory_2_slave),
	.map_Address(address_memory_2_slave),
	//Memory_map <--> RAM
	.HRData1(data_return_ram),
	.WSel_1(we_memory_2_ram),
	.HSel_1(re_memory_2_ram),
	//Memory_map <--> UART
	.HRData2(data_return_uart),
	.WSel_2(we_memory_2_uart),
	.HSel_2(re_memory_2_uart)
);

//Memory RAM
data_memory #(.DATA_WIDTH(32), .ADDR_WIDTH(7)) memory_ram (
	.wd(data_memory_2_slave),
	.address(address_memory_2_slave),
	.we(we_memory_2_ram),
	.re(re_memory_2_ram),
	.clk(clk),
	.rd(data_return_ram)
);

always @(*) begin
    if(issue_queue_rdy)begin
        //0:LOAD
		//1:STORE
       if(mem_exec_fifo_data.ld_st_opcode==1)begin
            //STORE OPERATION
			//$display("STORE operation detected");
			//store_mem(mem_fifo_data.common_data.rs1_data,mem_fifo_data.common_data.rs2_data,mem_fifo_data.immediate);
            //mem_submit.cdb_result = 0;
            mem_submit.cdb_tag = 0;
			mem_submit.cdb_valid = 0;
			mem_submit.cdb_branch = 0;
			mem_submit.cdb_branch_taken = 0;
            mem_submit.issue_done=0;
        end
		else begin
            //LOAD OPERATION
			//$display("LOAD operation detected");
			//load_mem(mem_fifo_data.common_data.rs1_data,mem_fifo_data.immediate, mem_submit.cdb_result);
			mem_submit.cdb_tag = mem_exec_fifo_data.common_data.rd_tag;
			mem_submit.cdb_valid = 1;
			mem_submit.cdb_branch = 0;
			mem_submit.cdb_branch_taken = 0;
            mem_submit.issue_done=1;
			//cdb_publish.push_back(mem_submit);
		end
    end
    else begin
        mem_submit.cdb_branch = 1'b0;
        mem_submit.cdb_valid = 1'b0;
        mem_submit.cdb_tag = 0;
        //mem_submit.cdb_result =0;
        mem_submit.issue_done=0;
    end
end

ffd_param #(.LENGTH($bits(cdb_bfm))) latency(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_en(1'b1),
    .d(mem_submit),
    .q(latency_submit[0])
);

//latency generator
genvar i;
generate
    for (i=1; i<LATENCY; i++) begin
        ffd_param #(.LENGTH($bits(cdb_bfm))) latency(
            .i_clk(clk),
            .i_rst_n(rst_n),
            .i_en(1'b1),
            .d(latency_submit[i-1]),
            .q(latency_submit[i])
        );
    end
endgenerate

assign o_mem_submit=latency_submit[LATENCY-1];
assign issue_done = latency_submit[LATENCY-1].issue_done;

endmodule
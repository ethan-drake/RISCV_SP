// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     mem_issue.sv
// Module name:	  mem issue module
// Project Name:	  risc_v_sp
// Description:	  mem issue module
`include "utils.sv"
module mem_exec_unit #(parameter LATENCY = 1)(
    input logic clk,
    input logic rst_n,
	input logic flush,
    input logic issue_granted,
	input retire_store retire_store,
    input ld_st_fifo_data mem_exec_fifo_data,
    output cdb_bfm o_mem_submit
    //output reg issue_done
);

cdb_bfm [0:LATENCY-1] latency_submit;
cdb_bfm mem_submit;
wire [31:0] data_memory_2_slave, address_memory_2_slave, data_return_ram, data_return_uart;
wire we_memory_2_ram, re_memory_2_ram, we_memory_2_uart, re_memory_2_uart;

wire [31:0] mem_address = mem_exec_fifo_data.common_data.rs1_data+mem_exec_fifo_data.immediate;

//wire [31:0] memory_addr = retire_store.store_ready ? retire_store.mem_address : mem_address;

wire [31:0] load_mem_temp;
wc_array wc_data;
assign wc_data.valid=mem_exec_fifo_data.ld_st_opcode;//1;
assign wc_data.address = mem_address;
assign wc_data.data = data_memory_2_slave;

wire hit;

//Memory map
master_memory_map #(.DATA_WIDTH(32), .ADDR_WIDTH(7)) memory_map (
	//CORES <--> Memory map
	.wd(mem_exec_fifo_data.common_data.rs2_data),
	//.wd(retire_store.retire_rs2_data),
	//.address(memory_addr),
	.address(mem_address),
	.we(mem_exec_fifo_data.ld_st_opcode),
	//.we(retire_store.store_ready),
	.re(~mem_exec_fifo_data.ld_st_opcode),
	.clk(clk),
	//.rd(mem_submit.cdb_result),
	.rd(load_mem_temp),
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
//data_memory #(.DATA_WIDTH(32), .ADDR_WIDTH(7)) memory_ram (
//	.wd(data_memory_2_slave),
//	.address(address_memory_2_slave),
//	.we(we_memory_2_ram),
//	.re(re_memory_2_ram),
//	.clk(clk),
//	.rd(data_return_ram)
//);
//Memory RAM
wire ram_w_en;
wire [31:0] ram_w_data;
wire [31:0] ram_r_data;
wire[31:0] ram_w_address;
wire[31:0] w_address; 
assign w_address = (ram_w_address + (~32'h10_010_000 + 1'b1)) >> 2'h2; //10_010_000

wire [31:0] retire_address;
assign retire_address = (retire_store.mem_address + (~32'h10_010_000 + 1'b1)) >> 2'h2; //10_010_000

data_memory #(.DATA_WIDTH(32), .ADDR_WIDTH(7)) memory_ram (
	.wd(ram_w_data),
	.w_address(w_address),
	.we(ram_w_en),
	.re(1'b1),
	.clk(clk),
	.r_address(address_memory_2_slave),
	.rd(ram_r_data)
);

write_cache #(.ADDR_WIDTH(7)) write_cache(
	.clk(clk),
	.flush(flush),
	//write ports to cache
	.wc_data(wc_data),
	.w_cache_address(address_memory_2_slave),
	.wc_en(we_memory_2_ram), 
	//read ports to cache
	.rd_cache_address(address_memory_2_slave),
	.rd(data_return_ram),
	.hit(hit),
	//update cache and ram ports when retired
	.store_ready(retire_store.store_ready),
	.retired_address(retire_address),
	.ram_w_address(ram_w_address),
	.ram_w_data(ram_w_data),
	.ram_w_en(ram_w_en)
);



always @(*) begin
    if(issue_granted)begin
        //0:LOAD
		//1:STORE
       if(mem_exec_fifo_data.ld_st_opcode==1)begin
            //STORE OPERATION
			//$display("STORE operation detected");
			//store_mem(mem_fifo_data.common_data.rs1_data,mem_fifo_data.common_data.rs2_data,mem_fifo_data.immediate);
            //mem_submit.cdb_result = 0;
			mem_submit.cdb_result = mem_exec_fifo_data.common_data.rs1_data+mem_exec_fifo_data.immediate;
            //THESE MODIFICATIONS NEED TO BE REMOVED WHEN APPLIED CACHE WA
			mem_submit.cdb_tag = mem_exec_fifo_data.common_data.rd_tag;
			//mem_submit.cdb_tag = 0;
//			mem_submit.cdb_valid = 0;
			mem_submit.cdb_valid = 1;
			mem_submit.cdb_branch = 0;
			mem_submit.cdb_branch_taken = 0;
			//mem_submit.store_data = mem_exec_fifo_data.common_data.rs2_data;
            //mem_submit.issue_done=0;
        end
		else begin
            //LOAD OPERATION
			//$display("LOAD operation detected");
			//load_mem(mem_fifo_data.common_data.rs1_data,mem_fifo_data.immediate, mem_submit.cdb_result);
			mem_submit.cdb_tag = mem_exec_fifo_data.common_data.rd_tag;
			mem_submit.cdb_valid = 1;
			//mem_submit.cdb_valid = 1 & mem_exec_fifo_data.common_data.wb_valid;
			mem_submit.cdb_branch = 0;
			mem_submit.cdb_branch_taken = 0;
			//mem_submit.store_data = 0;
            //mem_submit.issue_done=1;
			//cdb_publish.push_back(mem_submit);
			//REMOVE WHEN IMPLEMENTING CACHE SOLUTION
			//mem_submit.cdb_result = load_mem_temp;
			mem_submit.cdb_result = (hit == 1'b1) ? load_mem_temp : ram_r_data;
		end
    end
    else begin
        mem_submit.cdb_branch = 1'b0;
        mem_submit.cdb_valid = 1'b0;
        mem_submit.cdb_tag = 0;
		//mem_submit.store_data = 0;
        //mem_submit.cdb_result =0;
        //mem_submit.issue_done=0;
    end
end



//latency generator
genvar i;
generate
	if(LATENCY>0)begin
		ffd_param #(.LENGTH($bits(cdb_bfm))) latency(
			.i_clk(clk),
			.i_rst_n(rst_n),
			.i_en(1'b1),
			.flush(flush),
			.d(mem_submit),
			.q(latency_submit[0])
		);
		assign o_mem_submit=latency_submit[LATENCY-1];
	end
	else begin
		assign o_mem_submit = mem_submit;
	end
    for (i=1; i<LATENCY; i++) begin
        ffd_param #(.LENGTH($bits(cdb_bfm))) latency(
            .i_clk(clk),
            .i_rst_n(rst_n),
            .i_en(1'b1),
			.flush(flush),
            .d(latency_submit[i-1]),
            .q(latency_submit[i])
        );
    end
endgenerate

//assign issue_done = latency_submit[LATENCY-1].issue_done;

endmodule
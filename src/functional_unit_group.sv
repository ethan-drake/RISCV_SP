`include "utils.sv"
module functional_unit_group(
    input logic i_clk,
    input logic i_rst_n,
    input logic flush,
    input int_issue_data exec_int_issue_data,
    input common_issue_data exec_mult_issue_data,
    input common_issue_data exec_div_issue_data,
    input mem_issue_data exec_mem_issue_data,
    input logic int_issue_granted,
    input logic mult_issue_granted,
    input logic div_issue_granted,
    input logic mem_issue_granted,
	input retire_store retire_store,
    output cdb_bfm int_submit_data,
    output cdb_bfm mult_submit_data,
    output cdb_bfm div_submit_data,
    output cdb_bfm mem_submit_data,
    output logic div_exec_busy
);
    //Execution units
    int_exec_unit #(.LATENCY(0)) exec_int_issue(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .flush(flush),
        .issue_granted(int_issue_granted),
        .int_exec_fifo_data(exec_int_issue_data.rsv_station_data),
        .o_int_submit(int_submit_data)//.issue_cdb),
        //.issue_done(int_submit_data.issue_done)
    );

    mult_exec_unit #(.LATENCY(3)) exec_mult_issue(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .flush(flush),
        .issue_granted(mult_issue_granted),
        .mult_exec_fifo_data(exec_mult_issue_data.rsv_station_data),
        .o_mult_submit(mult_submit_data)//.issue_cdb),
        //.issue_done(mult_submit_data.issue_done)
    );

    div_exec_unit #(.LATENCY(6)) exec_div_issue(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .flush(flush),
        .issue_granted(div_issue_granted),
        .div_exec_fifo_data(exec_div_issue_data.rsv_station_data),
        .o_div_submit(div_submit_data),//.issue_cdb),
        .o_busy(div_exec_busy)
        //.issue_done(div_submit_data.issue_done) pudieramos cambiarlo a busy
    );


    mem_exec_unit #(.LATENCY(0)) exec_mem_issue(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .flush(flush),
        .issue_granted(mem_issue_granted),
        .mem_exec_fifo_data(exec_mem_issue_data.rsv_station_data),
        .o_mem_submit(mem_submit_data),//.issue_cdb),
        //.issue_done(mem_submit_data.issue_done)
        .retire_store(retire_store)
    );
endmodule
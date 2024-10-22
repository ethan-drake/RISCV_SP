`include "utils.sv"
module issue(
    input logic i_clk,
    input logic i_rst_n,
    input int_issue_data exec_int_issue_data,
    input common_issue_data exec_mult_issue_data,
    input common_issue_data exec_div_issue_data,
    input mem_issue_data exec_mem_issue_data,
    output cdb_submit_data int_submit_data,
    output cdb_submit_data mult_submit_data,
    output cdb_submit_data div_submit_data,
    output cdb_submit_data mem_submit_data
);
    //Execution units
    int_issue exec_int_issue(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .issue_queue_rdy(exec_int_issue_data.issue_rdy),
        .int_exec_fifo_data(exec_int_issue_data.rsv_station_data),
        .o_int_submit(int_submit_data.issue_cdb),
        .issue_done(int_submit_data.issue_done)
    );

    mult_issue exec_mult_issue(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .issue_queue_rdy(exec_mult_issue_data.issue_rdy),
        .mult_exec_fifo_data(exec_mult_issue_data.rsv_station_data),
        .o_mult_submit(mult_submit_data.issue_cdb),
        .issue_done(mult_submit_data.issue_done)
    );

    div_issue exec_div_issue(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .issue_queue_rdy(exec_div_issue_data.issue_rdy),
        .div_exec_fifo_data(exec_div_issue_data.rsv_station_data),
        .o_div_submit(div_submit_data.issue_cdb),
        .issue_done(div_submit_data.issue_done)
    );


    mem_issue exec_mem_issue(
        .clk(i_clk),
        .rst_n(i_rst_n),
        .issue_queue_rdy(exec_mem_issue_data.issue_rdy),
        .mem_exec_fifo_data(exec_mem_issue_data.rsv_station_data),
        .o_mem_submit(mem_submit_data.issue_cdb),
        .issue_done(mem_submit_data.issue_done)
    );
endmodule
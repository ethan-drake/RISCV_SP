// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     rst.v
// Module name:	  register status table
// Project Name:	  risc_v_sp
// Description:	  register status table
`include "utils.sv"
module int_exec_unit #(parameter LATENCY = 1)(
    input clk,
    input rst_n,
    input logic issue_granted,
    input int_fifo_data int_exec_fifo_data,
    output cdb_bfm o_int_submit
    //output reg issue_done
);

cdb_bfm [0:LATENCY-1] latency_submit;
cdb_bfm int_submit;

always @(*) begin
    if(issue_granted)begin
        if(int_exec_fifo_data.opcode != BRANCH_TYPE)begin
            case (int_exec_fifo_data.opcode)
            R_TYPE:begin
                case (int_exec_fifo_data.func3)
                    3'h0:begin
                        if(int_exec_fifo_data.func7==7'h20)begin
                            int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data-int_exec_fifo_data.common_data.rs2_data;
                        end
                        else if(int_exec_fifo_data.func7==7'h00)begin
                            int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data+int_exec_fifo_data.common_data.rs2_data;
                        end
                        else begin
                            int_submit.cdb_result=0;
                        end
                    end
                    3'h2:begin
                        int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data<int_exec_fifo_data.common_data.rs2_data ? 1 : 0;
                    end
                    3'h4:begin
                        int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data^int_exec_fifo_data.common_data.rs2_data;
                    end
                    3'h6:begin
                        int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data|int_exec_fifo_data.common_data.rs2_data;
                    end
                    3'h7:begin
                        int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data&int_exec_fifo_data.common_data.rs2_data;
                    end
                    default:begin
                        int_submit.cdb_result=0;
                    end
                endcase
            end 
            I_TYPE:begin
                case (int_exec_fifo_data.func3)
                    3'h0:begin
                        int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data+int_exec_fifo_data.common_data.rs2_data;
                    end
                    3'h4:begin
                        int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data^int_exec_fifo_data.common_data.rs2_data;
                    end
                    3'h6:begin
                        int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data|int_exec_fifo_data.common_data.rs2_data;
                    end
                    3'h7:begin
                        int_submit.cdb_result=int_exec_fifo_data.common_data.rs1_data&int_exec_fifo_data.common_data.rs2_data;
                    end
                    default:begin
                        int_submit.cdb_result=0;
                    end
                endcase
            end
            LUI_TYPE:begin
                int_submit.cdb_result=int_exec_fifo_data.common_data.rs2_data;
            end
            default:begin
                int_submit.cdb_result=0;
            end
        endcase
            int_submit.cdb_tag = int_exec_fifo_data.common_data.rd_tag;
            int_submit.cdb_valid = 1 & int_exec_fifo_data.common_data.wb_valid;
            int_submit.cdb_branch = 0;
            int_submit.cdb_branch_taken = 0;
            //int_submit.issue_done=1;
        end
        else begin
            case (int_exec_fifo_data.func3)
                3'h0:begin
                    int_submit.cdb_branch_taken=(int_exec_fifo_data.common_data.rs1_data==int_exec_fifo_data.common_data.rs2_data);
                end
                3'h1:begin
                    int_submit.cdb_branch_taken=(int_exec_fifo_data.common_data.rs1_data!=int_exec_fifo_data.common_data.rs2_data);
                end 
                default:begin
                    int_submit.cdb_branch_taken=1'b0;
                end 
                endcase
            int_submit.cdb_branch = 1'b1;
            int_submit.cdb_valid = 1'b0;
            int_submit.cdb_tag = 0;
            int_submit.cdb_result =0;
            //int_submit.issue_done=1;
        end
    end
    else begin
        int_submit.cdb_branch = 1'b0;
        int_submit.cdb_valid = 1'b0;
        int_submit.cdb_tag = 0;
        int_submit.cdb_result =0;
        //int_submit.issue_done=0;
    end
end


//latency generator
genvar i;
generate
    if (LATENCY>0)begin
        ffd_param #(.LENGTH($bits(cdb_bfm))) latency(
            .i_clk(clk),
            .i_rst_n(rst_n),
            .i_en(1'b1),
            .d(int_submit),
            .q(latency_submit[0])
        );
        assign o_int_submit=latency_submit[LATENCY-1];
    end
    else begin
        assign o_int_submit=int_submit;
    end
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

//assign issue_done = latency_submit[LATENCY-1].issue_done;
endmodule
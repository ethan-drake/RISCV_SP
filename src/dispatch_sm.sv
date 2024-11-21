// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            20/11/24
// File:			     dispatch_sm.sv
// Module name:	  dispatch_sm
// Project Name:	  risc_v_sp
// Description:	  dispatch_sm

`include "utils.sv"
module dispatch_sm(
    input clk,
    input rst_n,
    input branch_detected,
    input queue_full,
    input cdb_branch,
    input cdb_branch_taken,
    output reg stall_br,
    output reg dispatch_next_instr
);

stall_br_enum current_state;
stall_br_enum next_state;


//next change always
always @(posedge clk, negedge rst_n) begin
    if(!rst_n)begin
        current_state = NORMAL_OP;
        next_state = NORMAL_OP;
    end
    else begin
        current_state = next_state;
    end
end

//state machine
always @(*) begin
    case (current_state)
        NORMAL_OP:begin
            //outputs definition
            stall_br = 1'b0;
            dispatch_next_instr = 1'b0;
            //next state definition
            if(branch_detected==1'b1 && queue_full==1'b0)begin
                next_state = STALL_BRANCH;
            end
            else begin
                next_state = NORMAL_OP;
            end
        end
        STALL_BRANCH:begin
            //outputs definition
            stall_br = 1'b1;
            if(branch_detected == 1'b1 && cdb_branch_taken==1'b0)begin
                dispatch_next_instr = 1'b0;
            end
            else if(branch_detected == 1'b1 && cdb_branch_taken==1'b1)begin
                dispatch_next_instr = 1'b1;
            end
            else begin
                dispatch_next_instr = 1'b0;
            end
            //next state definition
            if(cdb_branch==1'b1)begin
                next_state = NORMAL_OP;
            end
            else begin
                next_state = STALL_BRANCH;
            end
        end 
        default:begin
        end 
    endcase
end

endmodule
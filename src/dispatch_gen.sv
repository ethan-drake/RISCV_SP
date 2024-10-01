`include "utils.sv"

module dispatch_gen(
    input [4:0] rs1,
    input [4:0] rs2,
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [6:0] opcode,
    input [2:0] func3,
    input [6:0] func7,
    input [31:0] immediate,
    input [6:0] rs1_tag,
    input [6:0] rs2_tag,
    input [5:0] rd_tag,
    input [31:0] jmp_br_addr,
    input branch_stall,
    input br_stall_one_shot,
    output common_fifo_data o_mult_fifo_data,
    output common_fifo_data o_div_fifo_data,
    output reg int_dispatch_en,
    output reg mult_dispatch_en,
    output reg div_dispatch_en,
    output reg ld_st_dispatch_en,
    output int_fifo_data o_int_fifo_data,
    output ld_st_fifo_data o_ld_st_fifo_data
);

common_fifo_data cmn_fifo_data;

always @(*) begin
    cmn_fifo_data.rs1_data = rs1_data;
    cmn_fifo_data.rs2_data = rs2_data;
    cmn_fifo_data.rs1_tag = rs1_tag[5:0];
    cmn_fifo_data.rs2_tag = rs2_tag[5:0];
    cmn_fifo_data.rd_tag = rd_tag;
    
    if (rs1 == 0)begin
        cmn_fifo_data.rs1_data_valid = 1'b1;
    end
    else begin
        cmn_fifo_data.rs1_data_valid = 1'b0;
    end
    if (rs2 == 0)begin
        cmn_fifo_data.rs2_data_valid = 1'b1;
    end
    else begin
        cmn_fifo_data.rs2_data_valid = 1'b0;
    end
    if (!branch_stall || br_stall_one_shot)begin
        case (opcode)
            R_TYPE: begin
                if(func3==0 && func7==7'h1)begin
                    //Multiplication
                    int_dispatch_en = 1'b0;
                    mult_dispatch_en = 1'b1;
                    div_dispatch_en = 1'b0;
                    ld_st_dispatch_en = 1'b0;
                end
                else if(func3==7'h4 && func7==7'h1)begin
                    //Division
                    int_dispatch_en = 1'b0;
                    mult_dispatch_en = 1'b0;
                    div_dispatch_en = 1'b1;
                    ld_st_dispatch_en = 1'b0;
                end
                else begin
                    int_dispatch_en = 1'b1;
                    mult_dispatch_en = 1'b0;
                    div_dispatch_en = 1'b0;
                    ld_st_dispatch_en = 1'b0;
                end
            end
            I_TYPE: begin
                cmn_fifo_data.rs2_data = immediate;
                cmn_fifo_data.rs2_data_valid = 1'b1;
                int_dispatch_en = 1'b1;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b0;
            end
            LOAD_TYPE: begin
                cmn_fifo_data.rs2_data_valid = 1'b1;
                int_dispatch_en = 1'b0;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b1;
            end
            STORE_TYPE: begin
                int_dispatch_en = 1'b0;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b1;
            end
            BRANCH_TYPE: begin
                int_dispatch_en = 1'b1;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b0;
            end
            J_TYPE: begin
                int_dispatch_en = 1'b1;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b0;
            end
            JALR_TYPE: begin
                int_dispatch_en = 1'b1;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b0;
            end
            LUI_TYPE: begin
                int_dispatch_en = 1'b1;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b0;
            end
            AUIPC_TYPE: begin
                int_dispatch_en = 1'b1;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b0;
            end
            default:begin
                int_dispatch_en = 1'b0;
                mult_dispatch_en = 1'b0;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b0;
            end
        endcase
    end
    else begin
        int_dispatch_en = 1'b0;
        mult_dispatch_en = 1'b0;
        div_dispatch_en = 1'b0;
        ld_st_dispatch_en = 1'b0;
    end
end

assign o_int_fifo_data.opcode = opcode;
assign o_int_fifo_data.func3 = func3;
assign o_int_fifo_data.func7 = func7;

assign o_ld_st_fifo_data.ld_st_opcode = opcode;
assign o_ld_st_fifo_data.func3 = func3;


assign o_mult_fifo_data = cmn_fifo_data;
assign o_div_fifo_data = cmn_fifo_data;
assign o_int_fifo_data.common_data = cmn_fifo_data;
assign o_ld_st_fifo_data.common_data = cmn_fifo_data;
assign o_ld_st_fifo_data.immediate = jmp_br_addr;


endmodule
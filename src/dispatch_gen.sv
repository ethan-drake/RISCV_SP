`include "utils.sv"

module dispatch_gen(
    //input dispatch_2_en,
    //input [4:0] rs1,
    //input [4:0] rs2,
    //input [4:0] rd,
    //input [31:0] rs1_data,
    //input [31:0] rs2_data,
    //input cdb_rs1_sel,
    //input cdb_rs2_sel,
    //input [6:0] opcode,
    //input [2:0] i_dispatch_gen_str.func3,
    //input [6:0] i_dispatch_gen_str.func7,
    //input [31:0] immediate,
    //input [6:0] rs1_tag,
    //input [6:0] rs2_tag,
    //input [5:0] rd_tag,

    input dispatch_gen_str i_dispatch_gen_str,
    //input branch_stall,
    //input br_stall_one_shot,
    //input br_stall_one_shot_2,
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
    cmn_fifo_data.rs1_data = i_dispatch_gen_str.rs1_data;
    cmn_fifo_data.rs2_data = i_dispatch_gen_str.rs2_data;
    cmn_fifo_data.rs1_tag = i_dispatch_gen_str.rs1_tag[5:0];
    cmn_fifo_data.rs2_tag = i_dispatch_gen_str.rs2_tag[5:0];
    cmn_fifo_data.rd_tag = i_dispatch_gen_str.rd_tag;
    
    //RS1 valid evaluation if rs1 is register zero
    if (i_dispatch_gen_str.rs1 == 0)begin
        cmn_fifo_data.rs1_data_valid = 1'b1;
    end
    else begin
        cmn_fifo_data.rs1_data_valid = i_dispatch_gen_str.rs1_valid;
    end
    //else if(i_dispatch_gen_str.cdb_rs1_sel)begin
    //    cmn_fifo_data.rs1_data_valid = 1'b1;
    //end
    //else begin
    //    cmn_fifo_data.rs1_data_valid = ~i_dispatch_gen_str.rs1_tag[6];//1'b0;
    //end
    
    //RS2 valid evaluation
    if (i_dispatch_gen_str.rs2 == 0)begin
        cmn_fifo_data.rs2_data_valid = 1'b1;
    end
    else begin
        cmn_fifo_data.rs2_data_valid = i_dispatch_gen_str.rs2_valid;
    end
    //else if (i_dispatch_gen_str.cdb_rs2_sel)begin
    //    cmn_fifo_data.rs2_data_valid = 1'b1;
    //end
    //else begin
    //    cmn_fifo_data.rs2_data_valid = ~i_dispatch_gen_str.rs2_tag[6];//1'b0;
    //end

    cmn_fifo_data.wb_valid = 1'b1;

    //if (!i_dispatch_gen_str.branch_stall || i_dispatch_gen_str.br_stall_one_shot || i_dispatch_gen_str.br_stall_one_shot_2)begin
    case (i_dispatch_gen_str.opcode)
        R_TYPE: begin
            if(i_dispatch_gen_str.func3==0 && i_dispatch_gen_str.func7==7'h1)begin
                //Multiplication
                int_dispatch_en = 1'b0;
                mult_dispatch_en = 1'b1;
                div_dispatch_en = 1'b0;
                ld_st_dispatch_en = 1'b0;
            end
            else if(i_dispatch_gen_str.func3==7'h4 && i_dispatch_gen_str.func7==7'h1)begin
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
            
            if (i_dispatch_gen_str.rd == 0)begin
                cmn_fifo_data.wb_valid = 1'b0;
            end
        end
        I_TYPE: begin
            cmn_fifo_data.rs2_data = i_dispatch_gen_str.immediate;
            cmn_fifo_data.rs2_data_valid = 1'b1;
            int_dispatch_en = 1'b1;
            mult_dispatch_en = 1'b0;
            div_dispatch_en = 1'b0;
            ld_st_dispatch_en = 1'b0;
            
            if (i_dispatch_gen_str.rd == 0)begin
                cmn_fifo_data.wb_valid = 1'b0;
            end
        end
        LOAD_TYPE: begin
            cmn_fifo_data.rs2_data_valid = 1'b1;
            int_dispatch_en = 1'b0;
            mult_dispatch_en = 1'b0;
            div_dispatch_en = 1'b0;
            ld_st_dispatch_en = 1'b1;
            
            if (i_dispatch_gen_str.rd == 0)begin
                cmn_fifo_data.wb_valid = 1'b0;
            end
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
            int_dispatch_en = 1'b0;
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
            cmn_fifo_data.rs2_data = i_dispatch_gen_str.immediate;
            cmn_fifo_data.rs2_data_valid = 1'b1;
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
    //end
    //else begin
    //    int_dispatch_en = 1'b0;
    //    mult_dispatch_en = 1'b0;
    //    div_dispatch_en = 1'b0;
    //    ld_st_dispatch_en = 1'b0;
    //end
end

assign o_int_fifo_data.opcode = i_dispatch_gen_str.opcode;
assign o_int_fifo_data.func3 = i_dispatch_gen_str.func3;
assign o_int_fifo_data.func7 = i_dispatch_gen_str.func7;

assign o_ld_st_fifo_data.ld_st_opcode = (i_dispatch_gen_str.opcode==STORE_TYPE) ? 1'b1: 1'b0;
assign o_ld_st_fifo_data.func3 = i_dispatch_gen_str.func3;
assign o_ld_st_fifo_data.immediate = i_dispatch_gen_str.immediate;


assign o_mult_fifo_data = cmn_fifo_data;
assign o_div_fifo_data = cmn_fifo_data;
assign o_int_fifo_data.common_data = cmn_fifo_data;
assign o_ld_st_fifo_data.common_data = cmn_fifo_data;


endmodule
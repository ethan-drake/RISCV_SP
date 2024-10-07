`include "utils.sv"

module rd_enabled(
    input [4:0] rd,
    input [6:0] opcode,
    output reg rd_enable
);

always @(*) begin
    case (opcode)
        R_TYPE,
        I_TYPE,
        LOAD_TYPE,
        J_TYPE,
        JALR_TYPE,
        LUI_TYPE,
        AUIPC_TYPE:
        begin
            rd_enable = (rd != 0) ? 1'b1:1'b0;
        end
        default: begin
            rd_enable=1'b0;
        end
    endcase
end

endmodule
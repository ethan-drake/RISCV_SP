// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            22/09/24
// File:			     br_jmp_addr_calc.sv
// Module name:	  br_jmp_addr_calc
// Project Name:	  risc_v_sp
// Description:	  br_jmp_addr_calc

module br_jmp_addr_calc(
    input [31:0] pc,
    input [6:0] opcode,
    input [31:0] immediate,
    output reg[31:0] jmp_br_addr,
    output reg jmp_detected,
    output reg branch_detected
);

parameter B_TYPE = 7'b1100011;
parameter JAL_INS = 7'b1101111;
parameter JALR_INS = 7'b1100111;

always @(*) begin
    jmp_detected=1'b0;
    jmp_br_addr = 0;
    branch_detected=1'b0;
    case (opcode)
        B_TYPE:
        begin
                jmp_br_addr = pc+immediate;
                branch_detected=1'b1;
                jmp_detected=1'b0;
        end
        JAL_INS:
        begin
                jmp_br_addr = pc+immediate;
                branch_detected=1'b0;
                jmp_detected=1'b1;
        end
        default:
        begin
            jmp_br_addr = 0;
            branch_detected=1'b0;
            jmp_detected=1'b0;
        end
        /*
        calcular direccion de salto para JALR, falta agregar rs1 del RST
        JALR_INS
        begin
            jmp_br_addr = rs1+immediate;
        end
        */
    endcase
end

endmodule
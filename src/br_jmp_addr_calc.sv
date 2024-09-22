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
    output [31:0] jmp_br_addr
);

parameter B_TYPE = 7'b1100011;
parameter JAL_INS = 7'b1101111;
parameter JALR_INS = 7'b1100111;

always @(*) begin
    jmp_br_addr = 0;
    case (opcode)
        B_TYPE:
        begin
                jmp_br_addr = pc+immediate;
        end
        JAL_INS:
        begin
                jmp_br_addr = pc+immediate;
        end
        default
        begin
            jmp_br_addr = 0;
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
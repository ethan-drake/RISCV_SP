// Coder:           Eduardo Ethandrake Castillo, David Adrian Michel Torres
// Date:            November 20th, 2022
// File:			     double_multiplexor_param.v
// Module name:	  double_multiplexor_param
// Project Name:    risc_v_top
// Description:	  This is a 4 input multiplexor, with 2 bits selector

module double_multiplexor_param_one_hot #(parameter LENGTH=1)(
    //inputs
    input  [LENGTH-1:0] i_a,
    input  [LENGTH-1:0] i_b,
	 input  [LENGTH-1:0] i_c,
	 input  [LENGTH-1:0] i_d,
    input  [3:0] i_selector,
    //outputs
    output reg [LENGTH-1:0] out
);

//First multiplexors results go to final multiplexor
always @(*) begin
    case (i_selector)
        4'b0001:begin
            out=i_a;
        end
        4'b0010:begin
            out=i_b;
        end
        4'b0100:begin
            out=i_c;
        end
        4'b1000:begin
            out=i_d;
        end
        default:begin
            out=0;
        end 
    endcase
end
endmodule
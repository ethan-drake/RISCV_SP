// Coder:           David Adrian Michel Torres, Eduardo Ethandrake Castillo Pulido
// Date:            16/03/23
// File:			     multiplexor_param.v
// Module name:	  multiplexor_param
// Project Name:	  risc_v_top
// Description:	  This is a 2 input multiplexor, 0 selects a, 1 selects b

module multiplexor_param #(parameter LENGTH=1)(
    //inputs
    input [LENGTH-1:0] i_a,
    input [LENGTH-1:0] i_b,
    input i_selector,
    //outputs
    output [LENGTH-1:0] out
);

//Assigns output using ternary operator
assign out = i_selector ? i_b : i_a;

endmodule
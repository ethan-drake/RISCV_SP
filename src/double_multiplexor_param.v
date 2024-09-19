// Coder:           Eduardo Ethandrake Castillo, David Adrian Michel Torres
// Date:            November 20th, 2022
// File:			     double_multiplexor_param.v
// Module name:	  double_multiplexor_param
// Project Name:    risc_v_top
// Description:	  This is a 4 input multiplexor, with 2 bits selector

module double_multiplexor_param #(parameter LENGTH=1)(
    //inputs
    input [LENGTH-1:0] i_a,
    input [LENGTH-1:0] i_b,
	 input [LENGTH-1:0] i_c,
	 input [LENGTH-1:0] i_d,
    input [1:0] i_selector,
    //outputs
    output [LENGTH-1:0] out
);

//First multiplexors results go to final multiplexor
wire [LENGTH-1:0] out_mult1, out_mult2;

multiplexor_param #(.LENGTH(LENGTH)) mult1 (
	.i_a(i_a), .i_b(i_b), .i_selector(i_selector[0]), .out(out_mult1)
);

multiplexor_param #(.LENGTH(LENGTH)) mult2 (
	.i_a(i_c), .i_b(i_d), .i_selector(i_selector[0]), .out(out_mult2)
);

multiplexor_param #(.LENGTH(LENGTH)) mult3 (
	.i_a(out_mult1), .i_b(out_mult2), .i_selector(i_selector[1]), .out(out)
);

endmodule
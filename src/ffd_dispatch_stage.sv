// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            24/11/24
// File:			     ffd_dispatch_stage.v
// Module name:	  ffd_dispatch_stage
// Project Name:	  risc_v_top
// Description:	  This is a flipflopD register module

`include "utils.sv"
module ffd_dispatch_stage(
	//inputs
	input i_clk,
	input i_rst_n,
	input flush,
	input i_en,
	input dispatch_gen_str d,
	//outputs
	output dispatch_gen_str q
);

//Parametrized flip flop with synchronous reset and enable signal
always@(posedge i_clk, negedge i_rst_n)
begin
	if(!i_rst_n | flush)
		q <= 0; 
	else if(i_en)
		q <= d;
	else
		q <= q;
end

endmodule
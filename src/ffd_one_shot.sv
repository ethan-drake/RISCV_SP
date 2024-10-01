// Coder:           David Adrian Michel Torres, Eduardo Ethandrake Castillo Pulido
// Date:            16/03/23
// File:			     ffd_param_pc_risk.v
// Module name:	  ffd_param_pc_risk
// Project Name:	  risc_v_top
// Description:	  This is a flipflopD register module with PC start hack

module ffd_one_shot #()(
	//inputs
	input i_clk,
	input i_rst_n,
	input i_en,
	input d,
	input hold,
	input release_one_shot,
	//outputs
	output reg q
);

reg temp;
reg already_launched;

//Parametrized flip flop with synchronous reset and enable signal
always@(posedge i_clk, negedge i_rst_n)
begin
	if(!i_rst_n) begin
		temp <=1'b0;
		q <= 1'b0;
		already_launched <=0;
	end
	else if(i_en)begin
		if(temp & hold)begin
			q <= 0;
			temp <=1'b1;
			already_launched <=1'b1;
		end
		else if(already_launched==0)begin
			q <= d;
			temp <=1'b1;
		end
		if(release_one_shot)begin
			already_launched <=0;
		end
	end
	else begin
		q <= 0;
		temp <=1'b0;
	end
end



endmodule
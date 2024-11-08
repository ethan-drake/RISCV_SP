// Coder:           David Adrian Michel Torres, Eduardo Ethandrake Castillo Pulido
// Date:            16/03/23
// File:			     master_memory_map.v
// Module name:	  master_memory_map
// Project Name:	  risc_v_top
// Description:	  Master that constrolls the memory mapping

module master_memory_map #(parameter DATA_WIDTH = 32, parameter ADDR_WIDTH = 32) (
	//inputs from core
	input [(DATA_WIDTH-1):0] wd, address,
	input we, re, clk,
	//outputs to core
	output [(DATA_WIDTH-1):0] rd,
	//--------------------------------
	//Inputs from slaves
	input [(DATA_WIDTH-1):0] HRData1, HRData2, HRData3,
	//Outputs to slaves data & address
	output reg [(DATA_WIDTH-1):0] map_Data, map_Address,
	//Outputs to slaves write control
	output reg WSel_1, WSel_2,WSel_3,
	//Outputs to slaves read control
	output reg HSel_1, HSel_2,HSel_3
); 

//To select address
reg [1:0] mult_map, add_val;
//To evaluate address mapping conditions
always @(address) begin
	//RAM/UART
	if (address >= 32'h10_010_000 && address < 32'h10_040_000) begin
		//UART
		if (address >= 32'h10_010_040 && address <= 32'h10_010_060) begin
			add_val = 2'b01;
		end
		else
		begin
			add_val = 2'b00;
		end
	end else if (address >= 32'h10_040_000 && address < 32'h7fff_effc) begin
		add_val = 2'b10;
	end else begin
		add_val = 2'b00;
	end
end

//Decoder mapping
always @(add_val, we, wd, address) begin
	case(add_val)
		2'b00:
			begin  //RAM
				mult_map = 2'b00;
				HSel_1 = 1'b1;
				HSel_2 = 1'b0;
				HSel_3 = 1'b0;
				WSel_1 = we;
				WSel_2 = 1'b0;
				WSel_3 = 1'b0;
				map_Address = (address + (~32'h10_010_000 + 1'b1)) >> 2'h2; //10_010_000
				map_Data = wd;
			end
		2'b01:
			begin //UART
				mult_map = 2'b01;
				HSel_1 = 1'b0;
				HSel_2 = 1'b1;
				HSel_3 = 1'b0;
				WSel_1 = 1'b0;
				WSel_2 = we;
				WSel_3 = 1'b0;
				map_Address = address + (~32'h10_010_040 + 1'b1) >> 2'h2; //to UART
				map_Data = wd;
			end
		2'b10:
			begin //STACK (inside RAM)
				mult_map = 2'b00;
				HSel_1 = 1'b1;
				HSel_2 = 1'b0;
				HSel_3 = 1'b0;
				WSel_1 = we;
				WSel_2 = 1'b0;
				WSel_3 = 1'b0;
				map_Address = (address - 32'h7fff_effc + 32'hD4) >> 2'h2; //to STACK(inside RAM) address - upper limit + current RAM size
				map_Data = wd;
			end
			//RAM Stack
		default: //Reserved
			begin
				mult_map = 2'b00;
				HSel_1 = 1'b0;
				HSel_2 = 1'b0;
				HSel_3 = 1'b0;
				WSel_1 = 1'b0;
				WSel_2 = 1'b0;
				WSel_3 = 1'b0;
				map_Address = address;
				map_Data = wd;
			end
	endcase
end

double_multiplexor_param #(.LENGTH(DATA_WIDTH)) memory_map_mult (
	.i_a(HRData1),//RAM & STACK
	.i_b(HRData2),//UART
	.i_c(32'h0),
	.i_d(32'h0),
	.i_selector(mult_map),
	.out(rd)
);

endmodule

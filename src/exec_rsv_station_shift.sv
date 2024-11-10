// Coder:           Eduardo Ethandrake Castillo Pulido
// Date:            18/09/24
// File:			     exec_rsv_station.sv
// Module name:	  exec_rsv_station_shift
// Project Name:	  mips_sp
// Description:	  execution rsv_station_shift

module exec_rsv_station_shift #(parameter DEPTH=4, DATA_WIDTH=128)(
    input i_clk,
    input i_rst_n,
    input [DATA_WIDTH-1:0] data_in,
    input w_en,
    input flush,
    output reg [DATA_WIDTH-1:0] data_out,
    output reg empty,
    output o_full,
    input [5:0] cdb_tag,
    input cdb_valid,
    input [31:0] cdb_data,
    output reg issue_queue_rdy,
    input issue_completed
);
localparam POINTER_WIDTH = $clog2(DEPTH);
reg [DATA_WIDTH-1:0] rsv_station[DEPTH];
reg [DEPTH-1:0] occupied;
reg [DEPTH-1:0] occupied_mask;
reg [DEPTH-1:0] shifted;

 
reg instruction_written;
//assign issue_queue_rdy = |occupied; 
reg full;


always @(posedge i_clk, negedge i_rst_n) begin
    //Reset or flush
    if(!i_rst_n | flush)begin
        occupied = 0;
        rsv_station[0] = 0;
        rsv_station[1] = 0;
        rsv_station[2] = 0;
        rsv_station[3] = 0;
        instruction_written=0;
        shifted=4'b0000;
    end
    else begin
        if(issue_completed)begin //shifting
        //rsv_station 0
            if(~(occupied[0] & occupied_mask[0]))begin //check if its not occupied
                if(occupied[1] & occupied_mask[1])begin //if [1] has data get from it
                    rsv_station[0]=rsv_station[1];
                    occupied[0]=1;
                    occupied[1]=0;
                    shifted|=4'b0001;
                    occupied_mask[0]=1;
                    occupied_mask[1]=0;
                end
            end
            //rsv_station 1
            if(~(occupied[1] & occupied_mask[1]))begin //check if its not occupied
                if(occupied[2] & occupied_mask[2])begin //if [2] has data get from it
                    rsv_station[1]=rsv_station[2];
                    occupied[1]=1;
                    occupied[2]=0;
                    shifted|=4'b0010;
                    occupied_mask[1]=1;
                    occupied_mask[2]=0;
                end
            end
            //rsv_station 2
            if(~(occupied[2] & occupied_mask[2]))begin //check if its not occupied
                if(occupied[3] & occupied_mask[3])begin //if [1] has data get from it
                    rsv_station[2]=rsv_station[3];
                    occupied[2]=1;
                    occupied[3]=0;
                    shifted|=4'b0100;
                    occupied_mask[2]=1;
                    occupied_mask[3]=0;
                end
            end
        end
        else begin
            shifted=4'b0000;
        end
        //writing new instr to rsv station

        if (w_en & !full) begin
            if((~(occupied[0] & occupied_mask[0])) & (~shifted[0]))begin
                rsv_station[0]=data_in;
                occupied[0]=1'b1;
                occupied_mask[0]=1;
            end
            else if((~(occupied[1] & occupied_mask[1])) & (~shifted[1]))begin
                rsv_station[1]=data_in;
                occupied[1]=1'b1;
                occupied_mask[1]=1;
            end
            else if((~(occupied[2] & occupied_mask[2])) & (~shifted[2]))begin
                rsv_station[2]=data_in;
                occupied[2]=1'b1;
                occupied_mask[2]=1;
            end
            else if((~(occupied[3] & occupied_mask[3])) & (~shifted[3]))begin
                rsv_station[3]=data_in;
                occupied[3]=1'b1;
                occupied_mask[3]=1;
            end
        end
    end
    //flushing
    if(flush)begin
        occupied=0;
        rsv_station[0] = 0;
        rsv_station[1] = 0;
        rsv_station[2] = 0;
        rsv_station[3] = 0;
    end
end

//updating
always @(posedge i_clk) begin
    if (cdb_valid)begin
        //rs1 update
        //checks if rs1 is not valid and tag is equal to cdb_tag
        if(rsv_station[0] !=0 && rsv_station[0][51]==1'b0 && rsv_station[0][50:45]==cdb_tag)begin
            rsv_station[0][83:52]=cdb_data;
            rsv_station[0][51]=1'b1; //set rs1 as valid because from cdb fwd
        end
        if(rsv_station[1] !=0 && rsv_station[1][51]==1'b0 && rsv_station[1][50:45]==cdb_tag)begin
            rsv_station[1][83:52]=cdb_data;
            rsv_station[1][51]=1'b1; //set rs1 as valid because from cdb fwd
        end
        if(rsv_station[2] !=0 && rsv_station[2][51]==1'b0 && rsv_station[2][50:45]==cdb_tag)begin
            rsv_station[2][83:52]=cdb_data;
            rsv_station[2][51]=1'b1; //set rs1 as valid because from cdb fwd
        end
        if(rsv_station[3] !=0 && rsv_station[3][51]==1'b0 && rsv_station[3][50:45]==cdb_tag)begin
            rsv_station[3][83:52]=cdb_data;
            rsv_station[3][51]=1'b1; //set rs1 as valid because from cdb fwd
        end

        //rs2 update
        //checks if rs2 is not valid and tag is equal to cdb_tag
        if(rsv_station[0] !=0 && rsv_station[0][12]==1'b0 && rsv_station[0][11:6]==cdb_tag)begin
            rsv_station[0][44:13]=cdb_data;
            rsv_station[0][12]=1'b1; //set rs2 as valid because from cdb fwd
        end
        if(rsv_station[1] !=0 && rsv_station[1][12]==1'b0 && rsv_station[1][11:6]==cdb_tag)begin
            rsv_station[1][44:13]=cdb_data;
            rsv_station[1][12]=1'b1; //set rs2 as valid because from cdb fwd
        end
        if(rsv_station[2] !=0 && rsv_station[2][12]==1'b0 && rsv_station[2][11:6]==cdb_tag)begin
            rsv_station[2][44:13]=cdb_data;
            rsv_station[2][12]=1'b1; //set rs2 as valid because from cdb fwd
        end
        if(rsv_station[3] !=0 && rsv_station[3][12]==1'b0 && rsv_station[3][11:6]==cdb_tag)begin
            rsv_station[3][44:13]=cdb_data;
            rsv_station[3][12]=1'b1; //set rs2 as valid because from cdb fwd
        end
    end
end

//full signal logic
always @(*) begin
    if(!i_rst_n)begin
        full = 1;
    end
    else if(flush)begin
        full = 0;
    end
    else begin
        full = (occupied == 4'hF && issue_completed == 1'b0) ? 1 :0;
    end
end
//empty signal logic
always @(*) begin
    if(!i_rst_n)begin
        empty = 0;
    end
    else if(flush)begin
        empty = 1;
    end
    else begin
        empty = (occupied == 4'h0) ? 1 :0;
    end
end

//update occupied
always @(posedge i_clk) begin
    if (!empty)begin//rd_en)begin
        if(issue_completed)begin
            occupied = occupied & occupied_mask;
        end
    end
end

//reading
always @(*) begin
    if(!i_rst_n | flush)begin
        data_out=0;
        issue_queue_rdy=1'b0;
        occupied_mask=4'b0000;
    end
    else if(!empty)begin//rd_en)begin
        //check if location is occupied and rs2 is valid and rs1 is valid
        if(occupied[0] && rsv_station[0][12]==1'b1 && rsv_station[0][51]==1'b1)begin
            data_out = rsv_station[0];
            occupied_mask = issue_completed ? 4'b1110 : 4'b1111;
            issue_queue_rdy=1'b1;
        end
        else if(occupied[1] && rsv_station[1][12]==1'b1 && rsv_station[1][51]==1'b1)begin
            data_out = rsv_station[1];
            occupied_mask = issue_completed ? 4'b1101 : 4'b1111;
            issue_queue_rdy=1'b1;
        end
        else if(occupied[2] && rsv_station[2][12]==1'b1 && rsv_station[2][51]==1'b1)begin
            data_out = rsv_station[2];
            occupied_mask = issue_completed ? 4'b1011 : 4'b1111;
            issue_queue_rdy=1'b1;
        end
        else if(occupied[3] && rsv_station[3][12]==1'b1 && rsv_station[3][51]==1'b1)begin
            data_out = rsv_station[3];
            occupied_mask = issue_completed ? 4'b0111 : 4'b1111;
            issue_queue_rdy=1'b1;
        end
        else begin
            data_out=0;
            occupied_mask = 4'b1111;
            issue_queue_rdy=1'b0;
        end

    end
    else begin
        data_out=0;
        issue_queue_rdy=1'b0;
    end
end

    //empty cuando todas las flags de occupied sean 0
    //full cuando todas las flags de occupied sean 1
    assign o_full = full;

endmodule
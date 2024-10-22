typedef enum bit[6:0]{ 
   R_TYPE=7'b0110011,
   I_TYPE=7'b0010011,
   LOAD_TYPE=7'b0000011,
   STORE_TYPE=7'b0100011,
   BRANCH_TYPE=7'b1100011,
   J_TYPE=7'b1101111,
   JALR_TYPE=7'b1100111,
   LUI_TYPE=7'b0110111,
   AUIPC_TYPE=7'b0010111
} riscv_opcode;

typedef struct packed {
  bit [5:0] cdb_tag;
  bit cdb_valid;
  bit [31:0] cdb_result;
  bit cdb_branch;
  bit cdb_branch_taken;
  bit issue_done;
} cdb_bfm;

typedef enum bit[1:0] { 
   INT_FIFO=2'h0,
   LD_ST_FIFO=2'h1,
   MULT_FIFO=2'h2,
   DIV_FIFO=2'h3
} fifo_data_type;

typedef struct packed {
   logic [31:0] rs1_data;  //83:52
   logic rs1_data_valid;   //51
   logic [5:0] rs1_tag;    //50:45
   logic [31:0] rs2_data;  //44:13
   logic rs2_data_valid;   //12
   logic [5:0] rs2_tag;    //11:6
   logic [5:0] rd_tag;     //5:0
 } common_fifo_data;

typedef struct packed {
    logic dispatch_en;
    logic queue_full;
    logic queue_empty;
} common_fifo_ctrl;

 typedef struct packed {
    logic [6:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;
    common_fifo_data common_data;
 } int_fifo_data;

typedef struct packed {
    //1 bit opcode to distinguish between LD&ST
    logic ld_st_opcode;
    logic [2:0] func3;
    //change immediate value for risc-v ISA
    logic [31:0] immediate;
    common_fifo_data common_data;
 } ld_st_fifo_data;

typedef struct packed {
   logic issue_rdy;
   int_fifo_data rsv_station_data;
 } int_issue_data;

typedef struct packed {
   logic issue_rdy;
   common_fifo_data rsv_station_data;
} common_issue_data;

typedef struct packed {
   logic issue_rdy;
   ld_st_fifo_data rsv_station_data;
} mem_issue_data;

typedef struct packed {
   cdb_bfm issue_cdb;
   logic issue_done;
} cdb_submit_data;
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
   logic [31:0] rs1_data;
   logic rs1_data_valid;
   logic [5:0] rs1_tag;
   logic [31:0] rs2_data;
   logic rs2_data_valid;
   logic [5:0] rs2_tag;
   logic [5:0] rd_tag;
 } common_fifo_data;

typedef struct packed {
    logic dispatch_en;
    logic queue_full;
    logic queue_empty;
} common_fifo_ctrl;

 typedef struct packed {
    common_fifo_data common_data;
    logic [2:0] opcode;
    logic [2:0] func3;
    logic [6:0] func7;
 } int_fifo_data;

 typedef struct packed {
    common_fifo_data common_data;
    //1 bit opcode to distinguish between LD&ST
    logic ld_st_opcode;
    logic [2:0] func3;
    //change immediate value for risc-v ISA
    logic [31:0] immediate;
 } ld_st_fifo_data;
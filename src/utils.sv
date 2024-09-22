typedef enum type { 

 } name;

 typedef struct packed {
   logic [31:0] rs_data;
   logic rs_data_valid;
   logic [5:0] rs_tag
   logic [31:0] rt_data;
   logic rt_data_valid;
   logic [5:0] rt_tag;
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
 } int_fifo_data;

 typedef struct packed {
    common_fifo_data common_data;
    //1 bit opcode to distinguish between LD&ST
    logic ld_st_opcode;
    //change immediate value for risc-v ISA
    logic [15:0] immediate;
 } ld_st_fifo_data;
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

typedef enum bit { 
   ROB_0
} rob_state;

typedef enum bit { 
   NORMAL_OP,
   STALL_BRANCH
 }stall_br_enum;

typedef struct packed {
  bit [5:0] cdb_tag;
  bit cdb_valid;
  bit [31:0] cdb_result;
  bit cdb_branch;
  bit cdb_branch_taken;
  //logic [31:0] store_data;
  //bit issue_done;
} cdb_bfm;

typedef enum bit[1:0] { 
   INT_FIFO=2'h0,
   LD_ST_FIFO=2'h1,
   MULT_FIFO=2'h2,
   DIV_FIFO=2'h3
} fifo_data_type;

typedef struct packed {
   //logic wb_valid; //84, no mover porque altera el orden de bits para el cdb update
   logic [31:0] rs1_data;  //83:52
   logic rs1_data_valid;   //51
   logic [5:0] rs1_tag;    //50:45
   logic [31:0] rs2_data;  //44:13
   logic rs2_data_valid;   //12
   logic [5:0] rs2_tag;    //11:6
   logic [5:0] rd_tag;     //5:0
 } common_fifo_data;

//typedef struct packed {
//    logic dispatch_en;
//    logic queue_full;
//    logic queue_empty;
//} common_fifo_ctrl;

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

typedef enum bit[1:0] { 
   NON_VALID_RD_TAG=2'h0,
   BRANCH=2'h1,
   STORE =2'h2,
   JUMP = 2'h3
 } dispatch_type;

//typedef struct packed {
//   logic valid;
//   //riscv_opcode instr_type;
//   dispatch_type instr_type;
//   rob_state state;
//   logic [4:0] rd;
//   logic [4:0] rd_tag;
//   logic [31:0] rd_value;
//   logic [31:0] store_addr;
//   logic [31:0] store_data;
//   logic [31:0] pc;
//   logic exception;
//} rob_fifo_data;

typedef struct packed {
   logic [4:0] rd_reg;
   logic [31:0] pc; //now it is instr_pc //pc address to jump when branch instr
   logic [31:0] calculated_br_target;
   dispatch_type inst_type;
   logic [31:0] spec_data;
   logic spec_valid;
   logic branch_taken;
   logic branch_prediction;
   logic valid;
   //logic [31:0] store_data;
} rob_rf_data;

enum bit[1:0] { 
   PENDING_BACKEND,
   ROB_SPECULATIVE,
   REGFILE_RDY
} rst_state;

interface dispatch_check_rs_status;
   
   logic [4:0] rs1_reg;
   logic rs1_reg_ren;
   logic [5:0] rs1_token;
   logic [31:0] rs1_data_spec;
   logic rs1_data_valid; //if rs_data_valid == 1 speculative in ROB
   logic [4:0] rs2_reg;
   logic rs2_reg_ren;
   logic [5:0] rs2_token;
   logic [31:0] rs2_data_spec;
   logic rs2_data_valid; //if rt_data_valid == 1 speculative in ROB

   modport rob (
   input rs1_reg, rs1_reg_ren, rs2_reg, rs2_reg_ren, rs1_token, rs2_token,
   output rs1_data_spec, rs1_data_valid, rs2_data_spec, rs2_data_valid
   );

   modport dispatcher (
   input rs1_data_spec, rs1_data_valid, rs2_data_spec, rs2_data_valid,
   output rs1_reg, rs1_reg_ren, rs2_reg, rs2_reg_ren, rs1_token, rs2_token

   );

endinterface //dispatch_check_rs_status



interface dispatch_w_to_rob #(parameter type DTYPE= dispatch_type);
   
   logic [5:0] dispatch_rd_tag;  // tag assigned by TAG FIFO
   logic [4:0] dispatch_rd_reg;
   logic [31:0] dispatch_pc;     //instruction PC that corresponds to rd_tag, if branches this is jump address
   DTYPE dispatch_instr_type;
   logic dispatch_en;   //tells if current instruction will be sent to next pipe
   logic dispatch_need_tag;   //tells if current instruction needs update RST
   logic [31:0] calculated_br_target;
   logic branch_prediction;
   
   modport rob (
   input dispatch_rd_tag, dispatch_rd_reg, dispatch_pc, dispatch_instr_type, dispatch_en, calculated_br_target, branch_prediction
   );
   modport dispatcher (
   output dispatch_rd_tag, dispatch_rd_reg, dispatch_pc, dispatch_instr_type, dispatch_en, calculated_br_target, branch_prediction
   );
endinterface //dispatch_w_to_rob

interface retire_bus;

   logic [5:0] rd_tag;
   logic [4:0] rd_reg;  //register that must be updated in register file
   logic [31:0] data;
   logic [31:0] pc;  
   logic [31:0] calculated_br_target; //just makes sense in case a misspredicted branch
   logic [31:0] retired_branch_prediction; //branch prediction that was used originally, intend is to compare with calculated_br_target
   logic branch;     //specifies if retired instruction is a branch
   logic branch_taken;  //specifies the branch must been taken (wrong prediction)
   logic branch_prediction;
   logic store_ready;   //if retired instruction is a store
   logic valid;      //tells if an instruction is retiring
   logic spec_valid; //tells if head instr is retired from order_queue, retire signal data are valid and rf can be modified
   logic flush;  //tells if flush needed, RTS & TAG FIFO will restart to original state, dispatch stages not proceding with instr
   logic store_executed;   //tells if store has been executed
  // logic [31:0] store_data;
   logic [1:0] retire_instr_type;

   modport rob (
   input store_executed, retired_branch_prediction,
   output rd_tag, rd_reg, data, pc, branch, branch_taken, store_ready, valid, flush, spec_valid, retire_instr_type, calculated_br_target, branch_prediction
   );

   modport dispatcher (
   input rd_tag, rd_reg, data, pc, branch, branch_taken, store_ready, valid, flush, spec_valid, retire_instr_type, calculated_br_target, branch_prediction,
   output store_executed, retired_branch_prediction
   );
endinterface //retire_bus


typedef struct packed {
   //logic dispatch_2_en;
   logic [4:0] rs1;
   logic [4:0] rs2;
   logic [4:0] rd;
   logic [31:0] rs1_data;
   logic [31:0] rs2_data;
   //logic cdb_rs1_sel;
   //logic cdb_rs2_sel;
   logic [6:0] opcode;
   logic [2:0] func3;
   logic [6:0] func7;
   logic [31:0] immediate;
   logic rs1_valid;
   logic rs2_valid;
   logic [5:0] rs1_tag;
   logic [5:0] rs2_tag;
   logic [5:0] rd_tag;
   logic [31:0] jmp_br_addr;
} dispatch_gen_str;

typedef struct packed {
   logic store_ready;
   logic [31:0] mem_address;
   logic [31:0] retire_rs2_data;
} retire_store;

typedef struct packed {
   logic [31:0] data;
   logic [31:0] address;
   logic valid;
} wc_array;
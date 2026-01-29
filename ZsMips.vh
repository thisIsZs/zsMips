/*定义ALUOP*/
`define R_ALUOP     4'b0000

`define ADD_ALUOP   4'b0001
`define ADDU_ALUOP  4'b0010
`define SUB_ALUOP   4'b0011

`define AND_ALUOP   4'b0100
`define OR_ALUOP    4'b0101
`define XOR_ALUOP   4'b0110

`define SLTI_ALUOP  4'b0111
`define SLTIU_ALUOP 4'b1000


/*ALUCTL信号*/
`define ADD_CTL   5'b00000
`define SUB_CTL   5'b00001
`define ADDU_CTL  5'b11010
`define SUBU_CTL  5'b11011

`define AND_CTL   5'b00010
`define OR_CTL    5'b00011
`define XOR_CTL   5'b00100
`define NOR_CTL   5'b00101

`define SLL_CTL   5'b00110
`define SRL_CTL   5'b00111
`define SRA_CTL   5'b01000
`define SLT_CTL   5'b01001
`define SLTU_CTL  5'b01010
`define SLLV_CTL  5'b01011
`define SRLV_CTL  5'b01100
`define SRAV_CTL  5'b01101

`define MULT_CTL   5'b01110
`define MULTU_CTL  5'b01111

`define DIV_CTL    5'b10000
`define DIVU_CTL   5'b10001

`define MTHI_CTL   5'b10100
`define MTLO_CTL   5'b10101


//R type FUNC字段
`define     ADD_FUNC        6'b100000       // ADD
`define     ADDU_FUNC       6'b100001       // ADDU
`define     SUB_FUNC        6'b100010       // SUB
`define     SUBU_FUNC       6'b100011       // SUBU

`define     SLT_FUNC        6'b101010       // SLT
`define     SLTU_FUNC       6'b101011       // SLTU

`define     SLL_FUNC        6'b000000       // SLL
`define     SLLV_FUNC       6'b000100       // SLLV
`define     SRA_FUNC        6'b000011       // SRA
`define     SRAV_FUNC       6'b000111       // SRAV
`define     SRL_FUNC        6'b000010       // SRL
`define     SRLV_FUNC       6'b000110       // SRLV

`define     MULT_FUNC       6'b011000       // MULT
`define     MULTU_FUNC      6'b011001       // MULTU
`define     DIV_FUNC        6'b011010       // DIV
`define     DIVU_FUNC       6'b011011       // DIVU

`define     AND_FUNC        6'b100100       // AND
`define     NOR_FUNC        6'b100111       // NOR
`define     OR_FUNC         6'b100101       // OR
`define     XOR_FUNC        6'b100110       // XOR

`define     JR_FUNC         6'b001000       // JR
`define     JALR_FUNC       6'b001001       // JALR

`define     MFHI_FUNC       6'b010000       // MFHI
`define     MFLO_FUNC       6'b010010       // MFLO
`define     MTHI_FUNC       6'b010001       // MTHI
`define     MTLO_FUNC       6'b010011       // MTLO

    /*特权指令*/
`define     BREAK_FUNC      6'b001101       // BREAK
`define     SYSCALL_FUNC    6'b001100       // SYSCALL


//CP0指令RS字段
`define     MFC0_TYPE       5'b00000        // MFC0
`define     MTC0_TYPE       5'b00100        // MTC0


//指令opcode
`define     R_OP           6'b000000        // R(26条)

`define     ADDI_OP         6'b001000       // ADDI
`define     ADDIU_OP        6'b001001       // ADDIU

`define     ANDI_OP         6'b001100       // ANDI
`define     ORI_OP          6'b001101       // ORI
`define     XORI_OP         6'b001110       // XORI
`define     SLTI_OP         6'b001010       //SLTI
`define     SLTIU_OP        6'b001011       //SLTIU

`define     BEQ_OP          6'b000100       // BEQ
`define     BNE_OP          6'b000101       // BNE
`define     BGTZ_OP         6'b000111       // BGTZ
`define     BLEZ_OP         6'b000110       // BLEZ
`define     BZ_OP           6'b000001       //BGEZ, BLTZ, BGEZAL, BLTZAl

`define     J_OP            6'b000010       // J
`define     JAL_OP          6'b000011       // JAL 

`define     LUI_OP          6'b001111       // LUI

`define     LB_OP           6'b100000       // LB
`define     LBU_OP          6'b100100       // LBU
`define     LH_OP           6'b100001       // LH
`define     LHU_OP          6'b100101       // LHU
`define     LW_OP           6'b100011       // LW
`define     SH_OP           6'b101001       // SH
`define     SB_OP           6'b101000       // SB
`define     SW_OP           6'b101011       // SW

    /*特权指令*/
`define     ERET_INST     32'b01000010000000000000000000011000  // ERET
`define     MFTC0_OP         6'b010000       //MFC0 MTC0


//MEM信号
`define     LB_TYPE     3'b000
`define     LBU_TYPE    3'b001
`define     LH_TYPE     3'b010
`define     LHU_TYPE    3'b011
`define     LW_TYPE     3'b100
`define     SB_TYPE     3'b101
`define     SH_TYPE     3'b110
`define     SW_TYPE     3'b111


//BRANCH SPECIAL
`define     BGEZ_TYPE       5'b00001
`define     BLTZ_TYPE       5'b00000
`define     BGEZAL_TYPE     5'b10001
`define     BLTZAL_TYPE     5'b10000

//Exception Code
`define EXC_CODE_NONE       5'h01
`define EXC_CODE_INT        5'h00
`define EXC_CODE_ADEL       5'h04
`define EXC_CODE_ADES       5'h05
`define EXC_CODE_SYS        5'h08
`define EXC_CODE_BP         5'h09
`define EXC_CODE_RI         5'h0A
`define EXC_CODE_ERET       5'h0B //自定义
`define EXC_CODE_OV         5'h0C


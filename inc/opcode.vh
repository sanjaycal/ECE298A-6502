`ifndef OPCODES
    `define OPCODES 1

    //OPCODE

    `define OP_ALU_SHIFT_ZPG    8'b0xx00110
    `define OP_ALU_SHIFT_ZPG_X  8'b0XX10110
    `define OP_ALU_SHIFT_ABS    8'b0xx01110

    `define OP_ASL          8'b000xxx10
    `define OP_ASL_ZPG      8'b00000110
    `define OP_ASL_A        8'b00001010
    `define OP_ASL_ABS      8'b00001110
    `define OP_ASL_ZPG_X    8'b00010110
    
    `define OP_LSR          8'b010xxx10
    `define OP_LSR_ZPG      8'b01000110
    `define OP_LSR_A        8'b01001010
    `define OP_LSR_ABS      8'b01001110
    `define OP_LSR_ZPG_X    8'b01010110

    `define OP_ROL          8'b001xxx10
    `define OP_ROL_ZPG      8'b00100110
    `define OP_ROL_A        8'b00101010
    `define OP_ROL_ABS      8'b00101110
    `define OP_ROL_ZPG_X    8'00110110

    `define OP_JSR          8'b00100000

    `define OP_NOP          8'b11101010         
    // ADDRESSING
    `define ADR_ZPG         3'b001
    `define ADR_ZPG_X       3'b101
    `define ADR_ABS         3'b011
    `define ADR_A           3'b010

`endif

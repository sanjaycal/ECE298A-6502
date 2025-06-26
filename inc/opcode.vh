`ifndef OPCODES
    `define OPCODES 1

    //OPCODE

    `define OP_ASL          8'b000xxx10
    `define OP_ASL_ZPG      8'b00000110
    `define OP_ASL_A        8'b00001010
    
    `define OP_JSR          8'b00100000

    // ADDRESSING
    `define ADR_ZPG         3'b001
    `define ADR_ABS         3'b011
    `define ADR_A           8'b0xx01010

`endif
